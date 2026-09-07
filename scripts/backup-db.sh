#!/usr/bin/env bash
# ==============================================================================
# backup-db.sh — PostgreSQL dump → S3-compatible storage
# ==============================================================================
# A WORKING EXAMPLE, not a stack mandate. It implements whatever backup default you
# declare in docs/architecture/stack.md: a daily compressed dump to a bucket with
# configurable retention. It speaks S3, so it works as-is with any compatible
# storage; if your database is not PostgreSQL, this file is the starting point —
# swap `pg_dump`/`pg_restore` for their equivalent and the rest stays the same. If
# the product has no database, delete it.
#
# Requirements on the host: pg_dump (postgresql-client) and AWS CLI v2.
#
# Environment variables (the real values live in your credential manager and arrive
# via .env; see docs/conventions/secrets.md):
#   DATABASE_URL             postgres://user:pass@host:5432/database    (required)
#   BACKUP_S3_ENDPOINT       endpoint of the S3-compatible service      (required)
#   BACKUP_S3_ACCESS_KEY_ID  access token credential                    (required)
#   BACKUP_S3_SECRET_KEY     access token credential                    (required)
#   BACKUP_S3_BUCKET         destination bucket, e.g. myapp-backups     (required;
#                            different from the app's file bucket)
#   BACKUP_PREFIX            prefix inside the bucket (default: db)
#   BACKUP_RETENTION_DAYS    days the dumps are kept (default: 30)
#
# Usage:
#   ./scripts/backup-db.sh                       # manual
#   cron (VPS): 0 3 * * * cd /path/app && ./scripts/backup-db.sh >> /var/log/backup-db.log 2>&1
#   With an orchestrator: run it with cron on the host, or as a scheduled container command.
#
# Restore — TEST IT EVERY MONTH. A backup you never restored is an assumption:
#   export AWS_ACCESS_KEY_ID=$BACKUP_S3_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$BACKUP_S3_SECRET_KEY
#   aws s3 cp "s3://$BACKUP_S3_BUCKET/db/<file>.dump" . \
#     --endpoint-url "$BACKUP_S3_ENDPOINT"
#   pg_restore --clean --no-owner --dbname "$DATABASE_URL" <file>.dump
# ==============================================================================
set -euo pipefail

: "${DATABASE_URL:?Missing DATABASE_URL}"
: "${BACKUP_S3_ENDPOINT:?Missing BACKUP_S3_ENDPOINT}"
: "${BACKUP_S3_ACCESS_KEY_ID:?Missing BACKUP_S3_ACCESS_KEY_ID}"
: "${BACKUP_S3_SECRET_KEY:?Missing BACKUP_S3_SECRET_KEY}"
: "${BACKUP_S3_BUCKET:?Missing BACKUP_S3_BUCKET}"

BACKUP_PREFIX="${BACKUP_PREFIX:-db}"
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"

export AWS_ACCESS_KEY_ID="$BACKUP_S3_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$BACKUP_S3_SECRET_KEY"

# File name: <database>_<UTC timestamp>.dump
db_name="$(basename "${DATABASE_URL%%\?*}")"
timestamp="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
dump_file="${db_name}_${timestamp}.dump"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

echo "→ pg_dump of ${db_name}…"
pg_dump --format=custom --no-owner --file "${tmp_dir}/${dump_file}" "$DATABASE_URL"

echo "→ uploading to s3://${BACKUP_S3_BUCKET}/${BACKUP_PREFIX}/${dump_file}…"
aws s3 cp "${tmp_dir}/${dump_file}" \
  "s3://${BACKUP_S3_BUCKET}/${BACKUP_PREFIX}/${dump_file}" \
  --endpoint-url "$BACKUP_S3_ENDPOINT" --only-show-errors

echo "→ applying ${BACKUP_RETENTION_DAYS}-day retention…"
# date -d is GNU (Linux); date -v is BSD (macOS) — try the first, fall back to the second
cutoff_date="$(date -u -d "-${BACKUP_RETENTION_DAYS} days" +%Y-%m-%d 2>/dev/null \
  || date -u -v "-${BACKUP_RETENTION_DAYS}d" +%Y-%m-%d)"
aws s3 ls "s3://${BACKUP_S3_BUCKET}/${BACKUP_PREFIX}/" --endpoint-url "$BACKUP_S3_ENDPOINT" \
  | while read -r obj_date _obj_time _obj_size obj_name; do
      [ -n "$obj_name" ] || continue
      if [[ "$obj_date" < "$cutoff_date" ]]; then
        echo "   deleting ${obj_name} (${obj_date})"
        aws s3 rm "s3://${BACKUP_S3_BUCKET}/${BACKUP_PREFIX}/${obj_name}" \
          --endpoint-url "$BACKUP_S3_ENDPOINT" --only-show-errors
      fi
    done

echo "✓ backup ${dump_file} complete"
