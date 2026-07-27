#!/usr/bin/env bash

# Usage: CONGRESS_API_KEY=... CURRENT_OFFICIALS_TEST_KEY=... CLOUDFARE_API_TOKEN=... \
#   ./scripts/deploy.sh staging|prod

set -euo pipefail

environment="${1:-}"
case "$environment" in staging|prod) ;; *) echo "Usage: $0 <staging|prod>" >&2; exit 2 ;; esac

: "${CONGRESS_API_KEY:?Set CONGRESS_API_KEY}"
: "${CURRENT_OFFICIALS_TEST_KEY:?Set CURRENT_OFFICIALS_TEST_KEY}"
region="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-west-2}}"
root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bucket="$(AWS_REGION="$region" "$root_dir/scripts/bootstrap-tofu-state.sh")"

make -C "$root_dir" check test package
tofu -chdir="$root_dir/infra" init \
  -backend-config="bucket=$bucket" \
  -backend-config="key=civics/current-officials/$environment.tfstate" \
  -backend-config="region=$region" \
  -backend-config="use_lockfile=true"
tofu -chdir="$root_dir/infra" apply -auto-approve -var-file="$environment.tfvars"

aws ssm put-parameter --region "$region" --overwrite --type SecureString \
  --name "/civics/$environment/congress-api-key" --value "$CONGRESS_API_KEY" >/dev/null
aws ssm put-parameter --region "$region" --overwrite --type SecureString \
  --name "/civics/$environment/current-officials-test-key" --value "$CURRENT_OFFICIALS_TEST_KEY" >/dev/null

function_name="$(tofu -chdir="$root_dir/infra" output -raw refresh_function_name)"
aws lambda invoke --region "$region" --function-name "$function_name" \
  --invocation-type RequestResponse "$root_dir/dist/refresh-response.json" >/dev/null
