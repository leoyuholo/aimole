#!/bin/bash

script_dir=$(readlink -f $(dirname $0))

container_name="rabbitmq"
arguments=${@:-""}

docker build -t ${USER}:${container_name} ${script_dir}
docker kill ${container_name}
docker rm ${container_name}

echo "container_name:" ${container_name}
echo "arguments": ${arguments}

docker run -d \
	-p 5672:5672 \
	-p 15672:15672 \
	-v ${HOME}/rabbitmq:/var/lib/rabbitmq \
	--name ${container_name} \
	${USER}:${container_name} \
	${arguments}
