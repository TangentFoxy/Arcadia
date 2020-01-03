#!/usr/bin/env bash

SESSION_SECRET=secret
DB_HOST=realms2testdb
DB_USER=realms2test
DB_PASS=password
DB_NAME=realms2test
NET_NAME=realms2testnet

sudo docker stop realms2test
sudo docker stop $DB_HOST
sudo docker rm realms2test
sudo docker rm $DB_HOST

sudo docker network create $NET_NAME
sudo docker run --name $DB_HOST -e POSTGRES_PASSWORD=$DB_PASS \
 -e POSTGRES_USER=$DB_USER -e POSTGRES_DB=$DB_NAME \
 --network $NET_NAME --restart unless-stopped \
 -d postgres:12.1-alpine
sleep 5 # give it time to spin up to prevent failures on starting my container
sudo docker run --name realms2test --network $NET_NAME -p 80:80 \
 -e SESSION_SECRET=$SESSION_SECRET -e DB_HOST=$DB_HOST \
 -e DB_USER=$DB_USER -e DB_PASS=$DB_PASS -e DB_NAME=$DB_NAME \
 --restart unless-stopped -d guard13007/realms2:latest
