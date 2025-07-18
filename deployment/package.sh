#!/bin/bash

# Copy Cravyn source code to deployment directory
# Run this script to prepare the deployment package

echo "📦 Preparing Cravyn deployment package..."

# Create deployment structure
mkdir -p deployment/backend deployment/frontend

# Copy backend files
echo "📋 Copying backend files..."
cp -r ../backend/* deployment/backend/
cp deployment/backend.Dockerfile deployment/backend/Dockerfile

# Copy frontend files  
echo "📋 Copying frontend files..."
cp -r ../frontend/* deployment/frontend/
cp deployment/frontend.Dockerfile deployment/frontend/Dockerfile

# Create archive
echo "🗜️ Creating deployment archive..."
tar -czf cravyn-deployment.tar.gz deployment/

echo "✅ Deployment package ready!"
echo "📦 Package: cravyn-deployment.tar.gz"
echo "📁 Directory: deployment/"
echo ""
echo "🚀 To deploy:"
echo "1. Extract: tar -xzf cravyn-deployment.tar.gz"
echo "2. Setup: cd deployment && ./setup.sh"
echo "3. Deploy: source .env && ./deploy.sh"