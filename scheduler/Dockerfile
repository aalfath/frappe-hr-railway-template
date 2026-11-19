# Frappe HR scheduler: `bench schedule` puts due jobs (attendance, leave allocation, payroll
# reminders, daily work summaries) on the Redis queue; the workers in the Frappe HR service run
# them. Stateless. Needs the HRMS Python app for its hooks, not its web assets.
FROM frappe/erpnext:v16.60.0@sha256:3847babae025dae001e638b7fc5503c944fd968216b3074e60edfcc240fb2db6

ARG HRMS_REF=v16.60.0
USER frappe
WORKDIR /home/frappe/frappe-bench
RUN bench get-app --skip-assets --branch "$HRMS_REF" https://github.com/frappe/hrms \
 && rm -rf apps/hrms/.git apps/hrms/node_modules apps/hrms/frontend/node_modules apps/hrms/roster/node_modules \
 && env/bin/python -c "import hrms; print('hrms', hrms.__version__)"

COPY --chmod=755 start.sh /usr/local/bin/railway-start.sh
ENV SITE_NAME=hr.local \
    DB_NAME=frappe_hr \
    DB_PORT=3306
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD []
