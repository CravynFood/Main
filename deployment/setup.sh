#!/bin/bash

# Cravyn Quick Setup Script for Google Cloud
# This script helps you set up everything needed for deployment

echo "🚀 Cravyn Google Cloud Setup Assistant"
echo "======================================"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI not found. Please install it first:"
    echo "   https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Login to Google Cloud
echo "🔐 Logging into Google Cloud..."
gcloud auth login

# List projects
echo "📋 Available projects:"
gcloud projects list

# Get project ID
read -p "Enter your Google Cloud Project ID: " PROJECT_ID

# Set project
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "🔧 Enabling required APIs..."
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable generativelanguage.googleapis.com

# Get Gemini API key
echo ""
echo "🤖 Gemini API Key Setup:"
echo "1. Go to https://aistudio.google.com/"
echo "2. Click 'Get API key'"
echo "3. Create key for project: $PROJECT_ID"
echo "4. Copy the key (starts with AIza...)"
echo ""
read -p "Enter your Gemini API key: " GEMINI_API_KEY

# Get MongoDB connection
echo ""
echo "🗄️ MongoDB Setup:"
echo "1. Go to https://cloud.mongodb.com/"
echo "2. Create free cluster"
echo "3. Create database user"
echo "4. Get connection string"
echo "5. Replace <password> with your password"
echo ""
read -p "Enter your MongoDB connection string: " MONGO_URL

# Create environment file
echo "💾 Creating environment configuration..."
cat > .env << EOF
export PROJECT_ID="$PROJECT_ID"
export GEMINI_API_KEY="$GEMINI_API_KEY"
export MONGO_URL="$MONGO_URL"
export REGION="us-central1"
export DB_NAME="cravyn_db"
EOF

echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Source the environment: source .env"
echo "2. Run deployment: ./deploy.sh"
echo ""
echo "🎉 Your Cravyn app will be live on Google Cloud!"