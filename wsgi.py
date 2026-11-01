"""Small integration layer; upstream source remains unchanged."""
from flask import abort, request
from werkzeug.middleware.proxy_fix import ProxyFix
from fhost import app

# Only host nginx can reach the published loopback port. It overwrites these headers.
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1)

@app.before_request
def file_uploads_only():
    if request.method == "POST" and request.path == "/":
        if "url" in request.form or "shorten" in request.form:
            abort(400, "Only direct file uploads are enabled.")
