#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Stopping Mexxar Production Environment"
echo "======================================="
echo ""

cd "$SCRIPT_DIR"

docker compose down

echo ""
echo "Production service stopped"
