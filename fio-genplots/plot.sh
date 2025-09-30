#!/bin/sh
set -eu

echo "Plotting data..."
PLOTNAME=${PLOTNAME:-FIO}
OUTDIR=${OUTDIR:-plots}
mkdir -p "$OUTDIR"

# Expand globs in POSIX and ignore non-matches
find_logs() {
  for pat in "$@"; do
    # unquoted to allow globbing
    for f in $pat; do
      case "$f" in
        *'*'*|*'?'*|*'['*']'*)
          : ;;                 # still a pattern -> no matches
        *)
          [ -f "$f" ] && printf '%s\n' "$f"
          ;;
      esac
    done
  done
}

BW_LOGS="$(find_logs '*_bw.log' '*_bw.*.log')"
IOPS_LOGS="$(find_logs '*_iops.log' '*_iops.*.log')"
LAT_LOGS="$(find_logs '*_lat*.log' '*_clat*.log' '*_slat*.log')"

WORK=".norm"
rm -rf "$WORK"; mkdir "$WORK"

# Normalize time to integer milliseconds from t0
normalize() {
  in="$1"; out="$WORK/$(basename "$1")"
  # first numeric timestamp
  first="$(awk 'NF{print $1; exit}' "$in" 2>/dev/null || echo 0)"
  awk -v t0="$first" 'BEGIN{OFS="\t"; mode=0}
    NR==1{
      if (t0>=1000000000000)      mode=1; # epoch ms
      else if (t0>=1000000000)    mode=2; # epoch s
      else                        mode=3; # relative seconds
    }
    {
      t=$1
      if (mode==1)        t = t - t0;           # already ms
      else                t = (t - t0) * 1000;  # seconds -> ms
      $1 = int(t + 0.5)                         # force integer ms
      print
    }' "$in" > "$out"
}

# Normalize all logs we found
for f in $BW_LOGS $IOPS_LOGS $LAT_LOGS; do
  [ -n "${f:-}" ] && normalize "$f" || :
done

# best-effort bs hint for titles
BS_HINT=""
if [ -n "${JOBFILES:-}" ] && [ -f "$JOBFILES" ]; then
  BS_HINT="$(awk -F= '$0 ~ /(^|[,;[:space:]])bs[[:space:]]*=/ {print $2; exit}' "$JOBFILES" 2>/dev/null || true)"
fi
[ -z "$BS_HINT" ] && [ -f fio.output ] && BS_HINT="$(
  awk -F'[= ,]' '$0 ~ / bs=/ {for(i=1;i<=NF;i++) if($i=="bs"){print $(i+1); exit}}' fio.output 2>/dev/null || true
)"

cd "$WORK"

# detect optional flags
HAS_NO3D=""
if fio2gnuplot -h 2>&1 | grep -Eq '(^|[[:space:]])--no-3d([[:space:]]|,|$)'; then
  HAS_NO3D="--no-3d"
fi
HAS_LAT=""
if fio2gnuplot -h 2>&1 | grep -Eq '(^|[[:space:]])-l([[:space:]]|,|$)'; then
  HAS_LAT="-l"
fi

GP_OPTS="-g"
[ -n "$HAS_NO3D" ] && GP_OPTS="$GP_OPTS $HAS_NO3D"

ttl_bs=""
[ -n "$BS_HINT" ] && ttl_bs=" (bs=$BS_HINT)"

if [ -n "$BW_LOGS" ]; then
  echo "$(printf '%s\n' $BW_LOGS | wc -l | awk '{print $1}') files Selected with pattern '*_bw*'"
  fio2gnuplot $GP_OPTS -b -t "${PLOTNAME} - Bandwidth${ttl_bs}" -d "../$OUTDIR" || true
fi

if [ -n "$IOPS_LOGS" ]; then
  echo "$(printf '%s\n' $IOPS_LOGS | wc -l | awk '{print $1}') files Selected with pattern '*_iops*'"
  fio2gnuplot $GP_OPTS -i -t "${PLOTNAME} - IOPS${ttl_bs}" -d "../$OUTDIR" || true
fi

if [ -n "$LAT_LOGS" ] && [ -n "$HAS_LAT" ]; then
  echo "$(printf '%s\n' $LAT_LOGS | wc -l | awk '{print $1}') files Selected with pattern '*_lat|clat|slat*'"
  fio2gnuplot $GP_OPTS $HAS_LAT -t "${PLOTNAME} - Latency${ttl_bs}" -d "../$OUTDIR" || true
fi

cd ..
