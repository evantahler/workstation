# Evan's Remote Workstation

A Public repo that contains everything you need to be a developer on-the-go!

Features:
* Syncing passwords in a safe way via 1Password
* Authentication with your code via Github and SSH Keys
* A Visual, remote code editor via VSCode and code-server
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
```
# build the image
docker build -t workstation:latest .

# run the image
docker run --name workstation -p "2222:2222" workstation:latest

# connect
ssh root@localhost -p 2222
mosh root@localhost -p 2222
```

### Misc
* kill all running docker instances `docker kill $(docker ps -q)`
