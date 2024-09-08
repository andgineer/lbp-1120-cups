# lbp-1120-cups

Docker container for running a CUPS (Common Unix Printing System) 
server with support for the Canon LBP-1120 printer
and Avahi for network discovery.

### What is CUPS?
CUPS (Common Unix Printing System) is a modular printing system for Unix-like computer operating 
systems which allows a computer to act as a print server. 

A computer running CUPS is a host that can accept print jobs from client computers, process them, 
and send them to the appropriate printer.

### What is Avahi?
Avahi is a system which facilitates service discovery on a local network via the mDNS/DNS-SD protocol suite.

This enables you to plug your computer into a network and instantly be able to view other people 
who you can chat with, find printers to print to or find files being shared. 

In the context of this project, Avahi allows for easier discovery of the CUPS print server 
on your local network.

### Features

- CUPS server in a Docker container
- Preconfigured support for Canon LBP-1120 printer
- Avahi daemon for network discovery

### Quick Start

#### Building the Container

    docker build -t lbp-1120-cups .

#### Running the Container

    docker run \
        -d \
        -p 631:631 \
        -p 5353:5353 \
        -v /var/run/dbus:/var/run/dbus \
        --name lbp-1120 \
        lbp-1120-cups

### Accessing CUPS
Once the container is running, you can access the CUPS web interface at http://localhost:631.
