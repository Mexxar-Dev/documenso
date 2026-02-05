#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"

echo "Viewing Documenso production logs (Ctrl+C to exit)"
echo ""

docker compose logs -f app
