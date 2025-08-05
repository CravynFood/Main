#!/bin/sh
set -e

# Substitute ${PORT} in nginx.conf with the Cloud Run port, write result to temp config
envsubst '$PORT' < /etc/nginx/nginx.conf > /etc/nginx/nginx.conf.rendered

# Start FastAPI backend on port 8001 (not PORT, this is internal)
cd /backend || { echo "Backend directory not found"; exit 1; }
echo "Starting FastAPI backend"
uvicorn server:app --host 0.0.0.0 --port 8001 &

BACKEND_PID=$!
echo "Waiting for backend to start..."
sleep 30

if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo "Backend failed to start at initialization, exiting"
    exit 1
fi

# Start Nginx with the dynamically rendered config
nginx -c /etc/nginx/nginx.conf.rendered -g 'daemon off;'

# Handle termination signals
trap 'kill $BACKEND_PID $NGINX_PID; exit 0' SIGTERM SIGINT

# Check if processes are still running
while kill -0 $BACKEND_PID 2>/dev/null && kill -0 $NGINX_PID 2>/dev/null; do
    sleep 1
done

# If we get here, one of the processes died
if kill -0 $BACKEND_PID 2>/dev/null; then
    echo "Nginx died, shutting down backend..."
    kill $BACKEND_PID
else
    echo "Backend died, shutting down nginx..."
    kill $NGINX_PID
fi

exit 1
