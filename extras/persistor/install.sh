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

# Cassandra Helm chart (local chart in ./cassandra, official Apache Cassandra image)
# Used as persistor for streaming graph (required).
# Although it is possible to use any cassandra-compatible 
#   database such as ScyllaDB.
helm upgrade \
    --install --wait --timeout 20m0s \
    --namespace "$ns" \
    --set replicaCount=3 \
    --set persistence.size=100Gi \
    --set resources.requests.cpu=3 \
    --set resources.requests.memory=7Gi \
    --set resources.limits.cpu=3 \
    --set resources.limits.memory=7Gi \
    --set maxHeapSize=3G \
    --set heapNewSize=800M \
    quine-enterprise-store \
    "$(dirname "$0")/cassandra"
