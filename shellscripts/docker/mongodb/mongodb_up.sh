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
    popd  > /dev/null
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    script_dir=$(readlink -f $(dirname $0))
else
    script_dir=""
fi

container_name="mongodb"
argument=""

docker build -t ${USER}:$container_name $script_dir
docker kill ${container_name}
docker rm ${container_name}

docker run -d \
	-p 27017:27017 \
	-v mongodb:/data/db \
	-v mongodb_backup:/backup \
	--name ${container_name} \
	${USER}:${container_name} \
	${argument}
