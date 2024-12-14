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
helm repo add influxdata https://helm.influxdata.com/
helm upgrade influx influxdata/influxdb \
    --install \
    --namespace "$ns" \
    --values influxdb-values.yaml

# Grafana Helm chart
kubectl apply -f grafana-secret.yaml --namespace "$ns"
helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade grafana grafana/grafana \
    --install \
    --namespace "$ns" \
    --values grafana-values.yaml

