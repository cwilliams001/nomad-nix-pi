# NixOS Raspberry Pi with NomadNet and Message Board

This repository contains the configuration files and scripts to set up a Raspberry Pi running NixOS with NomadNet and a custom message board application.

## Prerequisites

- Raspberry Pi (compatible with NixOS)
- NixOS installed on the Raspberry Pi
- Basic understanding of NixOS and Nix package management

## Setup

1. Clone this repository to your local machine.

2. Copy the configuration files to your Raspberry Pi:
   - `configuration.nix` should be placed in `/etc/nixos/`
   - `nomadmb.nix` and `messageboard.py` should be placed in `/home/nixpi/`

3. Update the `configuration.nix` file:
   - Modify the `networking.hostName` to your desired hostname
   - Update the `time.timeZone` to your local timezone
   - Change the `users.users.nixpi.initialPassword` to a secure password

4. Create the NomadMB package:
   - Ensure `messageboard.py` is in the same directory as `nomadmb.nix`
   - The `nomadmb.nix` file will create a package called `nomadmb`

5. Update the system configuration:
   ```bash
   sudo nixos-rebuild switch
   ```

6. After the system reboots, you'll need to manually start NomadNet and the message board service.

## Usage

### Starting NomadNet and Message Board

A tmux script is provided to start both NomadNet and the message board service. To use it:

1. Make sure the script is executable:
   ```bash
   chmod +x /home/nixpi/start_nomad.sh
   ```
2. Run the script:
   ```bash
   /path/to/script/start_nomad.sh
   ```
  
  This script will create two tmux sessions:
  - `nomadnet-session`: Runs NomadNet
  - `nomadmb`: Runs the message board service

  You can attach to these sessions using:

  ```bash
  tmux attach-session -t nomadnet-session
  tmux attach-session -t nomadmb
  ```


### NomadNet

Once started, NomadNet can be accessed through its web interface or command-line interface.

### Message Board

The message board is accessible through NomadNet. To post a message, send a message to the NomadNet Message Board address configured in your system.

### Updating the Configuration

To update the configuration:

1. Modify the necessary files (`configuration.nix`, `nomadmb.nix`, or `messageboard.py`)
2. Run `sudo nixos-rebuild switch` to apply the changes

## Files Description

- `configuration.nix`: Main NixOS configuration file
- `nomadmb.nix`: Nix package definition for the message board application
- `messageboard.py`: Python script for the message board functionality
- `~/.nomadnetwork/storage/pages/index.mu`: NomadNet index page that displays the message board

## Notes

- The Python and Bash scripts have been modified to use the NixOS-specific shebang (`#!/usr/bin/env python3` and `#!/run/current-system/sw/bin/python`)
- The message board data is stored in `~/.nomadmb/storage/board`
- Ensure that the `message_board_peer` variable in the `index.mu` file is set to the correct address of your message board peer

## Automating Startup

If you want the services to start automatically on boot:

1. Create a systemd service file for each program.
2. Enable and start the services using `systemctl`.

Alternatively, you could add the tmux script to your user's crontab with the `@reboot` directive.

## Troubleshooting

If you encounter any issues:
1. Check the system logs: `journalctl -xe`
2. Verify that all services are running: `systemctl status nomadnet.service` (if you've set up systemd services)
3. Ensure that the Tailscale service is connected: `tailscale status`



