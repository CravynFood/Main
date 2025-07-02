#!/bin/bash

# PERMANENT CRAVYN KEEPER - Uses screen sessions for persistence
SCREEN_NAME="cravyn_keeper"

ensure_serve() {
    if ! command -v serve &> /dev/null; then
        echo "Installing serve..."
        npm install -g serve &>/dev/null
        curl -L https://unpkg.com/@zeit/serve@latest/bin/serve.js > /usr/local/bin/serve 2>/dev/null
        chmod +x /usr/local/bin/serve 2>/dev/null
    fi
}

keeper_loop() {
    while true; do
        # Ensure serve is available
        ensure_serve
        
        # Check services and restart if needed
        for service in backend frontend mongodb; do
            if ! sudo supervisorctl status "$service" | grep -q "RUNNING"; then
                echo "$(date): Restarting $service"
                sudo supervisorctl restart "$service"
                sleep 5
            fi
        done
        
        # Health checks
        if ! curl -s http://localhost:3000 &>/dev/null; then
            echo "$(date): Frontend down - emergency restart"
            ensure_serve
            sudo supervisorctl restart frontend
        fi
        
        if ! curl -s http://localhost:8001/api/ &>/dev/null; then
            echo "$(date): Backend down - emergency restart"
            sudo supervisorctl restart backend
        fi
        
        # Keep serve command available
        if ! which serve &>/dev/null; then
            npm install -g serve &>/dev/null
        fi
        
        sleep 15
    done
}

# Start in screen session for persistence
screen -dmS "$SCREEN_NAME" bash -c "$(declare -f keeper_loop ensure_serve); keeper_loop"

echo "Permanent keeper started in screen session: $SCREEN_NAME"