# Same minor version as db container, 9.5
FROM postgres:9.5

ENV SHELL=/bin/bash
ENV TERM=xterm

RUN pg_dump --version | grep "pg_dump.*9.5" \
    && bash --version | grep "bash.*4.4"

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y ca-certificates s3cmd && s3cmd --version \
    && rm -rf /var/lib/apt/lists/*

ARG BACKUP_DB_EVERY_N_SECONDS=86400
ENV BACKUP_DB_EVERY_N_SECONDS=${BACKUP_DB_EVERY_N_SECONDS}

ARG AWS_S3_STORAGE_CLASS=STANDARD
ENV AWS_S3_STORAGE_CLASS=${AWS_S3_STORAGE_CLASS}

COPY backup_db_continuously upload_stdin_s3 /usr/local/bin/
RUN cd /usr/local/bin && chmod +x backup_db_continuously upload_stdin_s3

ENTRYPOINT ["/usr/local/bin/backup_db_continuously"]
