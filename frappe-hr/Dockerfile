# Frappe HR web service: nginx (public PORT) + gunicorn + background workers.
# Owns the `sites` volume, creates the site on first start and migrates it after an update.
#
# Base: the official ERPNext image (Frappe v16.60.2 + ERPNext v16.60.0). Frappe HR requires
# ERPNext, and upstream's ghcr.io/frappe/hrms:v16.x tags are built from the version-15 branches
# (they contain HRMS 15.x), so the HRMS app is installed here from its v16 release tag.
FROM frappe/erpnext:v16.60.0@sha256:3847babae025dae001e638b7fc5503c944fd968216b3074e60edfcc240fb2db6

ARG HRMS_REF=v16.60.0
USER frappe
WORKDIR /home/frappe/frappe-bench
# The image keeps built assets in ./assets; link them so `bench get-app` builds HRMS's assets there.
RUN ln -s /home/frappe/frappe-bench/assets sites/assets \
 && bench get-app --branch "$HRMS_REF" https://github.com/frappe/hrms \
 && rm sites/assets \
 && rm -rf apps/hrms/.git apps/hrms/node_modules apps/hrms/frontend/node_modules apps/hrms/roster/node_modules \
 && test -f apps/hrms/hrms/www/hrms.html \
 && test -d assets/hrms \
 && grep -qx hrms sites/apps.txt \
 && env/bin/python -c "import hrms; print('hrms', hrms.__version__)"

USER root
# Keep a copy of the bench files that the volume hides (apps.txt, apps.json).
RUN cp -a /home/frappe/frappe-bench/sites /home/frappe/sites-image
COPY --chmod=755 start.sh /usr/local/bin/railway-start.sh
COPY nginx.conf.template /templates/nginx/railway.conf.template

ENV SITE_NAME=hr.local \
    DB_NAME=frappe_hr \
    DB_PORT=3306 \
    PORT=8080
# Starts as root only to fix the volume's ownership, then runs everything as `frappe`.
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD []
