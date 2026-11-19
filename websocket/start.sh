#!/bin/bash
# Frappe HR realtime (socket.io) service for Railway.
# It needs only the shared bench config: Redis for events, and the Frappe HR service's private
# address so it can check each browser session against the backend.
set -euo pipefail
cd /home/frappe/frappe-bench
: "${REDIS_QUEUE_URL:?REDIS_QUEUE_URL is required}"
: "${FRAPPE_HR_HOST:?FRAPPE_HR_HOST is required (private domain of the Frappe HR service)}"
# Its own variable, not PORT, so a PORT injected by the platform never moves it.
export SOCKETIO_PORT="${SOCKETIO_PORT:-9000}"
env/bin/python - <<'PY'
import json, os
json.dump({
    "redis_queue": os.environ["REDIS_QUEUE_URL"],
    "redis_socketio": os.environ["REDIS_QUEUE_URL"],
    "redis_cache": os.environ.get("REDIS_CACHE_URL", os.environ["REDIS_QUEUE_URL"]),
    "socketio_port": int(os.environ["SOCKETIO_PORT"]),
    # Session checks go to the Frappe HR service's nginx, which adds the site name header.
    "webserver_host": os.environ["FRAPPE_HR_HOST"],
    "webserver_port": int(os.environ.get("FRAPPE_HR_PORT", "8080")),
}, open("sites/common_site_config.json", "w"), indent=1)
PY
echo "[frappe-hr-railway] starting socket.io on port $SOCKETIO_PORT"
exec node apps/frappe/socketio.js
