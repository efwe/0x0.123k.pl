"""Small integration layer; upstream source remains unchanged."""
from flask import abort, request
from werkzeug.middleware.proxy_fix import ProxyFix
from fhost import app

# Only host nginx can reach the published loopback port. It overwrites these headers.
app.wsgi_app = ProxyFix(app.wsgi_app, x_for=1, x_proto=1)

@app.before_request
def disable_url_shortening():
    if request.method == "POST" and request.path == "/":
        if "shorten" in request.form:
            abort(400, "URL shortening is disabled.")
