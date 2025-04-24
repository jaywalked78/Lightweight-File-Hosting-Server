#!/bin/bash
# Start localtunnel in the background and redirect output
lt --port 7779 > /tmp/tunnel_url.txt 2>&1 &
LT_PID=$!

# Give localtunnel a moment to start and generate the URL
sleep 3

# Check if the URL file exists and has content
if [ -f "/tmp/tunnel_url.txt" ] && [ -s "/tmp/tunnel_url.txt" ]; then
  # Extract the URL (assuming it's in the format "your url is: https://...")
  URL=$(grep -o "https://[^[:space:]]*" /tmp/tunnel_url.txt | head -n 1)
  
  if [ -n "$URL" ]; then
    echo "{\"pid\":\"$LT_PID\",\"url\":\"$URL\"}"
  else
    echo "{\"error\":\"URL not found in output\",\"content\":\"$(cat /tmp/tunnel_url.txt)\"}"
  fi
else
  echo "{\"error\":\"Tunnel URL file not created or empty\"}"
fi