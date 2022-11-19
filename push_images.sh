#!/bin/bash
# /***************************
# @Author: Xhosa-LEE
# @Contact: lixiaoxmm@163.com
# @Time: 2022/11/20
# @Desc: 用于发布镜像到hub.docker
# ***************************/
function main() {
  # login
  docker login
  CURRENT=`date "+%Y-%m-%d %H:%M:%S"`
  TIME_STAMP=`date -d "$CURRENT" +%s`
  TAG_COMMIT=$1
  TAG_NAME=$2"_"${TIME_STAMP}
  AUTHOR=$(whoami)
  COMMIT_MESSAFE="save "${TAG_NAME}
  docker commit ${TAG_COMMIT} ${TAG_NAME} &&
    IMAGES_ID=$(docker images | grep "${TIME_STAMP}"| awk '{print $3}') &&
    docker tag ${IMAGES_ID} ${TAG_NAME} && docker push ${TAG_NAME}
}

main "$@"
