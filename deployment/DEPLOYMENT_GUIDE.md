# Cravyn Production Deployment Package
# Complete Google Cloud Platform deployment

## 🚀 Quick Start

### Prerequisites
- Google Cloud account with billing enabled
- Docker installed locally
- Git repository (for CI/CD)

### 1. Setup Google Cloud
```bash
./setup.sh
```

### 2. Test Locally (Optional)
```bash
source .env
./test-local.sh
```

### 3. Deploy to Google Cloud
```bash
source .env
./deploy.sh
```

## 📁 Package Contents

### Core Files
- `backend/` - FastAPI backend application
- `frontend/` - React frontend application  
- `backend.Dockerfile` - Backend container configuration
- `frontend.Dockerfile` - Frontend container configuration

### Deployment Scripts
- `setup.sh` - Interactive Google Cloud setup
- `deploy.sh` - Automated deployment to Cloud Run
- `test-local.sh` - Local Docker testing
- `cleanup.sh` - Clean up test resources

### Configuration
- `env-template.sh` - Environment variables template
- `github-actions.yml` - CI/CD pipeline configuration

## 🔧 Environment Variables

Required:
- `PROJECT_ID` - Google Cloud project ID
- `GEMINI_API_KEY` - Google AI Studio API key
- `MONGO_URL` - MongoDB connection string

Optional:
- `REGION` - Google Cloud region (default: us-central1)
- `DOMAIN` - Custom domain name

## 🌐 Getting API Keys

### Gemini API Key
1. Go to [Google AI Studio](https://aistudio.google.com/)
2. Click "Get API key"
3. Create key for your project
4. Copy key (starts with AIza...)

### MongoDB Connection
1. Go to [MongoDB Atlas](https://cloud.mongodb.com/)
2. Create free cluster
3. Create database user
4. Get connection string
5. Replace `<password>` with your password

## 🚀 Deployment Options

### Option A: Cloud Run (Recommended)
- Serverless, pay-per-use
- Auto-scaling
- Easy to manage
- Cost: ~$50-100/month

### Option B: Google Kubernetes Engine
- Full container orchestration
- More control
- Better for high traffic
- Cost: ~$200-500/month

## 📊 Monitoring & Logging

After deployment:
- View logs: `gcloud run logs tail cravyn-backend`
- Monitor performance: Google Cloud Console
- Set up alerts: Cloud Monitoring

## 🔒 Security Features

- Non-root container users
- Environment variable secrets
- CORS configuration
- Input validation
- Health checks

## 📱 Features Included

- ✅ AI recipe generation (Gemini 2.0-flash)
- ✅ 54+ African cuisines
- ✅ Smart ingredient tracking
- ✅ Mobile-responsive design
- ✅ Dietary preference filters
- ✅ Recipe history
- ✅ Image generation capability
- ✅ Ultra-resilient architecture

## 🎯 Expected Results

After successful deployment:
- Frontend URL: `https://cravyn-frontend-xxx.run.app`
- Backend URL: `https://cravyn-backend-xxx.run.app`
- Custom domain: `https://your-domain.com` (if configured)

## 🆘 Troubleshooting

### Common Issues
1. **Build failures**: Check Docker syntax
2. **API errors**: Verify environment variables
3. **Database connection**: Check MongoDB URL
4. **Permission errors**: Verify IAM roles

### Debug Commands
```bash
# Check service status
gcloud run services list

# View logs
gcloud run logs tail cravyn-backend --region=us-central1

# Test endpoints
curl https://your-backend-url/api/
```

## 📞 Support

For deployment issues:
1. Check logs first
2. Verify environment variables
3. Test locally with Docker
4. Check Google Cloud IAM permissions

## 🔄 CI/CD Setup

1. Copy `github-actions.yml` to `.github/workflows/`
2. Add secrets to GitHub repository:
   - `GCP_PROJECT_ID`
   - `GCP_SA_KEY` (service account key)
   - `GEMINI_API_KEY`
   - `MONGO_URL`
3. Push to main branch to trigger deployment

## 🎉 Success Metrics

After deployment, verify:
- [ ] Frontend loads correctly
- [ ] Backend API responds
- [ ] Recipe generation works
- [ ] Mobile layout correct
- [ ] All cuisines available
- [ ] Historical ingredients tracked

---

**🍳 Ready to serve "Eat what you crave" on Google Cloud!**