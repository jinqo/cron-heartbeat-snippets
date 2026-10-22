# cron-heartbeat-snippets

Copy-paste patterns for making scheduled jobs report when they fail or stop running, using an HTTP heartbeat (also called a dead man's switch). The job requests a URL when it succeeds; a monitoring service alerts you if the request does not arrive on time.

The snippets are service-agnostic. Replace `https://example.invalid/ping/ID` with the ping URL from whichever service you use.

**Disclosure:** I maintain [Cronbell](https://cronbell.wavez.lol/?src=gh), a small hosted heartbeat monitor that needs no signup. It is one option among several and nothing here depends on it. Alternatives: [Healthchecks.io](https://healthchecks.io) (open source, self-hostable, free tier), [Cronitor](https://cronitor.io), and push monitors in [Uptime Kuma](https://github.com/louislam/uptime-kuma).

## Why not `MAILTO`

- It sends mail only when the job prints output, and needs a working mail transfer agent.
- It says nothing if the job never ran (crond stopped, host down, crontab replaced).
- A heartbeat alerts on the absence of a check-in, which covers all three.

## Use `&&`, not `;`

```cron
# Wrong: pings even when backup.sh failed
0 3 * * * /usr/local/bin/backup.sh ; curl -fsS "$PING"
# Right: pings only on success
0 3 * * * /usr/local/bin/backup.sh && curl -fsS -m 10 --retry 3 "$PING"
```

Do not send all output to `/dev/null`; you lose the error message you need afterwards.

## Examples

| File | What it shows |
|---|---|
| [examples/crontab.example](examples/crontab.example) | Plain crontab line |
| [examples/wrapper.sh](examples/wrapper.sh) | Wrapper that sends `/start`, then success or `/fail`, keeping the exit code |
| [examples/backup.service](examples/backup.service), [backup.timer](examples/backup.timer) | systemd: `ExecStartPost` runs only if `ExecStart` succeeded |
| [examples/k8s-cronjob.yaml](examples/k8s-cronjob.yaml) | Kubernetes CronJob with `timeZone` |
| [examples/restic.sh](examples/restic.sh), [borg.sh](examples/borg.sh) | Ping after backup and prune succeed (`set -e`) |
| [examples/docker-compose-note.md](examples/docker-compose-note.md) | Chaining after `docker run` |

Laravel scheduler:

```php
Schedule::command('reports:send')->daily()->thenPing('https://example.invalid/ping/ID');
```

`/start` and `/fail` suffixes exist in Healthchecks.io and Cronbell; check your service's docs for the exact form.

## Pitfalls

- Set the grace period longer than the job's normal runtime, or you will get false alerts and learn to ignore them.
- Timezones: `30 2 * * *` does not exist on the spring DST change in many zones and occurs twice in autumn. Use a service that evaluates the schedule in your timezone, or schedule at a time that is never skipped.
- A ping URL works as a capability: anyone who has it can fake a check-in. Keep it out of public repos and logs.
- Add `-m 10` and `--retry` to `curl` so a network blip does not hang or fail the job.

## Contributing

Pull requests that add a correct, tested snippet for another scheduler or tool are welcome. Keep snippets service-agnostic.

## License

MIT, see [LICENSE](LICENSE).
