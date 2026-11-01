# Validation history

Initial commit validated locally with rootless Podman on 2026-11-01
(the authentication and remote-fetch policy below was subsequently changed):

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

## Public sharing and remote fetching

Rebuilt and tested the corrected policy end to end through temporary host-network
nginx and rootless application containers on 2026-11-01:

- Anonymous and incorrect-password POSTs returned 401.
- Authenticated multipart upload returned a hosted URL and management token.
- Anonymous GET retrieved identical bytes; HEAD returned 200; range returned 206.
- Anonymous remote-fetch POST returned 401; authenticated fetch of a controlled
  HTTP fixture succeeded and its generated link downloaded without credentials.
- Management POST without Basic Auth returned 401 even with a valid token.
- Authenticated management with an invalid token returned 401.
- Authenticated deletion with a valid token succeeded; the public link became 404.
- URL shortening remained disabled (400).

No VPS changes. Temporary containers and fixture data were removed.

## Public homepage

Reviewed the live upstream index and added an instance-template override.
Rebuilt the image and verified rendered GET/HEAD responses with the actual
Flask application: personal-service notice, public-download policy,
authenticated upload/remote-fetch/management examples, HTTPS example URLs,
and limits/retention derived from runtime configuration. Tested alternate
20 MiB and 42-day settings to confirm these values are not hardcoded.
No VPS changes.
