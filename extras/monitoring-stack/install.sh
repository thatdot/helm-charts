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

# Metrics and Monitoring

# InfluxDB Helm chart
helm upgrade influx influxdb \
    --repo https://helm.influxdata.com/ \
    --install \
    --namespace "$ns" \
    --values influxdb-values.yaml

# Grafana Helm chart
kubectl apply -f grafana-secret.yaml --namespace "$ns"
helm upgrade grafana grafana \
    --repo https://grafana-community.github.io/helm-charts \
    --install \
    --namespace "$ns" \
    --values grafana-values.yaml

