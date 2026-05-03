#!/bin/bash
# docker-entrypoint.sh
# Runs at container startup:
#   1. Generates SSH host keys if missing (e.g. fresh volume)
#   2. Creates student users from the mounted CSV
#   3. Starts the SSH daemon in the foreground

set -e

# Generate host keys if they don't exist (needed on first run with a fresh volume)
ssh-keygen -A

# Create student accounts from the mounted CSV
CSV="/opt/setup/students.csv"
if [ -f "$CSV" ]; then
    echo "[entrypoint] Creating student users from $CSV ..."
    bash /opt/setup/create_users.sh "$CSV"
else
    echo "[entrypoint] WARNING: No students.csv found at $CSV"
    echo "[entrypoint]   Mount your CSV via compose.yaml, or with:"
    echo "[entrypoint]   docker run -v ./setup/students.csv:/opt/setup/students.csv:ro ..."
    echo "[entrypoint] Starting SSH anyway — you can exec in and run create_users.sh manually."
fi

echo "[entrypoint] SSH server starting on port 22..."
exec /usr/sbin/sshd -D
