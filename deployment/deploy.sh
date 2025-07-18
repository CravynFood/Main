#!/bin/bash

# Cravyn Google Cloud Deployment Script
# Run this script after setting up your Google Cloud project

set -e

echo "🚀 Starting Cravyn deployment to Google Cloud..."

# Check if required variables are set
if [ -z "$PROJECT_ID" ] || [ -z "$GEMINI_API_KEY" ] || [ -z "$MONGO_URL" ]; then
    echo "❌ Please set required environment variables:"
    echo "export PROJECT_ID=your-project-id"
    echo "export GEMINI_API_KEY=your-gemini-api-key"
    echo "export MONGO_URL=your-mongodb-connection-string"
    exit 1
fi

# Set project
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "🔧 Enabling Google Cloud APIs..."
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable generativelanguage.googleapis.com

# Build and push backend image
echo "🏗️ Building backend image..."
gcloud builds submit ../backend --tag gcr.io/$PROJECT_ID/cravyn-backend

# Build and push frontend image
echo "🏗️ Building frontend image..."
gcloud builds submit ../frontend --tag gcr.io/$PROJECT_ID/cravyn-frontend

# Deploy backend to Cloud Run
echo "🚀 Deploying backend to Cloud Run..."
gcloud run deploy cravyn-backend \
    --image gcr.io/$PROJECT_ID/cravyn-backend \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --set-env-vars MONGO_URL="$MONGO_URL" \
    --set-env-vars DB_NAME="cravyn_db" \
    --set-env-vars GEMINI_API_KEY="$GEMINI_API_KEY" \
    --port 8001 \
    --memory 1Gi \
    --cpu 1 \
    --min-instances 1 \
    --max-instances 10 \
    --timeout 300

# Get backend URL
BACKEND_URL=$(gcloud run services describe cravyn-backend --platform managed --region us-central1 --format 'value(status.url)')

echo "✅ Backend deployed at: $BACKEND_URL"

# Deploy frontend to Cloud Run
echo "🚀 Deploying frontend to Cloud Run..."
gcloud run deploy cravyn-frontend \
    --image gcr.io/$PROJECT_ID/cravyn-frontend \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --set-env-vars REACT_APP_BACKEND_URL="$BACKEND_URL" \
    --port 3000 \
    --memory 512Mi \
    --cpu 1 \
    --min-instances 1 \
    --max-instances 5 \
    --timeout 300

# Get frontend URL
FRONTEND_URL=$(gcloud run services describe cravyn-frontend --platform managed --region us-central1 --format 'value(status.url)')

echo "✅ Frontend deployed at: $FRONTEND_URL"

# Test deployment
echo "🧪 Testing deployment..."
curl -f "$BACKEND_URL/api/" || echo "❌ Backend health check failed"
curl -f "$FRONTEND_URL/" || echo "❌ Frontend health check failed"

echo "🎉 Deployment complete!"
echo "📱 Frontend: $FRONTEND_URL"
echo "🔌 Backend: $BACKEND_URL"
echo "🍳 Your Cravyn app is now live on Google Cloud!"