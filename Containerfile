FROM docker.io/library/python:3.12-slim-bookworm@sha256:623674a14ef93d052bb9b0de4dbf5f28eb578a35263838941cc8aa43213c1487
ARG UPSTREAM_COMMIT=0cd289d9812675f60a9d81b0b9ce0a3d08cc4d35
ARG UPSTREAM_SHA256=95c3d2935229a7a19f84f8ace7798b680b4f6de9e1a012b518487228fa9930a4
LABEL org.opencontainers.image.title="0x123k.pl" \
      org.opencontainers.image.description="Private minimal 0x0 file host"
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 TMPDIR=/data/tmp
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl libmagic1 \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN curl --fail --location --retry 3 "https://git.0x0.st/mia/0x0/archive/${UPSTREAM_COMMIT}.tar.gz" -o /tmp/upstream.tar.gz \
    && echo "${UPSTREAM_SHA256}  /tmp/upstream.tar.gz" | sha256sum -c - \
    && tar -xzf /tmp/upstream.tar.gz --strip-components=1 -C /app \
    && rm /tmp/upstream.tar.gz
COPY requirements.txt /app/requirements-minimal.txt
RUN pip install --no-cache-dir -r /app/requirements-minimal.txt \
    && useradd --uid 1000 --no-create-home app \
    && mkdir -p /data && chown app:app /data
COPY config.py /app/instance/config.py
COPY instance/templates/ /app/instance/templates/
COPY wsgi.py entrypoint.sh /app/
USER 1000:1000
EXPOSE 5000
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
