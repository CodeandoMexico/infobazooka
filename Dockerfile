# Yet another sinatra container
#
# Build:
#   docker build -t CodeandoMexico/sinatra .
# Usage:
#   docker run --rm -it CodeandoMexico/sinatra

FROM ubuntu:14.04

MAINTAINER Rodolfo Wilhelmy <@rodowi>

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git-core \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
  && git clone https://github.com/sstephenson/rbenv.git ~/.rbenv \
  && git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build \
  && git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV RUBY_VERSION=2.1.5

# Add rbenv configuration to .bashrc
RUN \
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc

# Install Ruby and set the working version as default
RUN \
  rbenv install $RUBY_VERSION -k && \
  rbenv global $RUBY_VERSION

# Working directory
RUN mkdir /app
WORKDIR /app

# Caching bundler
COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install

# Deploy
COPY . /app
