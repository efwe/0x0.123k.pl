# 0x123k.pl

Private 0x0 file hosting with host nginx providing HTTPS and one-user Basic Auth.
Gunicorn runs the upstream Flask application in a rootless Podman container.
All URLs, including downloads and management requests, require authentication.
No scanners, models, moderation UI, URL fetching, or new shortened URLs.

## Build

Run as `fw`, locally or on the VPS:

```sh
podman build -t localhost/0x123k:latest .
```

Upstream is downloaded from its canonical forge as a commit archive, verified
with SHA-256. No submodule or Git installation is needed in the image.
The base is Python 3.12 on Debian Bookworm slim. The base image digest and all Python dependency versions are pinned.
Update these explicitly when applying dependency and base security updates.
Debian package updates are resolved at build time.

## VPS installation

Check `/etc/os-release` first: 26.04 is Ubuntu version numbering, not Debian.
Install Podman with Quadlet support (Podman 4.4+), nginx, and apache2-utils using
the host distribution packages. Run the following as `fw`:

```sh
mkdir -p /home/fw/0x0/data ~/.config/containers/systemd ~/.config/systemd/user
chmod 700 /home/fw/0x0/data
cp deploy/0x123k.container ~/.config/containers/systemd/
cp deploy/0x123k-prune.service deploy/0x123k-prune.timer ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user start 0x123k.service
systemctl --user enable --now 0x123k-prune.timer
sudo loginctl enable-linger fw
```

Quadlet generates the service; its `[Install]` section starts it on future boots.
The keep-id mapping gives container UID 1000 ownership corresponding to `fw`.
Only `/home/fw/0x0/data` is bind-mounted, read/write at `/data`.
Port 5000 is published only on IPv4 loopback. Other local VPS users can access
that port directly; nginx is the authentication boundary.

Create the one nginx account (password is prompted, not placed in history):

```sh
sudo htpasswd -cB /etc/nginx/0x123k.htpasswd fw
sudo chown root:www-data /etc/nginx/0x123k.htpasswd
sudo chmod 640 /etc/nginx/0x123k.htpasswd
```

Include the contents of `deploy/nginx.conf` inside the existing HTTPS server
block for `0x123k.pl`. Keep the host's certificate configuration and HTTP redirect.
Adjust the nginx group above if your distribution uses a different worker group.

```sh
sudo nginx -t
sudo systemctl reload nginx
```

Basic Auth covers the entire server. Review any existing locations that might
bypass the proxy or override authentication. No credentials are in the image.
To change the password later, run htpasswd again without `-c`.

## Use and configuration

```sh
curl -u fw -F file=@example.txt https://0x123k.pl/
curl -u fw https://0x123k.pl/RETURNED_NAME.txt
```

Curl prompts for the password. Save response headers with `-D headers.txt` when
you need upstream's `X-Token` for deletion or expiration management.
Management POST requests require both Basic Auth and the upstream token.

Configuration is baked into the image; no config directory mount is needed.
Edit the Quadlet environment settings to change hostname, request size, or
retention, then daemon-reload and restart the service. Match nginx's upload
limit when changing the app limit. Default request limit: 256 MiB including
multipart overhead. Default maximum retention: 365 days for all file sizes;
uploaders can request less. Expiration cleanup runs daily, so removal is not
instantaneous. Changes to retention apply to subsequent uploads.

```sh
systemctl --user status 0x123k.service
journalctl --user -u 0x123k.service
podman exec 0x123k python -m flask --app fhost prune
```

## Backup, update, and rollback

Stop the service before copying the entire data directory, including SQLite
journals; restart afterward. Restore the complete directory with the service
stopped and preserve its ownership. Back up nginx configuration and htpasswd
separately on the host.

Before upgrading, retain the previous image under a dated local tag and make a
consistent data backup. Update the upstream commit and archive checksum together
in Containerfile, review dependency changes, rebuild, and restart. Startup runs
upstream database migrations. A rollback after a schema change may require
restoring the matching data backup, not just reverting the image.

Verify anonymous access returns 401, authenticated upload/download works,
management tokens work, and uploads survive container recreation. Check HTTPS
URLs in upload responses, size limits, and range requests before relying on
media seeking. Deployment does not automatically modify the VPS.

## Upstream and license

Upstream: https://git.0x0.st/mia/0x0
Pinned commit: `0cd289d9812675f60a9d81b0b9ce0a3d08cc4d35` (2025-03-01).
Upstream is EUPL-1.2-or-later; its notices and license are retained in the image.
This repository is intended to remain private; no remote is created automatically.
