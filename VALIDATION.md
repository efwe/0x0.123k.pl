# Initial validation

Validated locally with rootless Podman on 2026-11-01:

- Built the pinned upstream archive and verified its SHA-256.
- Started Gunicorn and initialized the SQLite database using upstream migrations.
- Uploaded a multipart file and received an HTTPS URL and management token.
- Downloaded identical bytes; byte-range request returned 206 and expected bytes.
- Rejected remote URL fetching and URL shortening with 400.
- Rejected a wrong management token with 401; accepted deletion with the correct token.
- Recreated the container using the same bind directory and retrieved the original file.
- Ran pruning successfully and checked dependency consistency with pip check.
- Confirmed optional scanning/model/moderation packages were absent.
- Pinned the tested base digest and complete installed Python dependency versions,
  then rebuilt successfully.
- Validated the nginx snippet using nginx:stable-alpine: syntax passed, anonymous
  and incorrect-password requests returned 401, correct-password requests passed
  authentication and reached the proxy (502 with the test backend absent).
- Generated the user service with the installed Quadlet generator in dry-run mode.

Test containers and temporary data were removed. VPS TLS, DNS, host nginx
integration, actual boot behavior, and large-upload limits still need deployment
verification. No live server was modified.
