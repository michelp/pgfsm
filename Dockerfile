FROM postgres:17

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      mkdocs \
      build-essential \
      postgresql-server-dev-17 \
 && rm -rf /var/lib/apt/lists/*

ARG HOST_UID
ARG HOST_GID
RUN groupadd -g $HOST_GID hostgroup \
 && useradd -u $HOST_UID -g hostgroup hostuser

USER hostuser
COPY . /usr/src/demo

USER root
WORKDIR /usr/src/demo
RUN make install

USER postgres
WORKDIR /
