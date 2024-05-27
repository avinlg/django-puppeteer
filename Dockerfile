# syntax=docker/dockerfile:1

# FROM node:20-slim as node-base
# WORKDIR /code
# COPY package*.json /code/
# RUN npm install

# FROM node-base as node-build
# COPY node-src tsconfig.json /code/
# RUN npm run build

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
        build-essential \
        nodejs \
        npm

COPY . /code/

# install poetry - respects $POETRY_VERSION & $POETRY_HOME
RUN curl -sSL https://install.python-poetry.org | python3 -

FROM builder-base as run-server
# Install packages
WORKDIR $CODE_PATH
# COPY poetry.toml poetry.lock pyproject.toml $CODE_PATH
RUN poetry install --no-dev --no-root

# WORKDIR $CODE_PATH
# COPY package*.json /code/
RUN npm install

# WORKDIR $CODE_PATH
# COPY ./node-src /code/
# COPY tsconfig.json /code/
RUN npm run build && ls -ls && pwd
# COPY node-build node_modules /code/

# COPY . /code/

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /code
USER appuser
WORKDIR $CODE_PATH
RUN ls -l && pwd
# COPY $CODE_PATH/node_modules $CODE_PATH/node-src $CODE_PATH/node-build $CODE_PATH/
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "main.wsgi", "--reload"]