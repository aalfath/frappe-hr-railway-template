# Frappe HR realtime service: Frappe's socket.io server (node apps/frappe/socketio.js).
# Stateless; reached only by the Frappe HR service's nginx over Railway's private network.
# The socket.io server is part of the Frappe framework, so it needs no HRMS code.
FROM frappe/erpnext:v16.60.0@sha256:3847babae025dae001e638b7fc5503c944fd968216b3074e60edfcc240fb2db6

COPY --chmod=755 start.sh /usr/local/bin/railway-start.sh
ENV SOCKETIO_PORT=9000 \
    FRAPPE_HR_PORT=8080
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD []
