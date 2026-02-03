#!/bin/bash

source ./.env

# CA directory
cd ./ca

# Private key
echo "Generating private key..."

openssl genrsa -out $ROOT_CA_KEY_FILE 4096

# Root certificate
echo "Generating root certificate..."

openssl req -x509 -new -nodes \
  -key $ROOT_CA_KEY_FILE \
  -sha256 -days 3650 \
  -out $ROOT_CA_CERT_FILE \
  -subj "/C=SE/O=${CAMELCASE_NAME}/CN=${CAMELCASE_NAME} Root CA"


# Certificate for domain
echo "Generating certificate for ${DOMAIN}"

openssl genrsa -out $DOMAIN_KEY_FILE 2048

openssl req -new -key $DOMAIN_KEY_FILE \
  -out $DOMAIN_CSR_FILE \
  -subj "/CN=${DOMAIN}"


# Signing 
openssl x509 -req \
  -in $DOMAIN_CSR_FILE \
  -CA $ROOT_CA_CERT_FILE \
  -CAkey $ROOT_CA_KEY_FILE \
  -CAcreateserial \
  -out $DOMAIN_CERT_FILE \
  -days 825 \
  -sha256 \
  -extfile san.cnf \
  -extensions req_ext


# Install certificates
sudo cp $DOMAIN_CERT_FILE /etc/ssl/certs/
sudo cp $DOMAIN_KEY_FILE  /etc/ssl/private/

# Cleanup
echo "Setting up secrest directory"

sudo mkdir -p $SECRETS_DIR/ca
sudo chmod 700 $SECRETS_DIR
sudo chmod 700 $SECRETS_DIR/ca

echo "Moving keys"
sudo mv *.key $SECRETS_DIR/ca/
sudo chmod 600 $SECRETS_DIR/ca/*.key

echo "Moving SRLs"
sudo mv *.srl $SECRETS_DIR/ca/
sudo chmod 600 $SECRETS_DIR/ca/*.srl

echo "Removing CSRs"
rm *.csr

# Devices
echo "IMPORTANT! Update the root certificate "${ROOT_CA_CERT_FILE}" to devices!"

# TODO: copy certificate to dropbox, nextcloud, or email

# Done
echo "DONE!"

