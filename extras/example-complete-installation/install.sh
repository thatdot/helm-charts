#!/usr/bin/env bash

set -euo pipefail

# Run from this directory so the relative paths below resolve
cd "$(dirname "$0")"

kube_namespace="thatdot-example"

# The license key and registry secrets must be created first (see README.md)
for secret in quine-enterprise-license quine-enterprise-registry novelty-license novelty-registry; do
    if ! kubectl get secret "$secret" --namespace "$kube_namespace" > /dev/null; then
        echo "Error: could not read secret \"$secret\" in namespace \"$kube_namespace\""
        echo "Create the namespace and the secrets described in README.md, then run this script again."
        echo "Exiting..."
        exit 1
    fi
done

# Kafka cluster to use for ingest/output
# RedPanda (Kafka API compatible) Helm chart
helm repo add redpanda https://charts.redpanda.com --force-update
helm upgrade redpanda redpanda/redpanda \
    --install \
    --namespace "$kube_namespace" \
    --version 5.8.11 \
    --values redpanda-values.yaml


# Metrics and Monitoring
# InfluxDB Helm chart
helm repo add influxdata https://helm.influxdata.com/ --force-update
helm upgrade influx influxdata/influxdb \
    --install \
    --namespace "$kube_namespace" \
    --values influxdb-values.yaml

# Grafana Helm chart
kubectl apply -f grafana-secret.yaml --namespace "$kube_namespace"
helm repo add grafana-community https://grafana-community.github.io/helm-charts --force-update
helm upgrade grafana grafana-community/grafana \
    --install \
    --namespace "$kube_namespace" \
    --values grafana-values.yaml

# Cassandra Helm chart (local chart in ../persistor/cassandra, official Apache Cassandra image)
# Used as persistor for Quine Enterprise (required) and Novelty.
# Although it is possible to use any cassandra-compatible 
#   database such as ScyllaDB.
helm upgrade \
    --install --wait --timeout 20m0s \
    --namespace "$kube_namespace" \
    quine-enterprise-store \
    ../persistor/cassandra \
    --values cassandra-values.yaml

# Novelty Helm chart
helm upgrade \
    --install --wait --timeout 10m0s \
    --namespace "$kube_namespace" \
    novelty \
    ../../charts/novelty \
    --values novelty-values.yaml

# Quine Enterprise Helm chart
helm upgrade \
    --install --wait --timeout 10m0s \
    --namespace "$kube_namespace" \
    quine-enterprise \
    ../../charts/quine-enterprise \
    --values quine-enterprise-values.yaml
