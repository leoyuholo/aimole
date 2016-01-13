#!/bin/bash

script_dir=$(readlink -f $(dirname $0))

container_name="aimole"
worker_dir=/tmp/aimole/worker/
app_dir=$(readlink -f "$script_dir/../../../")
argument="dev"

mkdir -p $worker_dir

docker build -t ${USER}:$container_name $script_dir
docker kill $container_name
docker rm $container_name

/bin/bash $script_dir/../mongodb/mongodb_up.sh

echo "app_dir:" $app_dir
echo "container_name:" $container_name
echo "argument": $argument

docker run  -i \
			-u $(id -u):$(getent group docker | cut -d: -f3) \
			--link mongodb:mongodb \
			-p 3000:3000 \
			-p 35729:35729 \
			-v $app_dir:/app \
			-v $worker_dir:$worker_dir \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v $(which docker):/bin/docker \
			-v /usr/lib/x86_64-linux-gnu/libapparmor.so.1.1.0:/lib/x86_64-linux-gnu/libapparmor.so.1 \
			--name $container_name \
			${USER}:$container_name \
			$argument
