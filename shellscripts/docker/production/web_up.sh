#!/bin/bash

script_dir=$(readlink -f $(dirname $0))
host_ip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

container_name="aimole-web"
app_dir=$(readlink -f "${script_dir}/../../../")
arguments='web'

worker_dir=/tmp/worker/
mkdir -p ${worker_dir}

if [ "$1" == "--help" ]
then
	echo "usage: $0 master_ip"
	exit
fi

master_ip=$([ "$1" == "" ] && echo $host_ip || echo "$1")

docker build -t ${USER}:${container_name} ${script_dir}
docker kill ${container_name}
docker rm ${container_name}

sandboxrun=tomlau10/sandbox-run
if [ -z "$(docker images -a | grep ${sandboxrun})" ]; then
	echo "${sandboxrun} docker image exists, pulling..."
	docker pull ${sandboxrun}
else
	echo "${sandboxrun} docker image exists, skip pulling."
fi

echo "container_name:" ${container_name}
echo "app_dir:" ${app_dir}
echo "arguments": ${arguments}

docker run  -d \
			-e NODE_ENV=production \
			-u $(id -u):$(getent group docker | cut -d: -f3) \
			-e "WORKER_DIR=${worker_dir}"\
			-e "HOST_IP="$master_ip \
			-p 80:3000 \
			-v ${app_dir}:/app \
			-v ${worker_dir}:${worker_dir} \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v $(which docker):/bin/docker \
			-v /usr/lib/x86_64-linux-gnu/libapparmor.so.1.1.0:/lib/x86_64-linux-gnu/libapparmor.so.1 \
			--restart="always" \
			--name ${container_name} \
			${USER}:${container_name} \
			${arguments}
