#!/usr/bin/env bash

SESSION_SECRET=secret
DB_HOST=realms2testdb
DB_USER=realms2test
DB_PASS=password
DB_NAME=realms2test
NET_NAME=realms2testnet

docker stop realms2test
docker stop $DB_HOST
docker rm realms2test
docker rm $DB_HOST

docker run --name $DB_HOST -e POSTGRES_PASSWORD=$DB_PASS \
 -e POSTGRES_USER=$DB_USER -e POSTGRES_DB=$DB_NAME \
 --network $NET_NAME --restart unless-stopped \
 -d postgres:12.1-alpine
sleep 5 # give it time to spin up to prevent failures on starting my container
docker run --name realms2test --network $NET_NAME -P \
 -e SESSION_SECRET=$SESSION_SECRET -e DB_HOST=$DB_HOST \
 -e DB_USER=$DB_USER -e DB_PASS=$DB_PASS -e DB_NAME=$DB_NAME \
 --restart unless-stopped -d guard13007/realms2:latest
