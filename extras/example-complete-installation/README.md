## thatDot Helm Charts Example Complete Installation

### Overview

This directory contains an example installation of thatDot Quine Enterprise and
Novelty. The included Cassandra persistor is required by the thatDot Quine
Enterprise cluster. Also included are optional components of a RedPanda (Kafka)
cluster for ingest/output and a monitoring stack consisting of InfluxDB and
Grafana.

### Prerequisites

* Sign up for Novelty and Streaming Graph Trial at
  [thatdot.com](https://www.thatdot.com/free-trial/)
  * Add email address and API key for Streaming Graph to
    streaming-graph-values.yaml
  * Add email address and API key for Novelty to novelty-values.yaml
  * **NOTE:** You will receive the API key via email. A separate key must be
    used for each unique product.
* Kubernetes cluster (EKS recommended)
  * Clusterrole with permissions to create a new namespace and resources under it.
  * kubectl
  * helm
* Storage driver
  * For EKS, [ebs-csi-driver](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html) addon is recommended

### Usage

To install everything in the namespace "thatdot-example":

```
./install.sh
```

To delete everything in the namespace (including persisted disks):

```
./uninstall.sh
```

#### Access Quine Enterprise UI

Port forward the deployment to access locally:

```
kubectl -n thatdot-example port-forward deploy/quine-enterprise 8080:8080
```

Use browser at `http://localhost:8080`. Or access API via curl:

```
# Example, to get cluster status
curl http://localhost:8080/api/v1/admin/status
```

#### Access RedPanda Console

Port forward the deployment to access locally:

```
kubectl -n thatdot-example port-forward deploy/redpanda-console 8080:8080
```

#### Access Grafana Dashboard

Port forward the deployment to access locally:

```
kubectl -n thatdot-example port-forward deploy/grafana 3000:3000
```

Log into the Grafana server with browser. "Quine" dashboard is preconfigured.

**Note:** the defualt username/password is intended for internal use only. A stronger
password should be used if exposing the Grafana to the open internet.

* Username: `admin`

* Password: `admin`

### Further Considerations

This installations have been provided mostly with small requests/limits. Please
consider setting the requests/limits to reasonable values for your cluster.
