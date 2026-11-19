[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/frappe-hr-1?utm_medium=integration&utm_source=button&utm_campaign=frappe-hr)

# Frappe HR on Railway

One-click [Frappe HR](https://frappe.io/hr) (open-source HR and payroll software, the `hrms` app on ERPNext) on Railway, as the full multi-service stack that upstream's [frappe_docker](https://github.com/frappe/frappe_docker) runs.

**Version:** Frappe HR **v16.60.0** on ERPNext **v16.60.0** and Frappe **v16.60.2**. The app services build `FROM frappe/erpnext:v16.60.0@sha256:3847babae025dae001e638b7fc5503c944fd968216b3074e60edfcc240fb2db6` (official image) and install HRMS from its `v16.60.0` release tag. Upstream's `ghcr.io/frappe/hrms:v16.x` images are not used: they are built from HRMS's `version-15` branch and contain HRMS 15.x.

## Services

| Service | Built from | What it does | Volume |
|---|---|---|---|
| **Frappe HR** (public) | `frappe-hr/` | nginx on `PORT`, gunicorn (Frappe backend) and the background workers. Creates the site with ERPNext and Frappe HR on first start, runs `bench migrate` after an update | `/home/frappe/frappe-bench/sites` (site config, attachments, backups) |
| **Websocket** | `websocket/` | Frappe's socket.io server for live updates; nginx forwards `/socket.io` to it over the private network | none |
| **Scheduler** | `scheduler/` | `bench schedule`: puts due jobs (attendance, leave allocation, payroll and HR reminders) on the queue | none |
| **MariaDB** | `mariadb:11.8.9` (pinned digest) | Database | `/var/lib/mysql` |
| **Redis-Cache** | `redis:8.2.6` (pinned digest) | Cache, in memory only (LRU, 256 MB) | none |
| **Redis-Queue** | `redis:8.2.6` (pinned digest) | Job queue and realtime events (append-only file) | `/data` |

The background workers run inside the Frappe HR service because they write attachments, salary slips and backups into the `sites` folder, and a Railway volume attaches to one service only. Raise `BACKGROUND_WORKERS` on the Frappe HR service for more worker processes.

## Variables

All are filled in by the template; the deploy form asks for nothing.

- `ADMIN_PASSWORD` (Frappe HR): generated password of the `Administrator` user. Read it in the Frappe HR service's Variables tab. It is used once, when the site is created; change the password in Frappe HR afterwards.
- `DB_PASSWORD` (Frappe HR, referenced by Scheduler): generated password of the site's own MariaDB user.
- `MARIADB_ROOT_PASSWORD` (MariaDB) and `REDIS_PASSWORD` (both Redis services): generated.
- References wire the rest: `DB_HOST`, `DB_ROOT_PASSWORD`, `REDIS_CACHE_URL`, `REDIS_QUEUE_URL`, `SOCKETIO_UPSTREAM`, `FRAPPE_HR_HOST`.
- Optional, not set by default: `GUNICORN_WORKERS` (2), `GUNICORN_THREADS` (4), `BACKGROUND_WORKERS` (1), `CLIENT_MAX_BODY_SIZE` (`50m`).

## After deploy

1. Wait for the Frappe HR service to finish its first start (about 5 to 8 minutes; a "Frappe HR is starting" page shows meanwhile).
2. Open the public URL, sign in as `Administrator` with `ADMIN_PASSWORD`, and complete the setup wizard (company, country, currency, fiscal year).
3. Change the Administrator password, add your employees, and point them to the self-service app at `/hrms`.
4. Add an email account in the desk if you want leave approvals, salary slips and reminders sent by email. SMTP is not included.

## Updates

Every service builds from this repo. When a new Frappe HR release comes out, we bump the pinned base image and the HRMS tag in the Dockerfiles on `main` and note it in [CHANGELOG.md](CHANGELOG.md); Railway then shows "update available" on your project. Read the changelog, back up first (MariaDB plus the Frappe HR `sites` volume), then apply the update. The Frappe HR service runs `bench migrate` by itself when the app versions change, and serves the holding page while it runs.

If the `sites` volume is ever lost while the database still holds a site, the service refuses to create a new site over it and says so in its logs, so your HR data is never dropped by accident.

## Layout

- `frappe-hr/`: `Dockerfile`, `start.sh` (volume ownership, bench config from variables, site creation or migrate, process supervisor), `nginx.conf.template`.
- `websocket/`: `Dockerfile`, `start.sh`.
- `scheduler/`: `Dockerfile`, `start.sh` (waits until the site's database exists).
- `compose.test.yml`: local test of the same layout (not used by Railway).

Licence of this wrapper: MIT. Frappe HR itself is GPL-3.0.
