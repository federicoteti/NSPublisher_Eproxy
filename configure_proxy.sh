#!/bin/bash

# Author: Federico Teti
# Title: Solutions Architect
# Organization: Netskope
# Version: 1.0

# Log file path
log_file="/var/log/proxy_config.log"

# Function to display a countdown timer
function countdown_timer() {
    local seconds=$1
    while [ $seconds -gt 0 ]; do
        echo -ne "Time remaining: ${seconds}s\033[0K\r"
        sleep 1
        : $((seconds--))
    done
    echo
}

# Function to display current proxy settings
function show_current_settings() {
    echo -e "\nCurrent Proxy Settings:"
    echo "http_proxy:  $(echo $http_proxy)"
    echo "https_proxy: $(echo $https_proxy)"
}

# Function to validate IPv4 address
function validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0  # Valid IP address
    else
        return 1  # Invalid IP address
    fi
}

# Function to validate port number
function validate_port() {
    local port=$1
    if [[ $port =~ ^[1-9][0-9]*$ && $port -le 65535 ]]; then
        return 0  # Valid port number
    else
        return 1  # Invalid port number
    fi
}

# Function to prompt user to confirm or cancel changes
function confirm_changes() {
    local confirm_message="Proxy Configuration Summary:
IP Address: ${proxy_ip}
Port: ${proxy_port}

Type 'yes' to continue or any other key to cancel: "

    read -p "${confirm_message}" user_response
    if [ "$user_response" != "yes" ]; then
        echo "Proxy settings not applied. Exiting."
        exit 0
    fi
}

# Parse command line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--show)
            show_current_settings
            exit 0
            ;;
        *)
            echo "Invalid option: $1"
            exit 1
            ;;
    esac
    shift
done

# Prompt the user for proxy details
read -p "Enter the IP address of the proxy: " proxy_ip

# Validate the IP address
if ! validate_ip "$proxy_ip"; then
    echo "Invalid IP address format. Exiting."
    exit 1
fi

read -p "Enter the port of the proxy: " proxy_port

# Validate the port number
if ! validate_port "$proxy_port"; then
    echo "Invalid port number. Exiting."
    exit 1
fi

# Display configuration details
echo -e "\nProxy Configuration Summary:"
echo "IP Address: ${proxy_ip}"
echo "Port: ${proxy_port}"

# Confirm changes
confirm_changes

# Update /etc/environment
sudo bash -c "cat <<EOL >> /etc/environment
export http_proxy=\"http://${proxy_ip}:${proxy_port}/\"
export https_proxy=\"http://${proxy_ip}:${proxy_port}/\"
EOL"

# Create and edit /etc/systemd/system/docker.service.d/http-proxy.conf
sudo mkdir -p /etc/systemd/system/docker.service.d/
sudo bash -c "cat <<EOL > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment=\"HTTP_PROXY=http://${proxy_ip}:${proxy_port}\"
Environment=\"HTTPS_PROXY=http://${proxy_ip}:${proxy_port}\"
EOL"

# Reload systemd and restart docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# Log the configuration details
log_message="Proxy configured with IP: ${proxy_ip} and Port: ${proxy_port} by ${USER}"
echo "$(date): ${log_message}" | sudo tee -a "$log_file"

# Display a countdown timer and inform the user to log out and log in
echo -e "\nProxy settings applied successfully."
countdown_timer 10  # You can adjust the timer duration as needed
echo "Please log out and log in for the changes to take effect."

