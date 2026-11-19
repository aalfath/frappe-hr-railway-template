# Changelog

## v16.60.0 (2026-11-19)

First release of the template.

- Frappe HR v16.60.0 on ERPNext v16.60.0 and Frappe v16.60.2, built on the official image `frappe/erpnext:v16.60.0@sha256:3847babae025dae001e638b7fc5503c944fd968216b3074e60edfcc240fb2db6` with HRMS installed from its `v16.60.0` tag.
- Six services: Frappe HR (nginx + gunicorn + workers), Websocket (socket.io), Scheduler, MariaDB 11.8.9, Redis-Cache and Redis-Queue 8.2.6.
- The Frappe HR service refuses to create a new site over a database that already holds one when the `sites` volume has no folder for the site, so a lost volume never drops HR data.
