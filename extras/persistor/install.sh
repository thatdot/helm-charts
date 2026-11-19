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
# Used as persistor for Quine Enterprise (required) and, optionally, Novelty.
# Any Cassandra-compatible database (e.g. ScyllaDB) also works.
helm upgrade \
    --install --wait --timeout 20m0s \
    --namespace "$ns" \
    --set replicaCount=3 \
    quine-enterprise-store \
    "$(dirname "$0")/cassandra"
