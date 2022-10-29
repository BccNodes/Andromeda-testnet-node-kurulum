#!/bin/bash

if [ ! $CHAIN_NAME ]; then
	read -p "Enter chain name: " CHAIN_NAME
	echo 'export CHAIN_NAME='$CHAIN_NAME >> $HOME/.bash_profile
fi

if [ ! $API_PORT ]; then
	read -p "Enter API port (default 1317): " API_PORT
	echo 'export API_PORT='$API_PORT >> $HOME/.bash_profile
fi

sudo apt update && sudo apt upgrade -y

sudo apt install nginx certbot python3-certbot-nginx -y

sudo rm -f /etc/nginx/sites-{available,enabled}/default

sudo tee /etc/nginx/sites-available/${CHAIN_NAME}.api.bccnodes.com.conf > /dev/null <<EOF
server {
        listen 80;
        listen [::]:80;

        server_name ${CHAIN_NAME}.api.bccnodes.com;

        location / {

                add_header Access-Control-Allow-Origin *;
                add_header Access-Control-Max-Age 3600;
                add_header Access-Control-Expose-Headers Content-Length;

                proxy_pass http://127.0.0.1:${API_PORT};
        }
}
EOF

sudo ln -s /etc/nginx/sites-available/${CHAIN_NAME}.api.bccnodes.com.conf /etc/nginx/sites-enabled/${CHAIN_NAME}.api.bccnodes.com.conf

sudo systemctl reload nginx.service

sudo certbot --nginx --register-unsafely-without-email
