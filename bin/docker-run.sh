#!/bin/bash -ex

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f "${ABSOLUTE_PATH}/docker-config.sh" ]; then
  . "${ABSOLUTE_PATH}/docker-config.sh"
elif [ -f "/vagrant/bin/docker-config.sh" ]; then
  . "/vagrant/bin/docker-config.sh"
else
  echo 'ERROR: No "bin/docker-config.sh" file found.'
  exit 1
fi

if [ -d "${ABSOLUTE_PATH}/tftpboot" ]; then
  TFTPBOOT_DIR="${ABSOLUTE_PATH}/tftpboot"
elif [ -d "/vagrant/tftpboot" ]; then
  TFTPBOOT_DIR="/vagrant/tftpboot"
else
  echo 'ERROR: No "tftpboot" directory found.'
  exit 1
fi

docker stop tftpd 2>/dev/null || true && docker rm tftpd 2>/dev/null || true

docker run \
  --detach \
  --rm \
  --cap-add=NET_ADMIN \
  --net=host \
  -v ${TFTPBOOT_DIR}:/tftpboot \
  --name=tftpd \
  ${DOCKER_IMAGE_FULL}