For a one-shot container run from host cron or a systemd timer, chain on the host:

    docker run --rm myimage /app/backup && curl -fsS -m 10 --retry 3 -o /dev/null "$PING"

`docker run` returns the container's exit code, so `&&` behaves as expected.
