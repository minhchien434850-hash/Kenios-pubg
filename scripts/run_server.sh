#!/bin/bash

# =====================================================
# KENIOS HAX - Run Server Script
# Khởi chạy Node.js Server
# =====================================================

cd "$(dirname "$0")/../server" || exit

if [ ! -d "node_modules" ]; then
  echo "📦 Installing dependencies..."
  npm install
fi

echo "🚀 Starting KENIOS HAX Server..."
echo "🌐 Server will run on http://localhost:3000"
echo "📝 Press Ctrl+C to stop"
echo ""

npm start
