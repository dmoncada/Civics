# Civics current-officials service

The service supplies the changing answers in the USCIS civics question set. It does not accept
addresses, coordinates, user identifiers, or accounts.

## Local verification

```sh
uv sync
make check
make package
```

Run `make test`, `make lint`, `make format`, or `make typecheck` individually while developing.
The Make targets use `uv` and the lockfile; `make format` applies Ruff formatting, while
`make check` verifies formatting without changing files. `make package` exports the locked
production dependencies and creates the two Lambda ZIP archives in `dist/`. It requires `uv`
and `zip`.

To invoke the handler locally, set `CONGRESSIONAL_TABLE_NAME` to a DynamoDB table reachable from
your AWS credentials, then call `src.api.lambda_handler(event, None)` from `uv run python`.
For example:

```sh
CONGRESSIONAL_TABLE_NAME=current-officials \
  uv run python -c 'from src.api import lambda_handler; print(lambda_handler({"queryStringParameters":{"jurisdiction":"WA"}}, None))'
```

For a local refresh, copy `.env.example` to `.env`, set `CONGRESS_API_KEY`, and load it with
`uv run --env-file .env`. The refresh handler uses `CONGRESS_API_KEY` when present; otherwise it
uses the deployed `CONGRESS_API_KEY_PARAMETER` SSM parameter. Docker Compose can use the same
file through `env_file: .env`.

## Local Lambda and DynamoDB

Docker Compose runs the API Lambda Runtime Interface Emulator, DynamoDB Local, and a seed job.
The seed job creates the `current-officials` table and inserts a deterministic Washington record.

```sh
docker compose up --build
curl -X POST http://localhost:9000/2015-03-31/functions/function/invocations \
  -d '{"queryStringParameters":{"jurisdiction":"WA"}}'
```

### Local HTTP API with SAM

SAM CLI exposes the same HTTP shape as the deployed API while Compose provides DynamoDB and
performs one refresh from Congress.gov. Copy `.env.example` to `.env`, set `CONGRESS_API_KEY`,
then run:

```sh
make local-api
```

In another terminal, call the API directly. Query parameters are converted to the Lambda event
by SAM, so no Lambda invocation payload is needed:

```sh
curl 'http://localhost:3000/api/v1/current-officials?jurisdiction=WA'
```

The response contains all of the jurisdiction's representatives in `representatives`. Numbered
districts are integers; representatives without a district omit `district`.

`make local-api` starts Compose, builds and starts SAM, then invokes the refresh Lambda once.
Stop it with `Ctrl-C`; the script stops SAM and runs `docker compose --profile refresh down`
automatically.

The API uses `DYNAMODB_ENDPOINT_URL` only when it is set; Compose sets it to the local DynamoDB
container, while AWS Lambda continues to use DynamoDB's standard AWS endpoint. Stop the local
environment with `docker compose down`.

To test the refresh Lambda, copy `.env.example` to `.env` and set `CONGRESS_API_KEY`, then start
the optional refresh profile. It calls the live Congress.gov API and writes refreshed records to
the local DynamoDB table.

```sh
docker compose --profile refresh up --build
curl -X POST http://localhost:9001/2015-03-31/functions/function/invocations -d '{}'
```

`registry/current-officials.json` is the reviewed record for the president, vice president,
Speaker, Chief Justice, and governors. Each registry change must cite an official source in the
pull request and update `asOf`. Congressional data is refreshed daily from Congress.gov and
cached in DynamoDB.

## AWS infrastructure and deployment

OpenTofu manages two isolated environments: `dev` and `prod`. Their state is kept separately
in one versioned, encrypted S3 bucket; running either deployment script safely reconfigures the
local OpenTofu working directory to that environment's state key.

Each environment contains a regional API Gateway REST API, four Python Lambdas (officials API,
Congress refresh, App Attest endpoints, and the request authorizer), DynamoDB tables for
congressional data and App Attest state, SecureString SSM parameters for runtime secrets,
30-day CloudWatch log groups, and a daily EventBridge refresh rule. `dev` is public. `prod`
uses the request authorizer and is exposed at `https://civics.dmoncada.net/api/v1` through an
API Gateway custom domain and a proxied Cloudflare CNAME.

Scripts:

- `scripts/boot.sh` creates or reuses the shared OpenTofu S3 state bucket and prints its name.
- `scripts/deploy.sh` packages, deploys, and refreshes the public `dev` environment.
- `scripts/deploy-prod.sh` packages, deploys, sets production SSM secrets, and refreshes `prod`.
- `scripts/retrieve-prod-api-key.sh` prints the production developer test key from SSM; handle
  its output as a secret.

The deployment scripts require authenticated AWS CLI credentials with access to the target AWS
account, OpenTofu, Docker (for Linux Lambda packaging), and a Congress.gov API key. `boot.sh`
only needs AWS CLI credentials.

### Deployment sequence

1. Create the shared state bucket once:

   ```sh
   ./scripts/boot.sh
   ```

2. Deploy the public development environment whenever needed:

   ```sh
   export CONGRESS_API_KEY='...'
   ./scripts/deploy.sh
   ```

3. Before the first production deploy, provision the ACM certificate and validate it in
   Cloudflare. Use the same state bucket but a distinct `domain.tfstate` key:

   ```sh
   BUCKET="$(./scripts/boot.sh)"
   tofu -chdir=infra/domain init -reconfigure \
     -backend-config="bucket=$BUCKET" \
     -backend-config='key=civics/current-officials/domain.tfstate' \
     -backend-config='region=us-west-2' \
     -backend-config='use_lockfile=true'
   tofu -chdir=infra/domain apply
   tofu -chdir=infra/domain output validation_records
   ```

   Create the displayed ACM validation CNAME in Cloudflare, wait for the certificate to be
   issued, then ensure `civics.dmoncada.net` is a proxied CNAME to the API Gateway domain target
   output after the next step. Cloudflare SSL/TLS mode must be **Full (strict)**.

4. Deploy production:

   ```sh
   export CONGRESS_API_KEY='...'
   ./scripts/deploy-prod.sh
   ```

   The script obtains the ACM certificate ARN from `infra/domain` state and preserves an existing
   production test key, or generates the initial one. Retrieve the key only when needed:

   ```sh
   ./scripts/retrieve-prod-api-key.sh
   ```

5. For GitHub Actions production deployments, complete the one-time GitHub OIDC role setup and
   configure the workflow's required repository secrets before relying on pushes to `main`.
