#!/usr/bin/env bash

DIR=$(dirname "$0")
source ${DIR}/common/logger.sh

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
  local _repo=$(git remote get-url origin | sed 's|:|/|; s|git@|https://|')
  local _branch=$(git branch --show-current)
  local _url=${_repo}\#${_branch}

  log-info "Deploying From: ${_url}"
  dd-oc new-app openshift/nodejs:12~${_url} --name="root-config" && \
  dd-oc expose svc/root-config
}

undeploy() {
  if dd-oc get pod --selector app=root-config > /dev/null 2>&1; then
    dd-oc delete all --selector app=root-config
  fi
}

# execute
undeploy
deploy
