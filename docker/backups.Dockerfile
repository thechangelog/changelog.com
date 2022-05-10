# Same minor version as db pod
FROM postgres:12.6

ENV SHELL=/bin/bash
ENV TERM=xterm

RUN pg_dump --version | grep "pg_dump.*12.6" \
    && bash --version | grep "bash.*5.0"

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install --no-install-recommends -y curl unzip ca-certificates groff rsync openssh-client \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && aws --version | grep  "aws-cli.*2." \
    && rm -rf /var/lib/apt/lists/* ./aws*

ARG BACKUP_EVERY_N_SECONDS=86400
ENV BACKUP_EVERY_N_SECONDS=${BACKUP_EVERY_N_SECONDS}

ARG AWS_S3_STORAGE_CLASS=STANDARD
ENV AWS_S3_STORAGE_CLASS=${AWS_S3_STORAGE_CLASS}

COPY always_waiting_on_your_selection backup_db_continuously backup_db_to_s3 backup_uploads_continuously backup_uploads_to_s3 clean_db download_last_db_backup load_backups_secrets restore_db_from_backup restore_uploads_from_s3 s3_backups upload_stdin_s3 /usr/local/bin/
RUN cd /usr/local/bin && chmod +x always_waiting_on_your_selection backup_db_continuously backup_db_to_s3 backup_uploads_continuously backup_uploads_to_s3 clean_db download_last_db_backup load_backups_secrets restore_db_from_backup restore_uploads_from_s3 s3_backups upload_stdin_s3

ENTRYPOINT ["/usr/local/bin/always_waiting_on_your_selection"]
