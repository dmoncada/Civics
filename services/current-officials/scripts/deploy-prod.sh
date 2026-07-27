#!/usr/bin/env bash

# Manual production deploy. CI uses the same OpenTofu commands.

set -euo pipefail

: "${CONGRESS_API_KEY:?Set CONGRESS_API_KEY}"
region="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-west-2}}"
root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bucket="$(AWS_REGION="$region" "$root_dir/scripts/boot.sh")"

if [[ -z "${PRODUCTION_CERTIFICATE_ARN:-}" ]]; then
  PRODUCTION_CERTIFICATE_ARN="$(tofu -chdir="$root_dir/infra/domain" output -raw certificate_arn)"
fi

if [[ -z "${CURRENT_OFFICIALS_TEST_KEY:-}" ]]; then
  if CURRENT_OFFICIALS_TEST_KEY="$(aws ssm get-parameter --region "$region" \
    --name /civics/prod/current-officials-test-key --with-decryption \
    --query 'Parameter.Value' --output text 2>/dev/null)"; then
    :
  else
    CURRENT_OFFICIALS_TEST_KEY="$(openssl rand -base64 32)"
    echo "Generated the initial production test key; retrieve it later from SSM." >&2
  fi
fi

make -C "$root_dir" check test package

tofu -chdir="$root_dir/infra" init -reconfigure \
  -backend-config="bucket=$bucket" \
  -backend-config="key=civics/current-officials/prod.tfstate" \
  -backend-config="region=$region" \
  -backend-config="use_lockfile=true"

tofu -chdir="$root_dir/infra" apply -auto-approve \
  -var-file=prod.tfvars \
  -var="production_certificate_arn=$PRODUCTION_CERTIFICATE_ARN"

aws ssm put-parameter --region "$region" \
  --overwrite --type SecureString \
  --name /civics/prod/congress-api-key \
  --value "$CONGRESS_API_KEY" >/dev/null

aws ssm put-parameter --region "$region" \
  --overwrite --type SecureString \
  --name /civics/prod/current-officials-test-key \
  --value "$CURRENT_OFFICIALS_TEST_KEY" >/dev/null

function_name="$(tofu -chdir="$root_dir/infra" output -raw refresh_function_name)"
aws lambda invoke --region "$region" --function-name "$function_name" \
  --invocation-type RequestResponse "$root_dir/dist/prod-refresh-response.json" > /dev/null
