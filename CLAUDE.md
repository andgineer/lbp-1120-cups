# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker-based CUPS (Common Unix Printing System) server specifically configured for Canon LBP-1120 printers with Avahi network discovery support.

## Architecture

- **Base Image**: `olbat/cupsd` - Provides the core CUPS functionality
- **Printer Drivers**: Canon CAPT drivers installed from `.deb` packages (`cndrvcups-capt_2.71-1_amd64.deb`, `cndrvcups-common_3.21-1_amd64.deb`)
- **Network Discovery**: Avahi daemon for mDNS/DNS-SD printer discovery on local networks
- **Startup Script**: `start.sh` handles printer configuration and service initialization

## Common Commands

### Docker Operations
```bash
# Build the container
docker build -t lbp-1120-cups .

# Run the container
docker run -d -p 631:631 -p 5353:5353 -v /var/run/dbus:/var/run/dbus --name lbp-1120 lbp-1120-cups

# Access CUPS web interface
# Navigate to http://localhost:631
```

### Container Management
```bash
# View container logs
docker logs lbp-1120

# Stop container
docker stop lbp-1120

# Remove container
docker rm lbp-1120
```

## Key Components

### Dockerfile
- Installs Canon CAPT printer drivers
- Configures required dependencies (libatk-adaptor, libglade2-0, gdb)
- Sets up startup script permissions

### start.sh
- Initializes CUPS daemon
- Configures Canon LBP-1120 printer if not already present
- Sets printer as default with specific options (Color=Mono, Enhance Black Printing=ON, Skip Blank Page=ON)
- Starts Avahi daemon for network discovery
- Maintains container lifecycle by tailing log files

## Network Configuration

- **Port 631**: CUPS web interface and IPP protocol
- **Port 5353**: Avahi mDNS for printer discovery
- **DBus Volume**: Required for proper service communication

## Printer Configuration Details

- **Printer Name**: CanonLBP-1120
- **Connection**: Socket protocol on 0.0.0.0 (configurable)
- **PPD File**: `/usr/share/ppd/CNCUPSLBP1120CAPTJ.ppd`
- **Location**: Kitchen (default, configurable)
- **Default Settings**: Monochrome printing with enhanced black printing and blank page skipping enabled