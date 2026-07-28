#!/usr/bin/env bash

# Starts the local HTTP API with fresh Congressional data. The refresh Lambda
# receives CONGRESS_API_KEY from .env through Docker Compose.

set -euo pipefail

sam_pid=""

cleanup() {
  local status=$?

  if [[ -n "$sam_pid" ]]; then
    kill "$sam_pid" 2> /dev/null || true
    wait "$sam_pid" 2> /dev/null || true
  fi

  docker compose --profile refresh down
  exit "$status"
}

trap cleanup EXIT INT TERM

if [[ ! -f .env ]]; then
  echo "Missing .env. Copy .env.example and set CONGRESS_API_KEY." >&2
  exit 1
fi

docker compose --profile refresh up --build --detach dynamodb seed refresh

sam build
sam local start-api --docker-network current-officials_default &
sam_pid=$!

refresh_ready=false
for _ in {1..30}; do
  if curl --silent --output /dev/null --max-time 1 http://localhost:9001/; then
    refresh_ready=true
    break
  fi
  sleep 1
done

if [[ "$refresh_ready" != true ]]; then
  echo "Refresh Lambda did not become ready." >&2
  exit 1
fi

if ! kill -0 "$sam_pid" 2>/dev/null; then
  echo "SAM local API exited before refresh could run." >&2
  exit 1
fi

curl --fail --silent --show-error --max-time 180 \
  -X POST http://localhost:9001/2015-03-31/functions/function/invocations \
  -d '{}'

echo
echo "Refresh complete. Local API: http://localhost:3000/api/v1/current-officials"

wait "$sam_pid"
