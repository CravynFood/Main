#!/bin/bash

# Final Verification Script for Cravyn Deployment Package
echo "🔍 VERIFYING CRAVYN DEPLOYMENT PACKAGE"
echo "====================================="

# Check if all required files exist
echo "📋 Checking required files..."

required_files=(
    "setup.sh"
    "deploy.sh"
    "test-local.sh"
    "cleanup.sh"
    "env-template.sh"
    "github-actions.yml"
    "DEPLOYMENT_GUIDE.md"
    "DEPLOYMENT_SUMMARY.md"
    "backend/server.py"
    "backend/requirements.txt"
    "backend/Dockerfile"
    "frontend/package.json"
    "frontend/src/App.js"
    "frontend/Dockerfile"
)

missing_files=()
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file - MISSING"
        missing_files+=("$file")
    fi
done

echo ""
if [ ${#missing_files[@]} -eq 0 ]; then
    echo "🎉 All required files present!"
else
    echo "⚠️  Missing files: ${missing_files[*]}"
fi

echo ""
echo "📊 Package Statistics:"
echo "- Backend files: $(find backend -type f | wc -l)"
echo "- Frontend files: $(find frontend -type f | wc -l)"
echo "- Script files: $(find . -maxdepth 1 -name "*.sh" | wc -l)"
echo "- Documentation: $(find . -maxdepth 1 -name "*.md" | wc -l)"

echo ""
echo "🎯 Deployment Package Ready!"
echo "- Extract: tar -xzf cravyn-gcp-deployment.tar.gz"
echo "- Setup: ./setup.sh"
echo "- Deploy: source .env && ./deploy.sh"

echo ""
echo "🍳 Ready to serve 'Eat what you crave' on Google Cloud!"