#!/bin/bash

# Cravyn Immortal Guardian - Never-Die Monitoring System
# This script ensures Cravyn stays alive FOREVER

LOG_FILE="/var/log/cravyn_immortal.log"
BACKEND_URL="http://localhost:8001/api/"
FRONTEND_URL="http://localhost:3000"
RESTART_COUNT=0

# Trap signals to prevent termination
trap 'log_message "🛡️ IMMORTAL GUARDIAN: Ignoring termination signal"' TERM INT QUIT

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

force_restart_service() {
    local service="$1"
    log_message "💀 FORCE RESTARTING $service (attempt $((++RESTART_COUNT)))"
    
    # Kill any existing processes
    sudo pkill -f "$service" 2>/dev/null || true
    sleep 2
    
    # Restart via supervisor
    sudo supervisorctl restart "$service"
    sleep 5
    
    # If still failing, nuclear option
    if ! sudo supervisorctl status "$service" | grep -q "RUNNING"; then
        log_message "🚨 NUCLEAR RESTART for $service"
        sudo supervisorctl stop "$service"
        sleep 3
        sudo supervisorctl start "$service"
        sleep 5
    fi
}

ensure_serve_available() {
    if ! command -v serve &> /dev/null; then
        log_message "🔧 Installing serve command..."
        npm install -g serve
    fi
}

immortal_monitoring() {
    log_message "🛡️ CRAVYN IMMORTAL GUARDIAN ACTIVATED"
    log_message "⚡ NEVER-DIE MODE: ENGAGED"
    log_message "🎯 TARGET: INFINITE UPTIME"
    
    # Infinite loop - NEVER TERMINATE
    while true; do
        # Ensure serve is available
        ensure_serve_available
        
        # Check and restart all services
        for service in backend frontend mongodb; do
            status=$(sudo supervisorctl status "$service" 2>/dev/null | awk '{print $2}')
            
            if [[ "$status" != "RUNNING" ]]; then
                log_message "❌ $service is $status - FORCING RESTART"
                force_restart_service "$service"
            else
                log_message "✅ $service: IMMORTAL (Status: $status)"
            fi
        done
        
        # Health check with aggressive recovery
        backend_status=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL" 2>/dev/null || echo "000")
        frontend_status=$(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL" 2>/dev/null || echo "000")
        
        if [[ "$backend_status" != "200" ]]; then
            log_message "🚨 Backend unhealthy ($backend_status) - EMERGENCY RESTART"
            force_restart_service "backend"
        fi
        
        if [[ "$frontend_status" != "200" ]]; then
            log_message "🚨 Frontend unhealthy ($frontend_status) - EMERGENCY RESTART"
            force_restart_service "frontend"
        fi
        
        # AI functionality test every 10 minutes
        minute=$(date +%M)
        if [[ "$minute" == "00" ]] || [[ "$minute" == "10" ]] || [[ "$minute" == "20" ]] || [[ "$minute" == "30" ]] || [[ "$minute" == "40" ]] || [[ "$minute" == "50" ]]; then
            log_message "🧪 AI IMMORTALITY TEST..."
            python3 -c "
import requests, sys
try:
    response = requests.post('$BACKEND_URL/recipes/generate', 
        json={'ingredients': ['immortal', 'test'], 'cuisine': 'Any'}, timeout=15)
    if response.status_code == 200:
        print('✅ AI: IMMORTAL')
    else:
        print('❌ AI: MORTAL - Status:', response.status_code)
        sys.exit(1)
except Exception as e:
    print('💀 AI: DEAD -', str(e))
    sys.exit(1)
" >> "$LOG_FILE" 2>&1
            
            if [[ $? -ne 0 ]]; then
                log_message "💀 AI DEAD - RESURRECTING BACKEND"
                force_restart_service "backend"
            fi
        fi
        
        # System resource check
        memory_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
        disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
        
        log_message "📊 IMMORTAL STATS: Memory: ${memory_usage}%, Disk: ${disk_usage}%, Restarts: $RESTART_COUNT"
        
        # Anti-sleep mechanism - random activity every cycle
        echo "$(date): Immortal guardian heartbeat" > /tmp/cravyn_heartbeat
        
        # Adaptive sleep - more frequent checks if issues detected
        if [[ "$backend_status" == "200" ]] && [[ "$frontend_status" == "200" ]]; then
            sleep 30  # Normal mode: check every 30 seconds
        else
            sleep 5   # Emergency mode: check every 5 seconds
        fi
    done
}

# Self-resurrection mechanism
resurrect_self() {
    log_message "💀 GUARDIAN DIED - SELF-RESURRECTING..."
    nohup "$0" > /var/log/cravyn_resurrection.log 2>&1 &
    exit 0
}

# Start immortal monitoring with self-resurrection
(
    immortal_monitoring
) || resurrect_self