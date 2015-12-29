#!/bin/bash
script_dir=$(readlink -f $(dirname $0))

sudo apt-get install -y build-essential

curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
sudo apt-get install -y nodejs

sudo npm install -g node-gyp \
	grunt-cli \
	bower \
	coffee-script \
	jade \
	stylus \
	npm-check-updates
