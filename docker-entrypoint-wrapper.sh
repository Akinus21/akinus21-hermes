#!/bin/bash
set -e
/usr/local/bin/init-evolution-repo.sh

exec /opt/hermes/docker/entrypoint-dispatch.sh "$@"
