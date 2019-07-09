## Source vsCode from CodeServer image
FROM codercom/code-server:1.621

## Build our Ubuntu Image
FROM ubuntu:18.10

ARG BUILD_SERVER_SSH_PUBLIC_KEY

ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"
ENV TERM screen-256color
ENV WORKSTATION_SSH_PORT 2222
ENV WORKSTATION_MOSH_PORT_RANGE 60000-60010
ENV ONE_PASSWORD_VERSION v0.5.5
ENV NODE_VERSION 10
ENV RUBY_VERSION 2.5.0
ENV CODE_SERVER_VERSION 1.604-vsc1.32.0
ENV CODE_SERVER_PORT 8443

### OS & Tools ###
RUN apt-get update && apt-get upgrade -y && apt-get install -qq -y \
  build-essential \
  clang \
  cmake \
  curl \
  git \
  jq \
  htop \
  iftop \
  less \
  mosh \
  net-tools \
  openssh-server \
  vim \
  tmux

### SSH & Keys ###
RUN mkdir /run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed 's/#Port 22/Port '"$WORKSTATION_SSH_PORT"'/' -i /etc/ssh/sshd_config
RUN sed 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' -i /etc/ssh/sshd_config
RUN sed 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' -i /etc/ssh/sshd_config

RUN mkdir -p ~/.ssh
RUN echo "$BUILD_SERVER_SSH_PUBLIC_KEY" > /root/.ssh/authorized_keys
RUN chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys

### install 1password ###
RUN apt-get update && apt-get install -y curl ca-certificates unzip
RUN curl -sS -o 1password.zip https://cache.agilebits.com/dist/1P/op/pkg/$ONE_PASSWORD_VERSION/op_linux_amd64_$ONE_PASSWORD_VERSION.zip && unzip 1password.zip op -d /usr/bin && rm 1password.zip

### Developer Tools ###

# code server
RUN mkdir -p /root/.local/share/code-server
RUN mkdir -p /root/.cache/code-server
COPY --from=0 /usr/local/bin/code-server /usr/local/bin/code-server
# Hack needed -> https://github.com/cdr/code-server/issues/499
RUN mkdir -p /User/workspaceStorage

# node, nvm, and yarn
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
RUN . /root/.nvm/nvm.sh && nvm install $NODE_VERSION
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install --no-install-recommends yarn

# rbenv and ruby
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
EXPOSE $WORKSTATION_SSH_PORT $WORKSTATION_MOSH_PORT_RANGE/udp $CODE_SERVER_PORT

### Entrypoint ###
WORKDIR /root
COPY entrypoint.sh /bin/entrypoint.sh
CMD ["/bin/entrypoint.sh"]
