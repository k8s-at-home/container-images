#!/usr/bin/env bash

if [[ -n "$ORG_JETBRAINS_PROJECTOR_SERVER_SSL_PROPERTIES_PATH" ]]; then
    echo "Generating temporary PKCS12"
    temp_pkcs12="/tmp/cert.p12"
    jks_path=$(grep -oP 'FILE_PATH=\K.*(?=$)' /tmp/ssl.properties)
    key_pass=$(grep -oP 'KEY_PASSWORD=\K.*(?=$)' /tmp/ssl.properties)
    jks_pass=$(grep -oP 'STORE_PASSWORD=\K.*(?=$)' /tmp/ssl.properties)
    cat /tmp/certs/"${TLS_CRT}" /tmp/certs/"${TLS_KEY}" | \
        openssl pkcs12 \
                -export \
                -out ${temp_pkcs12} \
                -password "pass:${key_pass}"

    echo "Generating java keystore from PKCS12"
    /app/ide/jbr/bin/keytool \
        -importkeystore \
        -srckeystore ${temp_pkcs12} \
        -srcstoretype pkcs12 \
        -destkeystore "${jks_path}" \
        -keypasswd "${key_pass}" \
        -storepasswd "${jks_pass}"
fi


