#!/usr/bin/env bash 
ORIGIN_DOCKER="lixiaoxmm/ubuntu22.10:original"
IMG="dockerproxy.com/${ORIGIN_DOCKER}"
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"


function show_usage () {
cat <<EOF
  Usage: $(basename $0) [options] ...
  DEFAULT OPTIONS:
      auto_intall            auto install docker
  OPTIONS:
      install_tools          install tools.
EOF
  exit 0
}



function hosts()
{
  echo '
  199.232.28.133 raw.githubusercontent.com 
  192.30.255.112 www.github.com
  192.30.255.112 github.com
  ' >> /etc/hosts
}


function install_tools()
{
  apt-get -y update
  apt-get -y upgrade
  #install llvm clang
  apt-get -y install make vim pip sudo wget curl pkg-config  unzip gnutls-bin lsb-release llvm clang
  # in docker
  cp -rf ${ROOT_DIR}/tools /tools

}

function start_docker () {
  sudo service docker start 
  # pull
  docker pull $IMG 

  docker run -ti -d --name xengine_docker_install -v $ROOT_DIR:/tmp $IMG /bin/bash

  docker exec xengine_docker_install bash -c "cd /tmp/&&./install_tools.sh install_tools"
}


function main() {
  local cmd="$1"
  if [ "$#" -eq 0 ]; then
    cmd="auto_intall"
  fi


  case "${cmd}" in
  auto_intall)
    start_docker "$@"
    ;;
  install_tools)
    # hosts
    hosts
    # install tools
    install_tools "$@"
    ;;
  *)
    show_usage
    ;;
  esac

  docker ps -a
  printf "\nxengine_docker_install done!\n usage push_images.sh push to hub.docker.\n"
}

main "$@"