#!/bin/bash

set -eu

export 1PASSWORD_DOMAIN="https://my.1password.com"
# export 1PASSWORD_ACCOUNT="you@gmail.com"
echo "Enter 1Password account email"
read 1PASSWORD_ACCOUNT
echo "OK, $1PASSWORD_ACCOUNT.  You will be prompted for you 1Password password next..."

echo "Authenticating with 1Password"
export OP_SESSION_my=$(op signin $1PASSWORD_DOMAIN $1PASSWORD_ACCOUNT --output=raw)

echo "Pulling secrets"
# private keys
op get document 'workstation_id_rsa' > id_rsa
op get document 'workstation_id_rsa.pub' > id_rsa.pub

rm ~/.ssh/id_rsa
rm ~/.ssh/id_rsa.pub

ln -s $(pwd)/id_rsa ~/.ssh/id_rsa
ln -s $(pwd)/id_rsa ~/.ssh/id_rsa.pub
chmod 0600 ~/.ssh/id_rsa

echo "Done!"
