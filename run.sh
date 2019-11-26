#!/bin/bash
# Inspired by https://github.com/honestbee/drone-kubernetes/blob/master/update.sh
set -e

if [[ ! -z ${KUBERNETES_SERVER} ]]; then
  KUBERNETES_SERVER=$KUBERNETES_SERVER
fi

if [[ ! -z ${KUBERNETES_CA_CERT} ]]; then
  KUBERNETES_CERT=${KUBERNETES_CA_CERT}
fi

if [[ ! -z ${KUBERNETES_CLIENT_CERT} ]]; then
  KUBERNETES_CLIENT_CERT=${KUBERNETES_CLIENT_CERT}
fi

if [[ ! -z ${KUBERNETES_CLIENT_KEY} ]]; then
  KUBERNETES_CLIENT_KEY=${KUBERNETES_CLIENT_KEY}
fi

if [[ ! -z ${KUBECONFIG} ]]; then
  mkdir -p /root/.kube
  echo ${KUBECONFIG} | base64 -d > /root/.kube/config
fi

if [[ ! -z ${KUBECONFIG_URL} ]]; then
  mkdir -p /root/.kube
  wget ${KUBECONFIG_URL} -O /root/.kube/config
fi

if [[ ! -z ${KUBERNETES_CA_CERT} ]]; then
  echo ${KUBERNETES_CA_CERT} | base64 -d >ca.pem
  kubectl config set-cluster default --server=${KUBERNETES_SERVER} --certificate-authority=ca.pem
fi

if [[ ! -z ${KUBERNETES_CLIENT_CERT} ]]; then
  echo ${KUBERNETES_CLIENT_CERT} | base64 -d >client-cert.pem
fi

if [[ ! -z ${KUBERNETES_CLIENT_KEY} ]]; then
  echo ${KUBERNETES_CLIENT_KEY} | base64 -d >client-key.pem
fi

if [[ ! -z ${KUBERNETES__CA_CERT} ]]; then
  echo ${KUBERNETES_CA_CERT} | base64 -d >ca.crt
fi

function setup_certs() {
  kubectl config set-cluster default --server=${KUBERNETES_SERVER} --certificate-authority=ca.crt
  kubectl config set-credentials default --certificate-authority=ca.pem --client-key=client-key.pem --client-certificate=client-cert.pem
  kubectl config set-context default --cluster=default --user=default
  kubectl config use-context default
}

if ! [ -f /root/.kube/config ]; then
  setup_certs
fi

# Run kubectl command
if [[ ! -z ${PLUGIN_KUBECTL} ]]; then
  kubectl --insecure-skip-tls-verify=true ${PLUGIN_KUBECTL}
fi

# Run helm command
if [[ ! -z ${PLUGIN_HELM} ]]; then
  helm ${PLUGIN_HELM}
fi
