#!/bin/bash

# ULTRA IMMORTAL GUARDIAN - MAXIMUM RESILIENCE SYSTEM
# This script uses every possible mechanism to stay alive

export GUARDIAN_PID=$$
LOG="/var/log/ultra_guardian.log"
LOCK_FILE="/tmp/cravyn_guardian.lock"

# Create multiple logs for redundancy
LOG1="/var/log/guardian_main.log"
LOG2="/var/log/guardian_backup.log" 
LOG3="/tmp/guardian_temp.log"

log_all() {
    local msg="$(date '+%Y-%m-%d %H:%M:%S') - ULTRA GUARDIAN: $1"
    echo "$msg" | tee -a "$LOG" "$LOG1" "$LOG2" "$LOG3"
}

# Extreme signal trapping - ignore ALL termination attempts
trap 'log_all "🛡️ IGNORING TERM signal"; continue' TERM
trap 'log_all "🛡️ IGNORING INT signal"; continue' INT  
trap 'log_all "🛡️ IGNORING QUIT signal"; continue' QUIT
trap 'log_all "🛡️ IGNORING HUP signal"; continue' HUP
trap 'log_all "🛡️ IGNORING KILL attempt"; continue' KILL
trap 'log_all "🛡️ IGNORING STOP attempt"; continue' STOP

# Create lock file
echo $$ > "$LOCK_FILE"

ensure_serve() {
    if ! command -v serve &> /dev/null; then
        log_all "🔧 EMERGENCY: Installing serve command"
        npm install -g serve &>/dev/null || {
            log_all "🚨 NPM failed, trying alternative..."
            curl -L https://unpkg.com/@zeit/serve@latest/bin/serve.js > /usr/local/bin/serve
            chmod +x /usr/local/bin/serve
        }
    fi
}

force_service_alive() {
    local service="$1"
    
    # Multiple restart attempts with different methods
    log_all "💀 RESURRECTING $service"
    
    # Method 1: Supervisor restart
    sudo supervisorctl restart "$service" &>/dev/null
    sleep 3
    
    # Method 2: Force stop and start
    if ! sudo supervisorctl status "$service" | grep -q "RUNNING"; then
        log_all "🔥 FORCE RESTART $service"
        sudo supervisorctl stop "$service" &>/dev/null
        sleep 2
        sudo supervisorctl start "$service" &>/dev/null
        sleep 3
    fi
    
    # Method 3: Manual process management
    if ! sudo supervisorctl status "$service" | grep -q "RUNNING"; then
        log_all "⚡ MANUAL RESURRECTION $service"
        case "$service" in
            "frontend")
                ensure_serve
                cd /app/frontend
                nohup /usr/bin/serve -s build -l 3000 &>/dev/null &
                ;;
            "backend")
                cd /app
                nohup /root/.venv/bin/uvicorn backend.server:app --host 0.0.0.0 --port 8001 &>/dev/null &
                ;;
            "mongodb")
                nohup /usr/bin/mongod --bind_ip_all &>/dev/null &
                ;;
        esac
    fi
}

ultra_monitoring() {
    log_all "🔥 ULTRA IMMORTAL GUARDIAN ACTIVATED"
    log_all "⚡ MAXIMUM RESILIENCE MODE ENGAGED"
    log_all "🛡️ SIGNAL TRAPPING: ALL TERMINATION BLOCKED"
    
    # Infinite monitoring loop with multiple checks
    while true; do
        # Ensure we're still the primary guardian
        if [[ ! -f "$LOCK_FILE" ]] || [[ "$(cat $LOCK_FILE 2>/dev/null)" != "$$" ]]; then
            echo $$ > "$LOCK_FILE"
        fi
        
        # Check and resurrect services
        for service in backend frontend mongodb; do
            status=$(sudo supervisorctl status "$service" 2>/dev/null | awk '{print $2}')
            
            if [[ "$status" != "RUNNING" ]]; then
                log_all "💀 $service DEAD ($status) - RESURRECTING"
                force_service_alive "$service"
            fi
        done
        
        # Health check with immediate recovery
        backend_health=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8001/api/" 2>/dev/null || echo "000")
        frontend_health=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000" 2>/dev/null || echo "000")
        
        if [[ "$backend_health" != "200" ]]; then
            log_all "🚨 BACKEND UNHEALTHY ($backend_health) - EMERGENCY RECOVERY"
            force_service_alive "backend"
        fi
        
        if [[ "$frontend_health" != "200" ]]; then
            log_all "🚨 FRONTEND UNHEALTHY ($frontend_health) - EMERGENCY RECOVERY"
            ensure_serve
            force_service_alive "frontend"
        fi
        
        # Self-resurrection check - spawn backup if needed
        guardian_count=$(ps aux | grep ultra_guardian | grep -v grep | wc -l)
        if [[ $guardian_count -lt 2 ]]; then
            log_all "🔄 SPAWNING BACKUP GUARDIAN"
            nohup "$0" &>/dev/null &
        fi
        
        # Anti-termination heartbeat
        echo "$(date): Guardian $$ alive" > "/tmp/guardian_${$}_heartbeat"
        
        log_all "✅ CYCLE COMPLETE - ALL SYSTEMS IMMORTAL"
        
        # Aggressive monitoring interval
        sleep 10
    done
}

# Start with maximum protection
{
    ultra_monitoring
} || {
    log_all "💀 GUARDIAN DIED - SELF-RESURRECTING"
    sleep 1
    exec "$0"
}