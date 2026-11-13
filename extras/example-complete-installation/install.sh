#!/usr/bin/env bash

set -euo pipefail

# Run from this directory so the relative paths below resolve
cd "$(dirname "$0")"

kube_namespace="thatdot-example"

# The license key and registry secrets must be created first (see README.md)
if ! kubectl get secret --namespace "$kube_namespace" \
    quine-enterprise-license quine-enterprise-registry novelty-license novelty-registry > /dev/null; then
    echo "Error: could not read the secrets in namespace \"$kube_namespace\""
    echo "Create the namespace and the secrets described in README.md, then run this script again."
    echo "Exiting..."
    exit 1
fi

# Kafka cluster to use for ingest/output
# RedPanda (Kafka API compatible) Helm chart
helm upgrade redpanda redpanda \
    --repo https://charts.redpanda.com \
    --install \
    --namespace "$kube_namespace" \
    --version 5.8.11 \
    --values redpanda-values.yaml


# Metrics and Monitoring
# InfluxDB Helm chart
helm upgrade influx influxdb \
    --repo https://helm.influxdata.com/ \
    --install \
    --namespace "$kube_namespace" \
    --values influxdb-values.yaml

# Grafana Helm chart
kubectl apply -f grafana-secret.yaml --namespace "$kube_namespace"
helm upgrade grafana grafana \
    --repo https://grafana-community.github.io/helm-charts \
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
    ../persistor/cassandra

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
