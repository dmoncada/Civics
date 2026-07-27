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
  uv run python -c 'from src.api import lambda_handler; print(lambda_handler({"queryStringParameters":{"jurisdiction":"WA","district":"10"}}, None))'
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
  -d '{"queryStringParameters":{"jurisdiction":"WA","district":"10"}}'
```

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
