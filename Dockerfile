# syntax=docker/dockerfile:1
FROM python:3.10 as python-base
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /code
ENV \
    # pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # poetry
    POETRY_VERSION=1.7.1 \
    POETRY_HOME=/opt/poetry \
    POETRY_VIRTUALENVS_CREATE=0 \
    POETRY_NO_INTERACTION=1 \
    \
    # paths
    CODE_PATH=/code

# prepend poetry to path
ENV PATH=$POETRY_HOME/bin:$PATH

# `builder-base` stage is used to build deps + create our environment
FROM python-base as builder-base
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential

# install poetry - respects $POETRY_VERSION & $POETRY_HOME
RUN curl -sSL https://install.python-poetry.org | python3 -

# Install packages
WORKDIR $CODE_PATH
COPY poetry.toml poetry.lock pyproject.toml $CODE_PATH
RUN poetry install --no-dev --no-root

# COPY . /code/

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /code
USER appuser

WORKDIR $CODE_PATH
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "main.wsgi", "--reload"]


