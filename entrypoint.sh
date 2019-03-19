#!/bin/bash

set -e

# clone this repo to the machine so it has latest configs
cd ~/workspace
git clone --recursive https://github.com/evantahler/workstation.git

# symlinks
ln -s ~/workspace/workstation/pull-secrets.sh /usr/local/bin/pull-secrets

# Run the fnial docker entrypoint command
echo "*** starting up SSH on port $WORKSTATION_SSH_PORT ***"
/usr/sbin/sshd -D
