docker rm -f pg-pgfsm-ext
docker build \
       --build-arg HOST_UID="$(id -u)" \
       --build-arg HOST_GID="$(id -g)" \
       -t pg-pgfsm-ext . \
&& docker run -d \
          --name pg-pgfsm-ext \
          -e POSTGRES_PASSWORD=pass123 \
          -v "$PWD":/usr/src/pgfsm \
          pg-pgfsm-ext \
&& docker exec -u "$(id -u):$(id -g)" pg-pgfsm-ext bash -c "\
        until pg_isready -U postgres; do sleep 3; done; \
        cd /usr/src/pgfsm; \
        PGUSER=postgres make installcheck; \
        PGUSER=postgres make doctest; \
        mkdocs build; \
  " \
docker rm -f pg-pgfsm-ext
