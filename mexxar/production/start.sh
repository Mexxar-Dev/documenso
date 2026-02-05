#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting Mexxar Production Environment"
echo "======================================="
echo ""

cd "$SCRIPT_DIR"

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "ERROR: .env file not found!"
    echo ""
    echo "Please create .env file from .env.example:"
    echo "   cp .env.example .env"
    echo "   nano .env  # Edit with your cloud service credentials"
    echo ""
    exit 1
fi

# Check if certificate exists
if [ ! -f "certs/cert.p12" ]; then
    echo "WARNING: No certificate found!"
    echo ""
    read -p "Generate certificate now? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        ./setup-cert.sh
        echo ""
    else
        echo "WARNING: Starting without certificate. Document signing will not work."
        echo ""
    fi
fi

# Pull latest image
echo "Pulling latest Documenso image..."
docker compose pull app

# Start service
echo "Starting production service..."
docker compose up -d

echo ""
echo "Production service started successfully!"
echo ""
echo "Checking health..."
sleep 5

# Check if container is running
if docker compose ps | grep -q "Up"; then
    echo "Status: Running"
    echo ""
    echo "Access Points:"
    echo "   App: http://localhost:3000"
    echo "   Health: http://localhost:3000/api/health"
    echo ""
    echo "Useful commands:"
    echo "   View logs:  ./logs.sh"
    echo "   Stop:       ./stop.sh"
    echo "   Restart:    docker compose restart app"
else
    echo "ERROR: Service failed to start!"
    echo ""
    echo "Check logs with: docker compose logs app"
    exit 1
fi
