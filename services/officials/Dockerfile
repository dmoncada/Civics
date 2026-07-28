FROM ghcr.io/astral-sh/uv:0.11.29 AS uv
FROM public.ecr.aws/lambda/python:3.13 AS requirements

WORKDIR /build

COPY --from=uv /uv /uvx /bin/
COPY pyproject.toml uv.lock ./

RUN uv export --locked --no-dev --format requirements-txt --output-file requirements.txt

FROM public.ecr.aws/lambda/python:3.13 AS app

ARG SAM_LOCAL_DEBUG=false

COPY --from=requirements /build/requirements.txt ./

RUN pip install --no-cache-dir --requirement requirements.txt --target "${LAMBDA_TASK_ROOT}"

RUN if [ "$SAM_LOCAL_DEBUG" = "true" ]; then pip install --no-cache-dir debugpy; fi

COPY src "${LAMBDA_TASK_ROOT}/src"
COPY docker "${LAMBDA_TASK_ROOT}/docker"
COPY registry "${LAMBDA_TASK_ROOT}/registry"

CMD ["src.api.lambda_handler"]
