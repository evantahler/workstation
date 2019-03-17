# Evan's Remote Workstation

Inspired by:
* https://arslan.io/2019/01/07/using-the-ipad-pro-as-my-development-machine/
* https://github.com/fatih/dotfiles/tree/master/workstation

## Install
Create workstation droplet
```
$ export DIGITALOCEAN_TOKEN="Put Your Token Here"
$ terraform plan
$ terraform apply -auto-approve
```

## SSH via mosh:
```
$ mosh --no-init --ssh="ssh -o StrictHostKeyChecking=no -i ~/.ssh/github_rsa -p 3222" root@<DROPLET_IP> -- tmux new-session -AD -s main
$ cd ~/secrets && ./pull-secrets.sh
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
