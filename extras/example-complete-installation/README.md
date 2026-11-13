## thatDot Helm Charts Example Complete Installation

### Overview

This directory contains an example installation of thatDot Quine Enterprise and
Novelty. The included Cassandra persistor is required by the thatDot Quine
Enterprise cluster and is also used by Novelty. Also included are optional components of a RedPanda (Kafka)
cluster for ingest/output and a monitoring stack consisting of InfluxDB and
Grafana.

### Prerequisites

* Obtain license keys for Novelty and Quine Enterprise from thatDot
  * License keys are provided as part of an evaluation agreement or purchase order
  * To schedule a demo or purchase a license:
    * Request a demo: [https://www.thatdot.com/request-a-demo/](https://www.thatdot.com/request-a-demo/)
    * Email sales: [sales@thatdot.com](mailto:sales@thatdot.com)
    * Contact thatDot: [https://www.thatdot.com/contact-us/](https://www.thatdot.com/contact-us/)
  * thatDot provides a client id together with each license key
* Kubernetes cluster (EKS recommended)
  * Clusterrole with permissions to create a new namespace and resources under it.
  * kubectl
  * helm
* Storage driver
  * For EKS, [ebs-csi-driver](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html) addon is recommended

**Note:** earlier versions of this example installed the Bitnami Cassandra
chart, which is not compatible with the Cassandra installed now. Run
`./uninstall.sh` to remove an earlier installation, including its data, before
installing this one.

### Usage

Create the namespace "thatdot-example", and in it the secrets holding the
license keys and the credentials of the thatDot image registry. The registry
username is your thatDot client id and the password is your license key:

```
kubectl create namespace thatdot-example

kubectl -n thatdot-example create secret generic quine-enterprise-license \
  --from-literal=license-key=<Quine Enterprise license key>
kubectl -n thatdot-example create secret docker-registry quine-enterprise-registry \
  --docker-server=registry.license.thatdot.com \
  --docker-username=<Quine Enterprise client id> \
  --docker-password=<Quine Enterprise license key>

kubectl -n thatdot-example create secret generic novelty-license \
  --from-literal=license-key=<Novelty license key>
kubectl -n thatdot-example create secret docker-registry novelty-registry \
  --docker-server=registry.license.thatdot.com \
  --docker-username=<Novelty client id> \
  --docker-password=<Novelty license key>
```

To install everything in the namespace "thatdot-example":

```
./install.sh
```

The script installs the Quine Enterprise and Novelty charts from this
repository's [charts](../../charts) directory.

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
# Example, to check that the cluster member is alive and that the cluster is ready
curl -i http://localhost:8080/api/v2/system/liveness
curl -i http://localhost:8080/api/v2/system/readiness
```

#### Access Novelty UI

Port forward the deployment to access locally:

```
kubectl -n thatdot-example port-forward deploy/novelty 8081:8080
```

Use browser at `http://localhost:8081`. Or access API via curl:

```
curl -i http://localhost:8081/api/v2/system/liveness
curl -i http://localhost:8081/api/v2/system/readiness
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
