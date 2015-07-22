#!/bin/bash

read -s -p "Enter root password: " password

# Generate a new CRT certificate, and a new private key, privateKey
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout privateKey.key -out certificate.crt

# Convert the new CRT cert to a PEM cert
openssl x509 -in certificate.crt -out certificate.pem -outform PEM -extensions codesign

# Convert the PEM certificate to a new P12 certificate, to import it using security
openssl pkcs12 -export -out certificate.p12 -inkey privateKey.key -in certificate.crt -certfile certificate.pem

# Unlock the default keychain 
security unlock-keychain -p $password login.keychain 

# Import the generated certificate to the default keychain
security import ./certificate.p12 -k login.keychain -P test 

# Make it a trusted cert
security add-trusted-cert -d -r trustRoot -p codeSign -k login.keychain ./certificate.crt

# Lock the default keychain
security lock-keychain login.keychain

# Remove the certs in the local directory
rm certificate.*

# Remove the private key
rm privateKey.key


