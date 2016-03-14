#!/bin/bash

sudo apt-get install -y build-essential

sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get install -y libstdc++-4.9-dev

curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker ${USER}

curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
sudo apt-get install -y nodejs

sudo npm install -g node-gyp
