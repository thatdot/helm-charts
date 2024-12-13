#!/usr/bin/env bash

kube_namespace="thatdot-example"

kubectl create namespace "$kube_namespace"

# Kafka cluster to use for ingest/output
# RedPanda (Kafka API compatible) Helm chart
helm repo add redpanda https://charts.redpanda.com
helm upgrade redpanda redpanda/redpanda \
    --install \
    --namespace "$kube_namespace" \
    --version 5.8.11 \
    --values redpanda-values.yaml


# Metrics and Monitoring
# InfluxDB Helm chart
helm repo add influxdata https://helm.influxdata.com/
helm upgrade influx influxdata/influxdb \
    --install \
    --namespace "$kube_namespace" \
    --values influxdb-values.yaml

# Grafana Helm chart
kubectl apply -f grafana-secret.yaml --namespace "$kube_namespace"
helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade grafana grafana/grafana \
    --install \
    --namespace "$kube_namespace" \
    --values grafana-values.yaml

# Add thatDot Helm repo
helm repo add thatdot https://helm.thatdot.com

# Novelty Helm chart
helm upgrade \
    --install \
    --namespace "$kube_namespace" \
    novelty \
    thatdot/novelty \
    --values novelty-values.yaml

# Cassandra Helm chart
# Used as persistor for Quine Enterprise (required).
# Although it is possible to use any cassandra-compatible 
#   database such as ScyllaDB.
helm upgrade \
    --install --wait --timeout 10m0s \
    --version 11.3.7 \
    --namespace "$kube_namespace" \
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

# Quine Enterprise Helm chart
helm upgrade \
    --install \
    --namespace "$kube_namespace" \
    quine-enterprise \
    thatdot/quine-enterprise \
    --values quine-enterprise-values.yaml

