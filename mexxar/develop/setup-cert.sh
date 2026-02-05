#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT_DIR="$SCRIPT_DIR/certs"
CERT_FILE="$CERT_DIR/cert.p12"

echo "Documenso Certificate Setup"
echo "================================"
echo ""

# Check if certificate already exists
if [ -f "$CERT_FILE" ]; then
    read -p "Certificate already exists. Regenerate? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Using existing certificate"
        exit 0
    fi
fi

# Create certs directory if it doesn't exist
mkdir -p "$CERT_DIR"

# Prompt for certificate password
read -s -p "Enter certificate password (or press Enter for default 'documenso'): " CERT_PASS
echo
if [ -z "$CERT_PASS" ]; then
    CERT_PASS="documenso"
    echo "Using default password: documenso"
fi

# Generate certificate
echo ""
echo "Generating self-signed certificate..."

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$CERT_DIR/private.key" \
    -out "$CERT_DIR/certificate.crt" \
    -subj '/C=US/ST=State/L=City/O=Mexxar/CN=localhost' \
    2>/dev/null

echo "Creating PKCS12 file..."

openssl pkcs12 -export \
    -out "$CERT_FILE" \
    -inkey "$CERT_DIR/private.key" \
    -in "$CERT_DIR/certificate.crt" \
    -passout pass:"$CERT_PASS" \
    2>/dev/null

# Set proper permissions
chmod 644 "$CERT_FILE"

# Cleanup temporary files
rm "$CERT_DIR/private.key" "$CERT_DIR/certificate.crt"

echo "Certificate generated successfully!"
echo ""
echo "Certificate location: $CERT_FILE"
echo "Password: $CERT_PASS"
echo ""
echo "Update your .env file with:"
echo "   NEXT_PRIVATE_SIGNING_PASSPHRASE=\"$CERT_PASS\""
echo ""

# Update .env file if it exists
ENV_FILE="$SCRIPT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
    if grep -q "^NEXT_PRIVATE_SIGNING_PASSPHRASE=" "$ENV_FILE"; then
        # Update existing line
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|^NEXT_PRIVATE_SIGNING_PASSPHRASE=.*|NEXT_PRIVATE_SIGNING_PASSPHRASE=\"$CERT_PASS\"|" "$ENV_FILE"
        else
            sed -i "s|^NEXT_PRIVATE_SIGNING_PASSPHRASE=.*|NEXT_PRIVATE_SIGNING_PASSPHRASE=\"$CERT_PASS\"|" "$ENV_FILE"
        fi
        echo "Updated .env file with certificate password"
    else
        # Append new line
        echo "NEXT_PRIVATE_SIGNING_PASSPHRASE=\"$CERT_PASS\"" >> "$ENV_FILE"
        echo "Added certificate password to .env file"
    fi
fi

echo ""
echo "You can now start the services with:"
echo "   cd $SCRIPT_DIR"
echo "   docker compose up -d"
