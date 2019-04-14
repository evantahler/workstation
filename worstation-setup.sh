#!/bin/bash

set -eu

export ONE_PASSWORD_DOMAIN="https://my.1password.com"
# export ONE_PASSWORD_ACCOUNT="you@gmail.com"
echo "Enter 1Password account email"
read ONE_PASSWORD_ACCOUNT
echo "OK, $ONE_PASSWORD_ACCOUNT.  You will be prompted for you 1Password password next..."

echo "Authenticating with 1Password"
export OP_SESSION_my=$(op signin $ONE_PASSWORD_DOMAIN $ONE_PASSWORD_ACCOUNT --output=raw)

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
