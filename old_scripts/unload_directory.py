#!/usr/bin/env python3
import os
import sys
import argparse
import requests
import json
from datetime import datetime

# Load environment variables from .env file
try:
    from dotenv import load_dotenv
    load_dotenv()
    print("Loaded environment variables from .env file")
except ImportError:
    print("Warning: python-dotenv not installed. Environment variables may not be loaded.")

# Configuration
SERVER_URL = "http://localhost:7779"

def is_server_running(server_url=None):
    """Check if the server is running"""
    url = server_url or SERVER_URL
    try:
        response = requests.get(url)
        return response.status_code == 200
    except requests.exceptions.ConnectionError:
        return False

def get_server_info(server_url=None):
    """Get detailed server information"""
    url = server_url or SERVER_URL
    response = requests.get(url)
    if response.status_code != 200:
        return None
    
    info = response.json()
    return info

def unload_directory(server_url=None, verbose=False):
    """Unload the current directory from the server"""
    url = server_url or SERVER_URL
    
    # First check if there's anything loaded
    server_info = get_server_info(url)
    if not server_info:
        print("Error: Unable to fetch server information.")
        return False
    
    current_dir = server_info.get("current_directory", None)
    if not current_dir:
        print("No directory is currently loaded on the server.")
        return True  # Nothing to unload, so consider it a success
    
    if verbose:
        print(f"Currently loaded directory: {current_dir}")
        print(f"Images loaded: {len(server_info.get('image_list', []))}")
        print(f"Sending unload request to {url}/unload")
    
    try:
        response = requests.post(f"{url}/unload")
        
        if response.status_code == 200:
            result = response.json()
            print(f"Success: {result.get('message', 'Directory unloaded successfully')}")
            
            # Verify the unload worked by checking the server status again
            if verbose:
                updated_info = get_server_info(url)
                if updated_info and not updated_info.get("current_directory"):
                    print("Verified: No directory is currently loaded.")
                else:
                    print("Warning: Directory might still be loaded. Server state unclear.")
            
            return True
        else:
            print(f"Error: Server returned status code {response.status_code}")
            print(f"Response: {response.text}")
            return False
    except Exception as e:
        print(f"Error during unload operation: {str(e)}")
        return False

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description="Unload the current directory from the lightweight image server")
    parser.add_argument("--server", type=str, default=SERVER_URL, 
                        help="URL of the image server")
    parser.add_argument("--verbose", "-v", action="store_true",
                        help="Show detailed information")
    
    args = parser.parse_args()
    server_url = args.server
    verbose = args.verbose
    
    if verbose:
        print("\n=== Image Server Unload Utility ===")
        print(f"Server URL: {server_url}")
        print("==================================\n")
    
    # Check if server is running
    if not is_server_running(server_url):
        print("Error: Server is not running")
        return 1
    
    # Unload directory
    success = unload_directory(server_url, verbose)
    
    if verbose:
        print("\n=== Operation completed ===")
    
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main()) 