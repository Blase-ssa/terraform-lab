#!/usr/bin/bash
set -e

sudo apt update && sudo apt install nginx -y && sudo systemctl start nginx && sudo systemctl enable nginx
