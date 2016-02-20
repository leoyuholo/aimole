#!/bin/bash

sudo apt-get install -y build-essential

curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker ${USER}

curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get install -y nodejs

sudo npm install -g node-gyp \
	grunt-cli \
	coffee-script \
	jade \
	stylus \
	npm-check-updates
