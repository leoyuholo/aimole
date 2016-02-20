#!/bin/bash

script_dir=$(readlink -f $(dirname $0))

container_name="mongodb"
arguments=${@:-""}

docker build -t ${USER}:${container_name} ${script_dir}
docker kill ${container_name}
docker rm ${container_name}

echo "container_name:" ${container_name}
echo "arguments": ${arguments}

docker run -d \
	-p 27017:27017 \
	-v ${HOME}/mongodb:/data/db \
	-v ${HOME}/mongodb_backup:/backup \
	--name ${container_name} \
	${USER}:${container_name} \
	${arguments}
