#!/bin/bash

# Cravyn 24-Hour Monitoring Script
LOG_FILE="/var/log/cravyn_monitor.log"
BACKEND_URL="http://localhost:8001/api/"
FRONTEND_URL="http://localhost:3000"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

check_service() {
    local service_name="$1"
    local url="$2"
    
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    
    if [ "$status_code" = "200" ]; then
        log_message "✅ $service_name: HEALTHY (Status: $status_code)"
        return 0
    else
        log_message "❌ $service_name: UNHEALTHY (Status: $status_code)"
        return 1
    fi
}

restart_if_needed() {
    local service="$1"
    log_message "🔄 Restarting $service..."
    sudo supervisorctl restart "$service"
    sleep 5
}

# Main monitoring function
monitor_cravyn() {
    log_message "🚀 Starting Cravyn 24-hour monitoring..."
    
    while true; do
        # Check supervisor services
        supervisor_status=$(sudo supervisorctl status | grep -E "(backend|frontend|mongodb)" | grep -c "RUNNING")
        
        if [ "$supervisor_status" -eq 3 ]; then
            log_message "📊 All supervisor services running (3/3)"
        else
            log_message "⚠️ Some supervisor services down ($supervisor_status/3)"
            sudo supervisorctl restart all
            sleep 10
        fi
        
        # Check service health
        if ! check_service "Backend" "$BACKEND_URL"; then
            restart_if_needed "backend"
        fi
        
        if ! check_service "Frontend" "$FRONTEND_URL"; then
            restart_if_needed "frontend"
        fi
        
        # Test AI functionality every hour
        current_minute=$(date +%M)
        if [ "$current_minute" = "00" ]; then
            log_message "🧪 Hourly AI functionality test..."
            python3 -c "
import requests
try:
    response = requests.post('$BACKEND_URL/recipes/generate', 
        json={'ingredients': ['test'], 'cuisine': 'Any'}, timeout=30)
    if response.status_code == 200:
        print('✅ AI Recipe Generation: WORKING')
    else:
        print('❌ AI Recipe Generation: FAILED')
except Exception as e:
    print(f'❌ AI Test Error: {e}')
" >> "$LOG_FILE" 2>&1
        fi
        
        # Monitor every 2 minutes
        sleep 120
    done
}

# Start monitoring
log_message "🎯 Cravyn 24-Hour Uptime Monitoring Started"
log_message "📅 Start Time: $(date)"
log_message "⏰ Will monitor until: $(date -d '+24 hours')"

monitor_cravyn