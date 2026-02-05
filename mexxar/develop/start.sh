#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting Mexxar Development Environment"
echo "=========================================="
echo ""

cd "$SCRIPT_DIR"

# Check if certificate exists
if [ ! -f "certs/cert.p12" ]; then
    echo "WARNING: No certificate found!"
    echo ""
    read -p "Generate certificate now? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        ./setup-cert.sh
        echo ""
    fi
fi

# Pull latest image
echo "Pulling latest Documenso image..."
docker compose pull app

# Start services
echo "Starting services..."
docker compose up -d

echo ""
echo "Services started successfully!"
echo ""
echo "Access Points:"
echo "   App:        http://localhost:3000"
echo "   Mailserver: http://localhost:9000"
echo "   MinIO:      http://localhost:9001"
echo ""
echo "Useful commands:"
echo "   View logs:  docker compose logs -f app"
echo "   Stop:       docker compose down"
echo "   Restart:    docker compose restart app"
echo ""
