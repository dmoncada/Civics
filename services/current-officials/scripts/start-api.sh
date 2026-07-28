#!/usr/bin/env bash

# Starts the local HTTP API with fresh Congressional data. The refresh Lambda
# receives CONGRESS_API_KEY from .env through Docker Compose.

set -euo pipefail

sam_pid=""

cleanup() {
  local status=$?
  local container_id
  local -a network_container_ids=()

  if [[ -n "$sam_pid" ]]; then
    kill "$sam_pid" 2> /dev/null || true

    for _ in {1..10}; do
      if ! kill -0 "$sam_pid" 2> /dev/null; then
        break
      fi
      sleep 0.2
    done

    if kill -0 "$sam_pid" 2> /dev/null; then
      kill -KILL "$sam_pid" 2> /dev/null || true
    fi

    wait "$sam_pid" 2> /dev/null || true
  fi

  while IFS= read -r container_id; do
    if [[ -n "$container_id" ]]; then
      network_container_ids+=("$container_id")
    fi
  done < <(docker ps --quiet --all --filter network=current-officials_default)

  if (( ${#network_container_ids[@]} > 0 )); then
    docker rm --force "${network_container_ids[@]}" 2> /dev/null || true
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

sam_args=(local start-api --docker-network current-officials_default)
if [[ -n "${SAM_DEBUG_PORT:-}" ]]; then
  sam_args+=(
    --warm-containers lazy
    --debug-port "$SAM_DEBUG_PORT"
    --debug-function CurrentOfficialsFunction
    --debug-args "/var/lang/bin/python3.13 -Xfrozen_modules=off -m debugpy --listen 0.0.0.0:$SAM_DEBUG_PORT --wait-for-client /var/runtime/bootstrap.py"
  )
fi

sam build
sam "${sam_args[@]}" &
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
