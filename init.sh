#!/bin/bash
if [ ! -f .env ]; then
	cp .env.example .env
fi
if [ ! -f transmission_password.secret ]; then
	cp transmission_password.secret.example transmission_password.secret
fi
