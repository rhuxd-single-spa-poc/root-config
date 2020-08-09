#!/usr/bin/env bash

DIR=$(dirname "$0")
source ${DIR}/common/logger.sh

VERSION=${VERSION:-$(git rev-parse HEAD)}
DIST_DIR=dist
FILENAME=react-mf-root-config.js

if [ -z "${NAMESPACE}" ]; then
  log-err "You must set NAMESPACE in you environment!
  example:
          export NAMESPACE=foobar"
  exit 1
fi

# push the dist directory up to given location
deploy() {
  local _resource_host=$(oc --namespace ${NAMESPACE} get route --selector=app=nginx -o=jsonpath={.items..status.ingress..host})
  local _pod_name=$(oc --namespace ${NAMESPACE} get pods --selector=app=nginx --field-selector=status.phase=Running -o=jsonpath={.items..metadata.name})
  log-debug "POD NAME: ${_pod_name}"

  log-info "uploading version: ${VERSION}"
  log-debug "tar cvf - ${VERSION} | oc --namespace ${NAMESPACE} rsh ${_pod_name} tar xofC - /usr/share/nginx/html"
  cd ${DIST_DIR}
  tar cvf - ${VERSION} | oc --namespace ${NAMESPACE} rsh ${_pod_name} tar xofC - /usr/share/nginx/html --warning=no-timestamp
  log-info "NEW RESOURCE CRETATED: http://${_resource_host}/${VERSION}/${FILENAME}"
  cd ..
}

copyDist() {
  if [ -d ${DIST_DIR}/${VERSION} ]; then
    rm -rf ${DIST_DIR}/${VERSION}
  fi

  log-debug "rsync -avr --exclude="${DIST_DIR}/${VERSION}" ${DIST_DIR}/* ${DIST_DIR}/${VERSION}/"
  rsync -avr --exclude="${DIST_DIR}/${VERSION}" ${DIST_DIR}/* ${DIST_DIR}/${VERSION}/
}

clean() {
  log-debug "rm -rf ${DIST_DIR}/${VERSION}/"
  rm -rf ${DIST_DIR}/${VERSION}/
}

# execute
clean
copyDist
deploy
clean
