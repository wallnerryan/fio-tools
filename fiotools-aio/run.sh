#!/bin/sh

echo "Running FIO job $JOBFILES"
LOG_MS="${LOG_MS:-1000}"          # 1s buckets
STEM="${STEM:-result}"            # our merged log stem

# Run the user-supplied job, but force our own logs as well
fio \
  --write_bw_log="$STEM" \
  --write_iops_log="$STEM" \
  --write_lat_log="$STEM" \
  --log_avg_msec="$LOG_MS" \
  --log_unix_epoch=1 \
  --per_job_logs=0 \
  ${JOBFILES} 2>&1 | tee fio.output