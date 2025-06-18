# thatDot Quine Helm Chart

Welcome to the thatDot Quine Helm Chart. Use this chart to easily install and
configure a thatDot Quine cluster on Kubernetes.

[Quine Docs Site](https://quine.io/)

## Prerequisites

### Persistence

thatDot Quine can take advantage of an external persistor to store data.
Currently, this Helm chart only supports either a Cassandra compatible
key-value store or an internal RocksDB file.

See [values.yaml](values.yaml) for configuration details.

### Metrics

Metrics are not required to operate Quine, but if desired they will require an
InfluxDB v1 instance reachable in the environment. 

See [values.yaml](values.yaml) for configuration details.

## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

```
helm repo add thatdot https://helm.thatdot.com
```

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
thatdot` to see the charts.

To install the quine chart:

```
helm install my-quine thatdot/quine
```

To uninstall the chart:

```
helm delete my-quine
```
