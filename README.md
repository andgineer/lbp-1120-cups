# Canon LBP-1120 CUPS Docker Server

A dockerized CUPS (Common Unix Printing System) server specifically configured for Canon LBP-1120 laser printers with automatic network discovery via Avahi.

## Overview

This project provides a ready-to-use Docker container that runs a CUPS print server with pre-installed Canon CAPT drivers for the LBP-1120 printer. The container includes Avahi daemon for automatic printer discovery on your local network, making it easy to set up network printing for this older Canon laser printer model.

## Features

- ✅ **CUPS server** in a lightweight Docker container
- ✅ **Canon LBP-1120** printer support with CAPT drivers pre-installed
- ✅ **Avahi daemon** for automatic network discovery
- ✅ **Web interface** for printer management
- ✅ **Optimized settings** for monochrome printing with enhanced black output

## Quick Start

### Prerequisites

- Docker installed on your system
- Canon LBP-1120 printer connected to the network or USB

### 1. Build the Container

```bash
docker build -t lbp-1120-cups .
```

### 2. Run the Container

```bash
docker run \
    -d \
    -p 631:631 \
    -p 5353:5353 \
    -v /var/run/dbus:/var/run/dbus \
    --name lbp-1120 \
    lbp-1120-cups
```

### 3. Access the Web Interface

Open your browser and navigate to: http://localhost:631

## Configuration

### Port Mapping

- **631**: CUPS web interface and IPP protocol
- **5353**: Avahi mDNS for printer discovery

### Volume Mounts

- `/var/run/dbus`: Required for proper D-Bus communication between services

### Default Printer Settings

The container automatically configures the Canon LBP-1120 with these optimized settings:

- **Color Mode**: Monochrome
- **Enhanced Black Printing**: Enabled
- **Skip Blank Pages**: Enabled
- **Default Location**: Kitchen (configurable)

## Management Commands

### View Container Status
```bash
docker ps | grep lbp-1120
```

### View Logs
```bash
docker logs lbp-1120
```

### Stop the Container
```bash
docker stop lbp-1120
```

### Restart the Container
```bash
docker restart lbp-1120
```

### Remove the Container
```bash
docker stop lbp-1120
docker rm lbp-1120
```

## Troubleshooting

### Printer Not Detected
1. Ensure the printer is powered on and connected
2. Check that port 631 is not blocked by firewall
3. Verify the printer IP address matches the configuration

### Cannot Access Web Interface
- Confirm the container is running: `docker ps`
- Check port binding: `docker port lbp-1120`
- Ensure no other service is using port 631

### Network Discovery Issues
- Verify Avahi is running in the container logs
- Check that port 5353 is not blocked
- Ensure mDNS is enabled on your network

## Technical Details

### Base Image
Built on `olbat/cupsd` which provides a minimal CUPS installation.

### Included Drivers
- `cndrvcups-capt_2.71-1_amd64.deb` - Canon CAPT driver
- `cndrvcups-common_3.21-1_amd64.deb` - Common Canon utilities

### Service Architecture
- **CUPS daemon**: Handles print job processing
- **Avahi daemon**: Manages network service discovery
- **Automatic printer setup**: Configures Canon LBP-1120 on first run

## What is CUPS?

CUPS (Common Unix Printing System) is a modular printing system for Unix-like operating systems that allows a computer to act as a print server. It can accept print jobs from client computers, process them, and send them to the appropriate printer.

## What is Avahi?

Avahi is a system that facilitates service discovery on local networks via the mDNS/DNS-SD protocol suite. In this context, it enables automatic discovery of the CUPS print server on your network, making printer setup seamless for client devices.
