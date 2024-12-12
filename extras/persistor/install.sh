#!/usr/bin/env bash

if [[ -z "$KUBE_NAMESPACE" ]]; then
    echo "Error: no namespace specified"
    echo "Usage: KUBE_NAMESPACE=<namespace> ./install.sh"
    echo "Desired namespace is required to run this script."
    echo "If the default namespace is desired, use:"
    echo "    KUBE_NAMESPACE=default ./install.sh"
    echo "Exiting..."
    exit 1
fi

ns="$KUBE_NAMESPACE"

# Cassandra Helm chart
# Used as persistor for streaming graph (required).
# Although it is possible to use any cassandra-compatible 
#   database such as ScyllaDB.
helm upgrade \
    --install --wait --timeout 10m0s \
    --version 11.3.7 \
    --namespace "$ns" \
    --set replicaCount=1 \
    --set dbUser.user=cassandra \
    --set dbUser.password=cassandra \
    --set persistence.size=100Gi \
    --set resources.requests.cpu=3 \
    --set resources.requests.memory=7Gi \
    --set resources.limits.cpu=3 \
    --set resources.limits.memory=7Gi \
    quine-enterprise-store \
    oci://registry-1.docker.io/bitnamicharts/cassandra
