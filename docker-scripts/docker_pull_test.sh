#!/bin/sh

# Registries
HUB=hub.docker.prod.walmart.com
GRC=gcr.docker.prod.walmart.com
QUAY=quay.docker.prod.walmart.com

# Test images
hubImage='google/cloud-sdk:171.0.0-alpine'
grcImage='heptio-images/sonobuoy-plugin-systemd-logs:v0.1'
quayImage='calico/cni:v1.10.0'

function pulltest() {
  echo;echo "HUB pull test..."
  time docker pull ${HUB}/${hubImage}
  echo;echo "GRC pull test..."
  time docker pull ${GRC}/${grcImage}
  echo;echo "QUAY pull test..."
  time docker pull ${QUAY}/${quayImage}
}

function cleanup (){
  echo;echo "Delete all images..."
  docker rmi ${HUB}/${hubImage}
  docker rmi ${GRC}/${grcImage}
  docker rmi ${QUAY}/${quayImage}
}

pulltest
sleep 5
cleanup
echo;echo
