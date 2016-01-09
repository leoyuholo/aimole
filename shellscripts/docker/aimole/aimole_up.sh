#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    # Get absolute path to this script file (for Mac)
    pushd . > /dev/null
    SCRIPT_PATH="${BASH_SOURCE[0]}";
    while([ -h "${SCRIPT_PATH}" ]); do
        cd "`dirname "${SCRIPT_PATH}"`"
        SCRIPT_PATH="$(readlink "`basename "${SCRIPT_PATH}"`")";
    done
    cd "`dirname "${SCRIPT_PATH}"`" > /dev/null
    script_dir="`pwd`"
		cd "../../../" > /dev/null
		app_dir="`pwd`"
    popd  > /dev/null
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    script_dir=$(readlink -f $(dirname $0))
		app_dir=$(readlink -f "$script_dir/../../../")
else
    script_dir=""
		app_dir=""
fi

container_name="aimole"
worker_dir=/tmp/aimole/worker/
argument=""
# argument="--livereload=35728 dev"

mkdir -p $worker_dir

docker build -t ${USER}:$container_name $script_dir
docker kill $container_name
docker rm $container_name

/bin/bash $script_dir/../mongodb/mongodb_up.sh

echo "app_dir:" $app_dir
echo "container_name:" $container_name
echo "argument": $argument

# -u $(id -u):$(getent group docker | cut -d: -f3) \
docker run  -i \
			--link mongodb:mongodb \
			-p 3000:3000 \
			-p 35728:35728 \
			-v $app_dir:/app \
			-v $worker_dir:$worker_dir \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v $(which docker):/bin/docker \
			-v /usr/lib/x86_64-linux-gnu/libapparmor.so.1.1.0:/lib/x86_64-linux-gnu/libapparmor.so.1 \
			--name $container_name \
			${USER}:$container_name \
			$argument
