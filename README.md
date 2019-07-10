# Remote Workstation
*A Public repo that contains everything you need to be a developer on-the-go!*

Features:
* Syncing passwords in a safe way via 1Password
* Authentication with your code via Github and SSH Keys
* A **visual**, remote code editor via VSCode and [code-server](https://github.com/codercom/code-server)
* Safe authentication to your image via SSH
* All the normal Ubuntu/Unix tools you know and love

Inspired by:
* https://arslan.io/2019/01/07/using-the-ipad-pro-as-my-development-machine/
* https://github.com/fatih/dotfiles/tree/master/workstation

## 1Password and SSH
This Docker image will use 1Password to sync SSH keys!  This assumes:
* `workstation_id_rsa` is a 1Password document (note the type should be `document`, not `note`, etc)
* `workstation_id_rsa.pub` is a 1Password document (note the type should be `document`, not `note`, etc)
* generate these new SSH keys via `ssh-keygen -t rsa -b 4096 -C "you@example.com"`

## SSH via mosh:
```
$ mosh --no-init --ssh="ssh -o StrictHostKeyChecking=no -i ~/.ssh/github_rsa -p 3222" root@<DROPLET_IP> -- tmux new-session -AD -s main
$ setup-worstation # I will pull secrets in via 1Password and prompt you for various account information
```

## Developing Locally
Ensure you have an `~/.ssh/id_rsa.pub` on the host you are building the image from.  It will become the image's `authorized_hosts` file.

```
# build the image (with your SSH key authorized)
docker build -t workstation:latest . --build-arg BUILD_SERVER_SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"

# run the image
docker run --name workstation -p "2222:2222" -p "8443:8443" workstation:latest

# connect
ssh root@localhost -p 2222
mosh root@localhost -p 2222

# (optional) push it
docker tag workstation:latest {yourname}/workstation:latest
docker push {yourname}/workstation:latest
```

## Code Server
1. Navigate to the folder you want to open and then run `code-server` in the directory.  ie, `cd ~/workspace/workstation/ && code-server`.
2. If you want to keep the server running, use `tmux` or `sceen`.
3. Running this command will generate a password for the web interface.

## Build Options
```
ENV WORKSTATION_SSH_PORT 2222
ENV WORKSTATION_MOSH_PORT_RANGE 60000-60010
ENV ONE_PASSWORD_VERSION v0.5.5
ENV NODE_VERSION 10
ENV RUBY_VERSION 2.5.0
ENV CODE_SERVER_VERSION 1.604-vsc1.32.0
ENV CODE_SERVER_PORT 8443
```
