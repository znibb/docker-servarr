#!/bin/bash

mkdir -p ./secrets
if [ ! -f .env ]; then
	cp ./files/.env.example .env
fi
if [ ! -f ./secrets/transmission_password.secret ]; then
	touch ./secrets/transmission_password.secret
fi
