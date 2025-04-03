#!/bin/bash

# Setup logging
logfile="/home/${admin_username}/custom-data.log"
exec > $logfile 2>&1

python3 -V
sudo apt update
sudo apt install -y python3-pip python3-flask
python3 -m flask --version

sudo cat << EOF > /home/${admin_username}/haha.py
from flask import Flask
import requests

app = Flask(__name__)

import requests
@app.route('/')
def hello_terraform():
    return """<!DOCTYPE html>
<html>
<meta charset="UTF-8">
<head>
    <title>Julia Test</title>
</head>
<body>
    <h1>HAHAHA! Let's go Terraform! Vroom!🚗🌮🌮🌮</h1>
</body>
</html>"""
EOF

chmod +x /home/${admin_username}/haha.py

sudo -b FLASK_APP=/home/${admin_username}/haha.py flask run --host=0.0.0.0 --port=${port}