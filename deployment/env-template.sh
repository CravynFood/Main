# Environment Variables for Google Cloud Deployment

# Required for deployment
export PROJECT_ID="your-gcp-project-id"
export GEMINI_API_KEY="your-gemini-api-key-from-ai-studio"
export MONGO_URL="your-mongodb-connection-string"

# Optional configurations
export REGION="us-central1"
export BACKEND_IMAGE="cravyn-backend"
export FRONTEND_IMAGE="cravyn-frontend"
export DB_NAME="cravyn_db"

# For custom domain (optional)
export DOMAIN="your-custom-domain.com"

# Instructions:
# 1. Copy this file to .env
# 2. Replace all placeholder values with your actual values
# 3. Run: source .env
# 4. Then run: ./deploy.sh

# Getting your values:
# 
# PROJECT_ID: 
# - Go to https://console.cloud.google.com/
# - Create or select your project
# - Copy the project ID
#
# GEMINI_API_KEY:
# - Go to https://aistudio.google.com/
# - Click "Get API key"
# - Create key for your project
# - Copy the key (starts with AIza...)
#
# MONGO_URL:
# - Go to https://cloud.mongodb.com/
# - Create free cluster
# - Get connection string
# - Replace <password> with your password
#
# Example values:
# PROJECT_ID="cravyn-prod-123456"
# GEMINI_API_KEY="AIzaSyABC123..."
# MONGO_URL="mongodb+srv://user:password@cluster.mongodb.net/cravyn_db"