#!/usr/bin/env bash

kube_namespace="thatdot-example"

kubectl delete namespace "$kube_namespace"

# Delete resources out of namespace
kubectl delete clusterrole grafana-clusterrole
kubectl delete clusterrolebinding grafana-clusterrolebinding
