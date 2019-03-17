### install kubectl ###
FROM ubuntu:18.10 as kubectl_builder
RUN apt-get update && apt-get install -y curl ca-certificates
RUN curl -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod 755 /usr/local/bin/kubectl

### install 1password ###
FROM ubuntu:18.10 as onepassword_builder
RUN apt-get update && apt-get install -y curl ca-certificates unzip
RUN curl -sS -o 1password.zip https://cache.agilebits.com/dist/1P/op/pkg/v0.5.5/op_linux_amd64_v0.5.5.zip && unzip 1password.zip op -d /usr/bin &&  rm 1password.zip

### install doctl ###
FROM ubuntu:18.10 as doctl_builder
RUN apt-get update && apt-get install -y wget ca-certificates
RUN wget https://github.com/digitalocean/doctl/releases/download/v1.12.2/doctl-1.12.2-linux-amd64.tar.gz && tar xf doctl-1.12.2-linux-amd64.tar.gz && chmod +x doctl && mv doctl /usr/local/bin && rm doctl-1.12.2-linux-amd64.tar.gz

### install terraform ###
FROM ubuntu:18.10 as terraform_builder
RUN apt-get update && apt-get install -y wget ca-certificates unzip
RUN wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip && unzip terraform_0.11.11_linux_amd64.zip && chmod +x terraform && mv terraform /usr/local/bin && rm terraform_0.11.11_linux_amd64.zip

### OS & Tools ###
FROM ubuntu:18.10
RUN apt-get update && apt-get upgrade -y && apt-get install -qq -y \
  build-essential \
  clang \
	cmake \
	curl \
  git \
  htop \
  iftop \
  less \
  mosh \
  openssh-server \
  vim \
  tmux

ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"
ENV TERM screen-256color
ENV WORKSTATION_SSH_PORT 2222
ENV WORKSTATION_MOSH_PORT_RANGE 60000-60010

RUN mkdir /run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed 's/#Port 22/Port '"$WORKSTATION_SSH_PORT"'/' -i /etc/ssh/sshd_config
RUN sed 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' -i /etc/ssh/sshd_config
RUN sed 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' -i /etc/ssh/sshd_config

### SSH Keys ###
RUN mkdir -p ~/.ssh
COPY authorized_keys /root/.ssh/authorized_keys
RUN chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys

### Developer Tools ###

# node, nvm, and yarn
ENV NODE_VERSION 10
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
RUN . /root/.nvm/nvm.sh && nvm install $NODE_VERSION
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install --no-install-recommends yarn

# rbenv and ruby
ENV RUBY_VERSION 2.5.0
RUN apt-get update && apt-get upgrade -y && apt-get install -qq -y \
  autoconf \
  bison \
  build-essential \
  libssl-dev \
  libyaml-dev \
  libreadline6-dev \
  zlib1g-dev \
  libncurses5-dev \
  libffi-dev \
  libgdbm5 \
  libgdbm-dev
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc
RUN /root/.rbenv/bin/rbenv install $RUBY_VERSION
RUN /root/.rbenv/bin/rbenv global $RUBY_VERSION
RUN /root/.rbenv/bin/rbenv exec gem install bundler

### Workspace ###
RUN mkdir -p ~/workspace

### SSH / MOSH ###
EXPOSE $WORKSTATION_SSH_PORT $WORKSTATION_MOSH_PORT_RANGE/udp

### Entrypoint ###
WORKDIR /root
COPY entrypoint.sh /bin/entrypoint.sh
CMD ["/bin/entrypoint.sh"]
