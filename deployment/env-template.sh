# Environment Variables for Google Cloud Deployment

# Required for deployment
export PROJECT_ID="gen-lang-client-0453265038"
export GEMINI_API_KEY="AIzaSyCA_y4nHkb9FApH_yLKSLXYl9OOD3ztShk"
export MONGO_URL="mongodb+srv://softwares:<sweQ2U3QzJXmZgo6>@production.ukwjfkq.mongodb.net/?retryWrites=true&w=majority&appName=Production"

# Optional configurations
export REGION="us-central1"
export BACKEND_IMAGE="cravyn-backend"
export FRONTEND_IMAGE="cravyn-frontend"
export DB_NAME="cravyn_db"

# For custom domain (optional)
export DOMAIN="https://www.cravyn.food"

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