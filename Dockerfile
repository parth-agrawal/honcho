# https://pythonspeed.com/articles/base-image-python-docker-images/
# https://testdriven.io/blog/docker-best-practices/
FROM python:3.11-slim-bullseye

RUN apt-get update && apt-get install -y build-essential

WORKDIR /app

# https://stackoverflow.com/questions/53835198/integrating-python-poetry-with-docker
ENV PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  POETRY_VERSION=1.8.3

RUN pip install "poetry==$POETRY_VERSION"

# Copy only requirements to cache them in docker layer
WORKDIR /app
COPY poetry.lock pyproject.toml /app/

# Project initialization:
RUN poetry config virtualenvs.create false \
  && poetry install --no-root --no-interaction --no-ansi

WORKDIR /app

RUN addgroup --system app && adduser --system --group app
RUN chown -R app:app /app
USER app

COPY --chown=app:app src/ /app/src/

EXPOSE 8000

# https://stackoverflow.com/questions/29663459/python-app-does-not-print-anything-when-running-detached-in-docker
CMD ["fastapi", "run", "src/main.py"]

