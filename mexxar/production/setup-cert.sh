#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT_DIR="$SCRIPT_DIR/certs"
CERT_FILE="$CERT_DIR/cert.p12"

echo "Documenso Production Certificate Setup"
echo "======================================="
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

# Prompt for certificate details
echo "Certificate Information"
echo "----------------------"
read -p "Country Code (e.g., US): " COUNTRY
read -p "State/Province: " STATE
read -p "City: " CITY
read -p "Organization: " ORG
read -p "Domain (e.g., yourdomain.com): " DOMAIN

# Prompt for certificate password
echo ""
read -s -p "Enter certificate password: " CERT_PASS
echo
read -s -p "Confirm password: " CERT_PASS_CONFIRM
echo

if [ "$CERT_PASS" != "$CERT_PASS_CONFIRM" ]; then
    echo "ERROR: Passwords do not match"
    exit 1
fi

if [ -z "$CERT_PASS" ]; then
    echo "ERROR: Password cannot be empty"
    exit 1
fi

# Generate certificate
echo ""
echo "Generating self-signed certificate..."
echo "Valid for 365 days"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$CERT_DIR/private.key" \
    -out "$CERT_DIR/certificate.crt" \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORG}/CN=${DOMAIN}" \
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
echo "Domain: $DOMAIN"
echo ""
echo "IMPORTANT: Update your .env file with:"
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
    echo ""
fi

echo "Next steps:"
echo "1. Ensure your .env file has all required cloud service credentials"
echo "2. Run ./start.sh to start the production service"
