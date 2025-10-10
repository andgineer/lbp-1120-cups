# Docker CUPS print server for Canon LBP-1120 printers with Avahi mDNS auto-discovery

A dockerized CUPS (Common Unix Printing System) server specifically configured for Canon LBP-1120 laser printers with automatic network discovery via Avahi.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Management Commands](#management-commands)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)
- [Technical Details](#technical-details)
- [About CUPS and Avahi](#about-cups-and-avahi)

## Overview

This project provides a ready-to-use Docker container that runs a CUPS print server with pre-installed Canon CAPT drivers for the LBP-1120 printer. The container includes Avahi daemon for automatic printer discovery on your local network, making it easy to set up network printing for this older Canon laser printer model.

**Supported Platforms**: Linux (x86_64), macOS (with Docker Desktop)

## Features

- **CUPS server** in a lightweight Docker container
- **Canon LBP-1120** printer support with CAPT drivers pre-installed
- **Avahi daemon** for automatic network discovery (mDNS/Bonjour)
- **Web interface** for printer management at http://localhost:631
- **Optimized settings** for monochrome printing with enhanced black output
- **Automatic printer configuration** on first run
- **Persistent configuration** support via volume mounts

## Quick Start

### Prerequisites

- Docker installed on your system ([Install Docker](https://docs.docker.com/get-docker/))
- Canon LBP-1120 printer connected to the network or USB
- Printer IP address (if using network connection)

### 1. Build the Container

```bash
docker build -t lbp-1120-cups .
```

### 2. Configure Printer Connection

Before running the container, edit `start.sh` to set your printer's IP address:

```bash
# Change this line in start.sh:
lpadmin -p CanonLBP-1120 -E -v socket://0.0.0.0 ...
# To your printer's IP, for example:
lpadmin -p CanonLBP-1120 -E -v socket://192.168.1.100 ...
```

### 3. Run the Container

```bash
docker run \
    -d \
    -p 631:631 \
    -p 5353:5353 \
    -v /var/run/dbus:/var/run/dbus \
    --name lbp-1120 \
    lbp-1120-cups
```

**For USB connection**, add the device mapping:
```bash
docker run \
    -d \
    -p 631:631 \
    -p 5353:5353 \
    -v /var/run/dbus:/var/run/dbus \
    --device=/dev/usb/lp0 \
    --name lbp-1120 \
    lbp-1120-cups
```

### 4. Access the Web Interface

Open your browser and navigate to: http://localhost:631

**Default credentials**: `root` / `root` (if prompted)

## Configuration

### Port Mapping

| Port | Protocol | Purpose |
|------|----------|---------|
| 631  | TCP      | CUPS web interface and IPP (Internet Printing Protocol) |
| 5353 | UDP      | Avahi mDNS for printer discovery |

### Volume Mounts

| Host Path | Container Path | Purpose |
|-----------|----------------|---------|
| `/var/run/dbus` | `/var/run/dbus` | Required for D-Bus communication between services |
| (optional) `/path/to/config` | `/etc/cups` | Persist CUPS configuration between container restarts |

### Default Printer Settings

The container automatically configures the Canon LBP-1120 with these optimized settings:

- **Printer Name**: `CanonLBP-1120`
- **Color Mode**: Monochrome
- **Enhanced Black Printing**: Enabled
- **Skip Blank Pages**: Enabled
- **Default Location**: Kitchen (configurable in `start.sh`)
- **Connection Protocol**: Socket (AppSocket/JetDirect)

### Customizing Printer Settings

You can modify printer settings in `start.sh` before building:

```bash
# Change printer location
lpadmin -p CanonLBP-1120 -L "Office" ...

# Change printer IP address
lpadmin -p CanonLBP-1120 -v socket://192.168.1.100 ...

# Modify printer options
lpadmin -p CanonLBP-1120 -o Color=Mono -o CNSkipBlank=ON ...
```

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

### Rebuild After Changes
```bash
docker stop lbp-1120
docker rm lbp-1120
docker build -t lbp-1120-cups .
docker run -d -p 631:631 -p 5353:5353 -v /var/run/dbus:/var/run/dbus --name lbp-1120 lbp-1120-cups
```

## Advanced Usage

### Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  cups:
    build: .
    container_name: lbp-1120
    ports:
      - "631:631"
      - "5353:5353"
    volumes:
      - /var/run/dbus:/var/run/dbus
      - ./cups-config:/etc/cups  # Optional: persist configuration
    restart: unless-stopped
    privileged: false
```

Then run:
```bash
docker-compose up -d
```

### Persistent Configuration

To preserve printer settings between container restarts:

```bash
mkdir -p ./cups-config

docker run \
    -d \
    -p 631:631 \
    -p 5353:5353 \
    -v /var/run/dbus:/var/run/dbus \
    -v $(pwd)/cups-config:/etc/cups \
    --name lbp-1120 \
    lbp-1120-cups
```

### Accessing Container Shell

To troubleshoot or make live changes:

```bash
docker exec -it lbp-1120 /bin/bash
```

### Manual Printer Configuration

Inside the container or via web interface:

```bash
# List available PPD files
lpinfo -m | grep -i canon

# Check printer status
lpstat -p CanonLBP-1120 -l

# Test print
echo "Test page" | lp -d CanonLBP-1120

# View printer options
lpoptions -p CanonLBP-1120 -l
```

### Multiple Printers

To add additional printers, modify `start.sh`:

```bash
# Add a second printer
lpadmin -p CanonLBP-1120-Office -E \
    -v socket://192.168.1.101 \
    -P /usr/share/ppd/CNCUPSLBP1120CAPTJ.ppd \
    -L "Office" \
    -o Color=Mono -o CNEnhanceBlkPrt=ON -o CNSkipBlank=ON
```

## Troubleshooting

### Printer Not Detected

1. **Verify printer is powered on and connected**
   ```bash
   ping 192.168.1.100  # Use your printer's IP
   ```

2. **Check container logs for errors**
   ```bash
   docker logs lbp-1120
   ```

3. **Verify printer IP address in start.sh**
   ```bash
   grep "socket://" start.sh
   ```

4. **Check firewall settings**
   ```bash
   # On Linux
   sudo ufw status
   sudo ufw allow 631/tcp
   sudo ufw allow 5353/udp
   ```

5. **Test printer connection manually**
   ```bash
   docker exec -it lbp-1120 /bin/bash
   telnet 192.168.1.100 9100  # AppSocket port
   ```

### Cannot Access Web Interface

1. **Confirm container is running**
   ```bash
   docker ps | grep lbp-1120
   ```

2. **Check port binding**
   ```bash
   docker port lbp-1120
   ```

3. **Verify no port conflicts**
   ```bash
   # On Linux/macOS
   lsof -i :631
   # Or
   netstat -an | grep 631
   ```

4. **Try accessing with explicit localhost**
   - http://127.0.0.1:631
   - http://localhost:631

5. **Check browser security settings**
   - Some browsers may block self-signed certificates
   - Try using a different browser or incognito mode

### Network Discovery Issues

1. **Verify Avahi is running**
   ```bash
   docker logs lbp-1120 | grep -i avahi
   ```

2. **Check mDNS port availability**
   ```bash
   # Ensure port 5353 is accessible
   docker exec -it lbp-1120 netstat -an | grep 5353
   ```

3. **Enable mDNS on your network**
   - Ensure your router/firewall allows multicast traffic
   - Check that devices are on the same subnet

4. **Test mDNS discovery**
   ```bash
   # On Linux/macOS
   avahi-browse -a -t
   # Or
   dns-sd -B _ipp._tcp
   ```

### Print Jobs Stuck or Failing

1. **Check CUPS error log**
   ```bash
   docker exec -it lbp-1120 tail -f /var/log/cups/error_log
   ```

2. **Clear print queue**
   ```bash
   docker exec -it lbp-1120 cancel -a -x
   ```

3. **Restart CUPS service**
   ```bash
   docker exec -it lbp-1120 /etc/init.d/cups restart
   ```

4. **Verify printer PPD file**
   ```bash
   docker exec -it lbp-1120 lpstat -p CanonLBP-1120 -l
   ```

### Container Won't Start

1. **Check Docker logs**
   ```bash
   docker logs lbp-1120
   ```

2. **Verify D-Bus is available**
   ```bash
   ls -la /var/run/dbus/
   ```

3. **Remove and rebuild container**
   ```bash
   docker rm -f lbp-1120
   docker rmi lbp-1120-cups
   docker build -t lbp-1120-cups .
   docker run -d -p 631:631 -p 5353:5353 -v /var/run/dbus:/var/run/dbus --name lbp-1120 lbp-1120-cups
   ```

### USB Connection Issues

1. **Find USB device**
   ```bash
   lsusb | grep -i canon
   ls -la /dev/usb/
   ```

2. **Check device permissions**
   ```bash
   sudo chmod 666 /dev/usb/lp0
   ```

3. **Verify device mapping**
   ```bash
   docker exec -it lbp-1120 ls -la /dev/usb/
   ```

### Common Error Messages

| Error | Solution |
|-------|----------|
| `Unable to connect to printer` | Check printer IP address and network connectivity |
| `cupsd: Child exited with status 1` | Review `/var/log/cups/error_log` for details |
| `Avahi daemon failed to start` | Ensure D-Bus volume is mounted correctly |
| `lpstat: Bad file descriptor` | Restart CUPS service inside container |
| `Print job held` | Check printer is ready and has paper/toner |

## Technical Details

### Base Image
Built on `olbat/cupsd` which provides a minimal CUPS installation.

### Included Drivers
- `cndrvcups-capt_2.71-1_amd64.deb` - Canon CAPT driver
- `cndrvcups-common_3.21-1_amd64.deb` - Common Canon utilities

### Service Architecture
- **CUPS daemon**: Handles print job processing and IPP protocol
- **Avahi daemon**: Manages network service discovery (mDNS/Bonjour)
- **Automatic printer setup**: Configures Canon LBP-1120 on first run
- **Canon CAPT driver**: Proprietary driver for Canon Advanced Printing Technology

### File Structure

```
.
├── Dockerfile                              # Container build instructions
├── start.sh                                # Startup script for services
├── cndrvcups-capt_2.71-1_amd64.deb        # Canon CAPT driver package
├── cndrvcups-common_3.21-1_amd64.deb      # Canon common utilities
└── README.md                               # This file
```

### Supported Canon Printers

While this container is optimized for the LBP-1120, the CAPT drivers support multiple models:
- LBP-1120
- LBP-810
- LBP-1210
- LBP-2900
- LBP-3000
- And other CAPT-compatible models

To use a different model, modify the PPD file path in `start.sh`:
```bash
lpinfo -m | grep -i canon  # List available PPD files
```

## About CUPS and Avahi

### What is CUPS?

**CUPS (Common Unix Printing System)** is a modular printing system for Unix-like operating systems that allows a computer to act as a print server.

**Key features:**
- Accepts print jobs from client computers via IPP (Internet Printing Protocol)
- Processes print jobs and converts them to printer-specific formats
- Manages print queues and scheduling
- Provides web-based administration interface
- Supports multiple printer drivers and backends

**Why use CUPS in Docker?**
- Centralized print server for multiple devices
- Isolate printer drivers from host system
- Easy deployment and configuration
- Consistent environment across different hosts

### What is Avahi?

**Avahi** is a system that facilitates service discovery on local networks via the mDNS/DNS-SD protocol suite (also known as Bonjour on macOS).

**Key features:**
- Automatic network printer discovery
- Zero-configuration networking
- Compatible with AirPrint and Bonjour
- No manual IP address configuration needed on client devices

**In this container:**
- Publishes the CUPS server on the local network
- Allows devices to discover the printer automatically
- Enables seamless printing from mobile devices and computers

## Client Setup

### macOS

1. Open **System Preferences** > **Printers & Scanners**
2. Click the **+** button to add a printer
3. The Canon LBP-1120 should appear automatically via Bonjour
4. Select it and click **Add**

### Windows

1. Download and install **Bonjour Print Services** from Apple
2. Open **Control Panel** > **Devices and Printers**
3. Click **Add a printer**
4. Select the discovered Canon LBP-1120
5. Install drivers when prompted

### Linux (Ubuntu/Debian)

```bash
# Install CUPS client
sudo apt install cups-client

# Add printer via IPP
lpadmin -p CanonLBP-1120 -E -v ipp://localhost:631/printers/CanonLBP-1120

# Set as default
lpadmin -d CanonLBP-1120

# Print test page
lp -d CanonLBP-1120 /usr/share/cups/data/testprint
```

### iOS/iPadOS

1. Ensure device is on the same network
2. Open any app with print functionality
3. Tap **Share** > **Print**
4. Select the Canon LBP-1120 (should appear automatically)

## Security Considerations

- The CUPS web interface is accessible without authentication by default
- For production use, consider:
  - Enabling authentication in `/etc/cups/cupsd.conf`
  - Using reverse proxy with SSL/TLS
  - Restricting network access with firewall rules
  - Running container in isolated network

Example: Enable authentication
```bash
# Inside container
cupsctl --remote-admin --remote-any --share-printers
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

### Potential Improvements
- Add SSL/TLS support for CUPS web interface
- Support for environment variables for configuration
- Multi-architecture builds (ARM support)
- Healthcheck endpoint
- Support for additional Canon printer models

## License

This project uses Canon proprietary drivers. Please ensure compliance with Canon's licensing terms.

## Acknowledgments

- Based on [olbat/cupsd](https://hub.docker.com/r/olbat/cupsd) Docker image
- Canon CAPT drivers from Canon official repositories

## Support

For issues and questions:
- Check the [Troubleshooting](#troubleshooting) section
- Review container logs: `docker logs lbp-1120`
- Open an issue on GitHub (if applicable)

---

**Last Updated**: 2025-10-10
**Version**: 1.0
