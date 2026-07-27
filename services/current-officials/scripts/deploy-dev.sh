#!/usr/bin/env bash

# Deploy the public development environment.

set -euo pipefail

: "${CONGRESS_API_KEY:?Set CONGRESS_API_KEY}"
region="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-west-2}}"
root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bucket="$(AWS_REGION="$region" "$root_dir/scripts/boot.sh")"

make -C "$root_dir" check test package

tofu -chdir="$root_dir/infra" init -reconfigure \
  -backend-config="bucket=$bucket" \
  -backend-config="key=civics/current-officials/dev.tfstate" \
  -backend-config="region=$region" \
  -backend-config="use_lockfile=true"

tofu -chdir="$root_dir/infra" apply -auto-approve -var-file=dev.tfvars

aws ssm put-parameter --region "$region" --overwrite --type SecureString \
  --name /civics/dev/congress-api-key --value "$CONGRESS_API_KEY" >/dev/null

function_name="$(tofu -chdir="$root_dir/infra" output -raw refresh_function_name)"
aws lambda invoke --region "$region" --function-name "$function_name" \
  --invocation-type RequestResponse "$root_dir/dist/dev-refresh-response.json" >/dev/null
