#!/usr/bin/env bash
# /***************************
# @Author: Xhosa-LEE
# @Contact: lixiaoxmm@163.com
# @Time: 2022/11/20
# @Desc: 用于本地宿主机启动目标docker
# ***************************/
image_name="ubuntu"
if [ -z "$2" ]; then
    image_name="ubuntu"
else
    image_name=$2
fi

start() {
    docker_name=$(docker ps | grep $1 | awk '{print $1}')
    if [ -z $docker_name ]; then
        docker_name=$(docker ps -a | grep $1 | awk '{print $1}')
        if [ -z $docker_name ]; then
            docker run -ti --name $1 -v /home/xiaoli:/root $image_name /bin/bash
            exit 0
        fi
        docker start $1
        docker run -ti --name $1 -v /root:/root $image_name /bin/bash
        exit 0
    fi

    if [ -e $(dirname "$0")/nsenter ]; then
        # with boot2docker, nsenter is not in the PATH but it is in the same folder
        NSENTER=$(dirname "$0")/nsenter
    else
        NSENTER=nsenter
    fi
    if [ -z "$1" ]; then
        echo "Usage: $(basename "$0") CONTAINER [COMMAND [ARG]...]"
        echo ""
        echo "Enters the Docker CONTAINER and executes the specified COMMAND."
        echo "If COMMAND is not specified, runs an interactive shell in CONTAINER."
    else
        PID=$(docker inspect --format "{{.State.Pid}}" "$1")
        if [ -z "$PID" ]; then
            exit 1
        fi
        shift
        OPTS="--target $PID --mount --uts --ipc --net --pid --"
        if [ -z "$1" ]; then
            # No command given.
            # Use su to clear all host environment variables except for TERM,
            # initialize the environment variables HOME, SHELL, USER, LOGNAME, PATH,
            # and start a login shell.
            "$NSENTER" $OPTS su - root
        else
            # Use env to clear all host environment variables.
            "$NSENTER" $OPTS env --ignore-environment -- "$@"
        fi
    fi
}
sudo /etc/init.d/docker start

if [ -z "$1" ]; then
    start 'lixiao'
    exit 1
fi
start $1
