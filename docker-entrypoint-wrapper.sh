#!/bin/bash
set -e
/usr/local/bin/init-evolution-repo.sh

# Neither process below is `exec`'d directly, so this wrapper stays PID 1
# and can forward shutdown signals to both. Disable errexit first —
# under `set -e`, `wait -n` returning a child's non-zero exit would abort
# the script before the cleanup trap runs.
set +e

gosu hermes env HERMES_HOME="${HERMES_HOME:-/opt/data}" HERMES_BIN=/opt/hermes/bin/hermes \
  node /opt/hermes-client/service-runner.mjs &
CLIENT_PID=$!

/opt/hermes/docker/entrypoint-dispatch.sh "$@" &
HERMES_PID=$!

trap 'kill -TERM "$CLIENT_PID" "$HERMES_PID" 2>/dev/null' TERM INT

wait -n "$CLIENT_PID" "$HERMES_PID"
EXIT_CODE=$?
kill -TERM "$CLIENT_PID" "$HERMES_PID" 2>/dev/null
wait
exit $EXIT_CODE
