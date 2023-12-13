#!/bin/bash

# Server information
SERVER_IP="18.214.88.155"
SSH_KEY="/path/to/your/private/key.pem"

# Remote directory where your app is deployed
REMOTE_DIR=""

echo "Testing the Flask application on $SERVER_IP"

# Start the Flask development server
ssh -i "$SSH_KEY" "ubuntu@$SERVER_IP" "cd $REMOTE_DIR && source venv/bin/activate && python3 app.py"

