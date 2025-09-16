#!/bin/bash
TARGET_USER=$1
TARGET_HOST=$2
REMOTE_TEMP_PATH="/tmp/migrations_$(date +%s)"

rsync -avz -e "ssh -o StrictHostKeyChecking=no" ./migrations/ "${TARGET_USER}@${TARGET_HOST}:${REMOTE_TEMP_PATH}/"

ssh -o StrictHostKeyChecking=no ${TARGET_USER}@${TARGET_HOST} << EOF
  echo "Applying migrations..."
  for SCRIPT in \$(ls -v ${REMOTE_TEMP_PATH}/*.sql); do
    echo "Applying \$SCRIPT..."
    clickhouse-client -h localhost --query="\$(cat \$SCRIPT)" # Adapte o client para hive, etc.
  done
  rm -rf ${REMOTE_TEMP_PATH}
EOF