#!/bin/sh
set -eu
mkdir -p /data/uploads /data/tmp
python -m flask --app fhost db upgrade
exec gunicorn --bind 0.0.0.0:5000 --workers 1 --threads 4 --timeout 300 --worker-tmp-dir /data/tmp --access-logfile - --error-logfile - wsgi:app
