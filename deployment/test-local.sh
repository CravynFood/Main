#!/bin/bash

# Test deployment locally before pushing to Google Cloud
echo "🧪 Testing Cravyn deployment locally..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check environment variables
if [ -z "$GEMINI_API_KEY" ] || [ -z "$MONGO_URL" ]; then
    echo "❌ Please set environment variables first:"
    echo "source .env"
    exit 1
fi

# Build images
echo "🏗️ Building Docker images..."
docker build -t cravyn-backend:test backend/
docker build -t cravyn-frontend:test frontend/

# Create test network
docker network create cravyn-test || true

# Run MongoDB for testing
echo "🗄️ Starting test MongoDB..."
docker run -d --name cravyn-mongo-test --network cravyn-test -p 27017:27017 mongo:7

# Wait for MongoDB
sleep 5

# Run backend
echo "🔌 Starting backend..."
docker run -d --name cravyn-backend-test --network cravyn-test \
    -p 8001:8001 \
    -e MONGO_URL="mongodb://cravyn-mongo-test:27017" \
    -e DB_NAME="cravyn_test" \
    -e GEMINI_API_KEY="$GEMINI_API_KEY" \
    cravyn-backend:test

# Wait for backend
sleep 10

# Run frontend
echo "🌐 Starting frontend..."
docker run -d --name cravyn-frontend-test --network cravyn-test \
    -p 3000:3000 \
    -e REACT_APP_BACKEND_URL="http://localhost:8001" \
    cravyn-frontend:test

# Wait for frontend
sleep 5

# Test endpoints
echo "🧪 Testing endpoints..."
echo "Backend health check:"
curl -f http://localhost:8001/api/ || echo "❌ Backend failed"

echo "Frontend health check:"
curl -f http://localhost:3000/ || echo "❌ Frontend failed"

echo "✅ Local test complete!"
echo "🌐 Frontend: http://localhost:3000"
echo "🔌 Backend: http://localhost:8001"
echo ""
echo "🧹 To cleanup:"
echo "docker stop cravyn-backend-test cravyn-frontend-test cravyn-mongo-test"
echo "docker rm cravyn-backend-test cravyn-frontend-test cravyn-mongo-test"
echo "docker network rm cravyn-test"