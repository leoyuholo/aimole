#!/bin/bash

script_dir=$(readlink -f $(dirname $0))

container_name="aimole"
app_dir=$(readlink -f "${script_dir}/../../../")
arguments=${@:-dev}

worker_dir=/tmp/worker/
mkdir -p ${worker_dir}

docker build -t ${USER}:${container_name} ${script_dir}
docker kill ${container_name}
docker rm ${container_name}

/bin/bash $script_dir/../mongodb/mongodb_up.sh
/bin/bash $script_dir/../rabbitmq/rabbitmq_up.sh

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

docker run  -i \
			-t \
			-u $(id -u):$(getent group docker | cut -d: -f3) \
			-e "WORKER_DIR=${worker_dir}"\
			--link mongodb:mongodb \
			--link rabbitmq:rabbitmq \
			-p 3000:3000 \
			-p 35729:35729 \
			-v ${app_dir}:/app \
			-v ${worker_dir}:${worker_dir} \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v $(which docker):/bin/docker:ro \
			-v /usr/lib/x86_64-linux-gnu/libapparmor.so.1.1.0:/lib/x86_64-linux-gnu/libapparmor.so.1:ro \
			-v /lib/x86_64-linux-gnu/libsystemd-journal.so.0:/lib/x86_64-linux-gnu/libsystemd-journal.so.0:ro \
			-v /lib/x86_64-linux-gnu/libcgmanager.so.0:/lib/x86_64-linux-gnu/libcgmanager.so.0:ro \
			-v /lib/x86_64-linux-gnu/libnih.so.1:/lib/x86_64-linux-gnu/libnih.so.1:ro \
			-v /lib/x86_64-linux-gnu/libnih-dbus.so.1:/lib/x86_64-linux-gnu/libnih-dbus.so.1:ro \
			-v /lib/x86_64-linux-gnu/libdbus-1.so.3:/lib/x86_64-linux-gnu/libdbus-1.so.3:ro \
			-v /lib/x86_64-linux-gnu/libgcrypt.so.11:/lib/x86_64-linux-gnu/libgcrypt.so.11:ro \
			--name ${container_name} \
			${USER}:${container_name} \
			${arguments}
