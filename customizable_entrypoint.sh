#!/bin/bash
set -e
echo '[INFO] Chromedriver-Watchdog gestartet'
CHROMEDRIVER_PATH=/chromedriver-linux64/chromedriver
CHROMEDRIVER_PORT=9515
while true; do
    if [ -x "$CHROMEDRIVER_PATH" ]; then
        "$CHROMEDRIVER_PATH" --port=$CHROMEDRIVER_PORT --verbose &
        PID=$!
        wait $PID
        echo '[WARN] Chromedriver beendet (Exit:$?). Neustart in 3s...'
        sleep 3
    else
        echo '[ERROR] Chromedriver nicht gefunden'
        sleep 3
    fi
done &
sleep 2
echo 'Ready to start'
echo 'Customization disabled - base entrypoint running'
exec /usr/local/bin/base_entrypoint.sh 2>/dev/null || echo 'Base entrypoint nicht gefunden, Container beendet.'
