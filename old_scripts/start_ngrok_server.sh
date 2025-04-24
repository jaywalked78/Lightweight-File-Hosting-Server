#!/bin/bash
# start_ngrok_server.sh
# This script starts a local HTTP server and exposes it via ngrok

# Set colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Starting ngrok tunnel for image server ===${NC}"

# Check if ngrok is installed
if ! command -v ngrok &> /dev/null; then
    echo -e "${RED}Error: ngrok is not installed${NC}"
    echo "Please install ngrok from https://ngrok.com/download"
    echo "Then authenticate with: ngrok config add-authtoken YOUR_TOKEN"
    exit 1
fi

# Check if the server is already running
check_server() {
    if curl -s http://localhost:7779 &> /dev/null; then
        return 0  # Server is running
    else
        return 1  # Server is not running
    fi
}

# Start the local server if not already running
if check_server; then
    echo -e "${GREEN}Image server is already running on port 7779${NC}"
else
    echo -e "${YELLOW}Image server not running. Starting server...${NC}"
    
    # Get the script directory
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    
    # Start the server in the background
    pushd "$SCRIPT_DIR" > /dev/null
    ./persistent_run.sh &
    SERVER_PID=$!
    popd > /dev/null
    
    echo -e "${GREEN}Image server started with PID: $SERVER_PID${NC}"
    
    # Wait for server to start
    echo -e "${YELLOW}Waiting for server to initialize...${NC}"
    for i in {1..10}; do
        if check_server; then
            echo -e "${GREEN}Server initialized successfully${NC}"
            break
        fi
        echo -e "${YELLOW}Waiting... ($i/10)${NC}"
        sleep 1
        
        if [ $i -eq 10 ]; then
            echo -e "${RED}Failed to start server. Check logs for details.${NC}"
            exit 1
        fi
    done
fi

# Kill any existing ngrok processes for the same port
echo -e "${BLUE}Killing any existing ngrok tunnels on port 7779...${NC}"
pkill -f "ngrok http 7779" || true
sleep 2

# Start ngrok in the background
echo -e "${BLUE}Starting ngrok tunnel...${NC}"
ngrok http 7779 --log=stdout > /tmp/ngrok_log.txt 2>&1 &
NGROK_PID=$!

# Wait for ngrok to initialize
echo -e "${YELLOW}Waiting for ngrok tunnel to establish...${NC}"
sleep 5

# Extract the ngrok URL
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*"' | head -n 1 | cut -d'"' -f4)

if [ -z "$NGROK_URL" ]; then
    echo -e "${RED}ERROR: Could not get ngrok URL${NC}"
    echo -e "${YELLOW}Checking ngrok logs...${NC}"
    cat /tmp/ngrok_log.txt
    echo -e "${RED}Try manually setting up ngrok with: ngrok config add-authtoken YOUR_TOKEN${NC}"
    exit 1
fi

# Save the URL to a file for reference
echo "$NGROK_URL" > /tmp/ngrok_url.txt

# Output the results in JSON format
echo -e "${GREEN}Ngrok tunnel established successfully${NC}"
echo -e "${BLUE}Tunnel URL: ${GREEN}$NGROK_URL${NC}"
echo "{\"pid\":\"$NGROK_PID\",\"url\":\"$NGROK_URL\",\"local_url\":\"http://localhost:7779\"}"

# Provide instructions for stopping the tunnel
echo -e "\n${BLUE}=== Tunnel Information ===${NC}"
echo -e "To stop the ngrok tunnel: ${YELLOW}kill $NGROK_PID${NC}"
echo -e "To check tunnel status: ${YELLOW}curl http://localhost:4040/api/tunnels${NC}"
echo -e "To access ngrok web interface: ${YELLOW}http://localhost:4040${NC}"
echo -e "Tunnel logs are available at: ${YELLOW}/tmp/ngrok_log.txt${NC}" 