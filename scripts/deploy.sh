#!/bin/bash
# KENIOS HAX - Deploy to GitHub
echo "🚀 Deploying KENIOS HAX to GitHub..."
git add .
git commit -m "[KENIOS] Auto-deploy $(date '+%Y-%m-%d %H:%M')" 2>/dev/null || echo "No changes to commit"
git push origin main 2>/dev/null || echo "Push failed - check remote"
echo "✅ Deploy complete!"
