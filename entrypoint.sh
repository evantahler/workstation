#!/bin/bash

set -e

# clone this repo to the machine so it has latest configs
cd ~/workspace
git clone --recursive https://github.com/evntahler/workstation.git

# symlinks

# Run the fnial docker entrypoint command
/usr/sbin/sshd -D
