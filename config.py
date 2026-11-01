"""Baked-in defaults; only operational settings need environment overrides."""
import os

SQLALCHEMY_DATABASE_URI = "sqlite:////data/database.sqlite"
FHOST_STORAGE_PATH = "/data/uploads"
SERVER_NAME = os.environ.get("PUBLIC_HOST", "0x123k.pl")
PREFERRED_URL_SCHEME = "https"
MAX_CONTENT_LENGTH = int(os.environ.get("MAX_UPLOAD_BYTES", 256 * 1024 * 1024))
# Fixed 365-day lifetime by default, independent of file size.
FHOST_MIN_EXPIRATION = FHOST_MAX_EXPIRATION = int(os.environ.get("RETENTION_DAYS", "365")) * 86400000
NSFW_DETECT = False
VSCAN_SOCKET = None
USE_X_SENDFILE = False
FHOST_USE_X_ACCEL_REDIRECT = False
