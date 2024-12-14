#!/usr/bin/env bash

if [[ -z "$KUBE_NAMESPACE" ]]; then
    echo "Error: no namespace specified"
    echo "Usage: KUBE_NAMESPACE=<namespace> ./uninstall.sh"
    echo "Desired namespace is required to run this script."
    echo "If the default namespace is desired, use:"
    echo "    KUBE_NAMESPACE=default ./uninstall.sh"
    echo "Exiting..."
    exit 1
fi

ns="$KUBE_NAMESPACE"

helm --namespace "$ns" uninstall influx
helm --namespace "$ns" uninstall grafana

# Delete Grafana resources out of namespace
kubectl delete clusterrole grafana-clusterrole
kubectl delete clusterrolebinding grafana-clusterrolebinding