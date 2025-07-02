#!/bin/bash

# Ultimate Backup Guardian - Spawns multiple immortal processes
LOG="/var/log/backup_guardian.log"

spawn_guardian() {
    echo "$(date): Spawning immortal guardian #$1" >> "$LOG"
    nohup /app/immortal_guardian.sh > "/var/log/guardian_$1.log" 2>&1 &
}

# Spawn multiple guardians for redundancy
for i in {1..3}; do
    spawn_guardian $i
    sleep 2
done

# Monitor guardians and respawn if needed
while true; do
    guardian_count=$(ps aux | grep immortal_guardian | grep -v grep | wc -l)
    
    if [[ $guardian_count -lt 2 ]]; then
        echo "$(date): Only $guardian_count guardians alive - spawning more" >> "$LOG"
        spawn_guardian "$(date +%s)"
    fi
    
    sleep 60
done