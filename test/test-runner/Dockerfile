FROM python:3.8.3

WORKDIR /src

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl \
      openssl \
 && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml .

RUN pip3 install pip==20.2.4
RUN pip3 install poetry==1.1.3
RUN poetry config virtualenvs.create false
RUN poetry install

# CMD [ "poetry", "run", "pytest" ]
