#!/bin/bash
# SqueezeOS Watchdog & Health Check
# Ensures llama-server is running and responsive. If down, restarts and logs.

PORT=8080
HEALTH_URL="http://localhost:$PORT/health"
LOG_FILE="$HOME/.config/squeezeos/watchdog.log"
RUN_SCRIPT="$HOME/.squeezeos/run-squeezeos.sh"

mkdir -p "$(dirname "$LOG_FILE")"

timestamp() {
    date -u +"%Y-%m-%d %H:%M:%S UTC"
}

if curl -s -f --max-time 5 "$HEALTH_URL" > /dev/null 2>&1; then
    echo "[$(timestamp)] STATUS: HEALTHY (HTTP 200)" >> "$LOG_FILE"
else
    echo "[$(timestamp)] WARNING: llama-server unresponsive or down! Attempting restart..." >> "$LOG_FILE"
    pkill -f "llama-server" || true
    sleep 2
    if [ -f "$RUN_SCRIPT" ]; then
        nohup "$RUN_SCRIPT" > /dev/null 2>&1 &
        echo "[$(timestamp)] ACTION: Restarted llama-server via $RUN_SCRIPT" >> "$LOG_FILE"
    else
        echo "[$(timestamp)] ERROR: Run script not found at $RUN_SCRIPT" >> "$LOG_FILE"
    fi
fi
