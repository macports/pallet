#!/bin/bash

# Create the cert directory (where all cert information will be stored)

security find-certificate -c Pallet-Certificate &>/dev/null 
retval=$?

if [ $retval -eq 0 ]; then
    echo "Certificate already exists."
    exit 1
else
    echo "Certificate doesn't exist. Beginning generation."
    if [ ! -d ./certs/ ]; then

        echo "Directory, \"./certs/\" does not exist. Creating."
        mkdir certs
    else
        echo "Directory, \"./certs/\" already exists. Skipping creation." 
    fi

    # Generate the magical configuration file.
    if [ ! -f ./certs/apple.conf ]; then
        
        echo "Configuration file, \"./certs/apple.conf\" does not exist. Creating."

        # THE FOLLOWING CONFIG INFORMATION IS MAGIC THAT WAS FOUND AFTER 14 HOURS ON GOOGLE. DO. NOT. TOUCH. 
        touch ./certs/apple.conf
        echo "[ req ]
        distinguished_name = req_name
        prompt = no
        [ req_name ]
        CN = Pallet-Certificate 
        [ extensions ]
        basicConstraints=critical,CA:false
        keyUsage=critical,digitalSignature
        extendedKeyUsage=codeSigning" >> ./certs/apple.conf
    else
         echo "Configuration file, \"./certs/apple.conf\" already exists. Skipping creation."
    fi

    # Generate a new private key
    if [ ! -f ./certs/apple.key ]; then

        echo "Private key, \"./certs/apple.key\" does not exist. Creating."
        openssl genrsa -out ./certs/apple.key  2048
    else
        echo "Private key, \"./certs/apple.key\" already exists. Skipping creation."
    fi

    # Generate a new cert (packed with information from apple.conf)
    if [ ! -f ./certs/apple.crt ]; then

        echo "Certificate, \"./certs/apple.crt\" does not exist. Creating."
        openssl req -x509 -new -config ./certs/apple.conf -nodes -key ./certs/apple.key -extensions extensions -sha256 -out ./certs/apple.crt
    else
        echo "Certificate, \"./certs/apple.crt\" already exists. Skipping creation."
    fi


    # Generate a new convert that cert to a P12 for importing
    if [ ! -f ./certs/apple.p12 ]; then

        echo "Certificate, \"./certs/apple.p12\" does not exist. Creating."
        echo test | openssl pkcs12 -export -password test -inkey ./certs/apple.key -in ./certs/apple.crt -out ./certs/apple.p12 -password stdin
    else
        echo "Certificate, \"./certs/apple.p12\" already exists. Skipping creation."
    fi

    # Import the the newly created P12 certificate into the login (default) keychain.
    echo "Importing the certificate into the keychain."
    security unlock-keychain -u login.keychain
    security import ./certs/apple.p12 -k login.keychain -P test
fi
