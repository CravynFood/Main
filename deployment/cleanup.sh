#!/bin/bash

# Cleanup script to remove test containers and resources
echo "🧹 Cleaning up test resources..."

# Stop and remove containers
echo "🛑 Stopping containers..."
docker stop cravyn-backend-test cravyn-frontend-test cravyn-mongo-test 2>/dev/null || true
docker rm cravyn-backend-test cravyn-frontend-test cravyn-mongo-test 2>/dev/null || true

# Remove test images
echo "🗑️ Removing test images..."
docker rmi cravyn-backend:test cravyn-frontend:test 2>/dev/null || true

# Remove test network
echo "🌐 Removing test network..."
docker network rm cravyn-test 2>/dev/null || true

# Clean up unused Docker resources
echo "🧽 Cleaning up unused Docker resources..."
docker system prune -f

echo "✅ Cleanup complete!"