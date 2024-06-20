#!/bin/bash
if [ ! -f .env ]; then
	cp files/.env.example .env
fi
if [ ! -f transmission_password.secret ]; then
	cp files/transmission_password.secret.example transmission_password.secret
fi
