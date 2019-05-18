#!/bin/bash

set -e

export GIT_PROJECT_URL="https://github.com/evantahler/workstation.git"

echo "Starting up..."

# clone this repo to the machine so it has latest configs
echo "Pulling latest project files from $GIT_PROJECT_URL"
cd ~/workspace
git clone --recursive $GIT_PROJECT_URL

# symlinks
echo "linking 'workstation-setup' command"
ln -s ~/workspace/workstation/workstation-setup.sh /usr/local/bin/workstation-setup

# Run the fnial docker entrypoint command
echo "*** Starting up SSH on port $WORKSTATION_SSH_PORT and Code Server ***"

/usr/sbin/sshd  -D
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start sshd: $status"
  exit $status
fi

# Start the second process
cd /root/workspace && code-server .
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start code-server: $status"
  exit $status
fi