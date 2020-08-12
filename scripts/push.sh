#!/usr/bin/env bash

DIR=$(dirname "$0")
source ${DIR}/common/logger.sh

USAGE="Usage: "`basename $0`" [deploy|undeploy]"
APP_NAME=root-config

dd-oc() {
  if [ -z "${NAMESPACE}" ]; then
    log-error "you must set the NAMESPACE variable in your environment"
    exit 1
  fi

  log-info "oc --namespace ${NAMESPACE} $@"
  oc --namespace ${NAMESPACE} "$@"
}

# push the dist directory up to given location
deploy() {
  local _repo=$(git remote get-url origin)
  if [[ ${_repo} == git@* ]]; then
    _repo=$(echo ${_repo} |sed 's|:|/|; s|git@|https://|')
  fi

  local _branch=$(git branch --show-current)
  local _url=${_repo}\#${_branch}

  log-info "Deploying From: ${_url}"
  if dd-oc get pods |grep ${APP_NAME} > /dev/null 2>&1; then
    # do this if we are updating deployment
    log-info "New Deployment"
    dd-oc start-build ${APP_NAME}
    dd-oc rollout latest dc/${APP_NAME}
  else
    # do this for new deployment
    log-info "Update Existing Deployment"
    dd-oc new-app openshift/nodejs:12~${_url} --name=${APP_NAME} && \
    dd-oc expose svc/${APP_NAME}
  fi
}

undeploy() {
  if dd-oc get pods |grep ${APP_NAME} > /dev/null 2>&1; then
    dd-oc delete all --selector app=${APP_NAME}
  fi
}

# execute
case $1 in
  undeploy)
    undeploy
  ;;
  deploy)
    deploy
  ;;
  *)
    echo ${USAGE}
  ;;
esac
