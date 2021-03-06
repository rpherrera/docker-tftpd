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

docker build \
  "${ABSOLUTE_PATH}/.." \
  -f "${ABSOLUTE_PATH}/../Dockerfile" \
  -t "${DOCKER_IMAGE_FULL}"

docker tag "${DOCKER_IMAGE_FULL}" "${DOCKER_IMAGE_SHORT}"
docker tag "${DOCKER_IMAGE_FULL}" "${DOCKER_IMAGE_LATEST}"