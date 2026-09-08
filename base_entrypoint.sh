#!/usr/bin/env bash
set -e

# Add password to vnc options
if [ -n "${VNC_PASSWORD}" ]; then
    mkdir -p ~/.vnc
    echo "${VNC_PASSWORD}" | vncpasswd -f > ~/.vnc/passwd
    export VNC_OPTIONS="${VNC_OPTIONS} -SecurityTypes VncAuth -PasswordFile /root/.vnc/passwd"
else
    export VNC_OPTIONS="${VNC_OPTIONS} -SecurityTypes None"
fi

# Print current VNC info
echo "Current VNC info:"
echo "-----------------"
echo "VNC Screen: ${VNC_SCREEN}"
echo "VNC Display: ${VNC_DISPLAY}"
echo "VNC resolution: ${VNC_RESOLUTION}"
echo "VNC password: ${VNC_PASSWORD}"
echo "VNC Port: ${VNC_PORT}"
echo "NOVNC Websockify Port: ${NOVNC_WEBSOCKIFY_PORT}"

# Print other container's info
echo "-----------------"
echo "Other Info:"
echo "-----------------"
echo "Lang: ${LANG}"
echo "LC All: ${LC_ALL}"
echo "Customize active: ${CUSTOMIZE}"
echo "Custom entrypoints dir: ${CUSTOM_ENTRYPOINTS_DIR}"
echo "Autostart browser: ${AUTO_START_BROWSER}"
echo "Homepage website URL: ${STARTING_WEBSITE_URL}"
echo "Autostart xterm: ${AUTO_START_XTERM}"
echo "-----------------"

# Start Supervisor
exec supervisord -c /etc/supervisor.d/supervisord.conf
