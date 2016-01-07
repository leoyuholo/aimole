#!/bin/bash
script_dir=$(readlink -f $(dirname $0))

sudo apt-get install -y build-essential

curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker ${USER}

sudo /bin/sh -c "curl -L https://github.com/docker/compose/releases/download/1.5.2/run.sh > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose

curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
sudo apt-get install -y nodejs

sudo npm install -g node-gyp \
	grunt-cli \
	bower \
	coffee-script \
	jade \
	stylus \
	npm-check-updates
