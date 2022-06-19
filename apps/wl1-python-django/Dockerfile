# syntax=docker/dockerfile:1

FROM python:3.10.5-bullseye as base

# Setup env
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# MSSQL ODBC
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql18
RUN ACCEPT_EULA=Y apt-get install -y mssql-tools18
RUN echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
RUN . ~/.bashrc
RUN apt-get install -y g++
RUN apt-get install -y unixodbc-dev
RUN apt-get install -y libgssapi-krb5-2


FROM base AS python-deps

RUN pip install --upgrade pip
RUN pip install poetry
COPY pyproject.toml .
COPY poetry.lock .
COPY poetry.toml .

RUN poetry install --no-dev
RUN poetry add gunicorn


FROM base AS runtime

# Copy virtual env from python-deps stage
SHELL ["/bin/bash", "-c"] 
COPY --from=python-deps /.venv /.venv
ENV PATH="/.venv/bin:$PATH"

# Create and switch to a new user
RUN useradd --create-home appuser
WORKDIR /home/appuser
USER appuser

ENV ALLOWED_HOSTS="*"

# Install application into container
COPY . .
ENTRYPOINT [ "/home/appuser/docker-entrypoint.sh" ]
