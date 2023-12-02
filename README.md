# Publisher_proxy

## Proxy Configuration Script

This Bash script provides a simple and interactive way to configure proxy settings on your system. It allows you to set the HTTP and HTTPS proxy settings for `/etc/environment` and Docker's systemd service.

## Features

- Interactive prompts for the proxy IP address and port.
- Input validation for ensuring a valid IPv4 address and a port number between 1 and 65535.
- Option to display current proxy settings without making changes (`--show` or `-s`).
- Option to confirm changes before applying them (`yes` or `no`).
- Log file (`/var/log/proxy_config.log`) for tracking configuration changes and troubleshooting.

## Usage

1. Clone the repository or download the script.
2. Make the script executable: `chmod +x configure_proxy.sh`
3. Run the script: `./configure_proxy.sh`

### Options

- To display current proxy settings: `./configure_proxy.sh --show` or `./configure_proxy.sh -s`
- To confirm changes before applying: `./configure_proxy.sh --confirm` or `./configure_proxy.sh -c`

## Troubleshooting

Check the log file (/var/log/proxy_config.log) for detailed information about configuration changes.


### Example

```bash
./configure_proxy.sh

Follow the interactive prompts to enter the proxy IP address and port. Confirm the changes when prompted.

