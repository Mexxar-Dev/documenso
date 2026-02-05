#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Stopping Mexxar Development Environment"
echo "=========================================="
echo ""

cd "$SCRIPT_DIR"

docker compose down

echo ""
echo "All services stopped"
