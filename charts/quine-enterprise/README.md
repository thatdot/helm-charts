# thatDot Quine Enterprise Helm Chart

Welcome to the thatDot Quine Enterprise Helm Chart. Use this chart to easily
install and configure a thatDot Quine Enterprise cluster on Kubernetes.

[Quine Enterprise Docs Site](https://docs.thatdot.com/streaming-graph/overview/index.html)

## Prerequisites

### Persistence

thatDot Quine Enterprise requires a persistor to store data for the cluster.
Currently, this Helm chart only supports a Cassandra compatible key-value
store. For debug and development purposes, the Quine Enterprise can be run
without a persistor, but data loss and data consistency issues should be
expected. This configuration should not be used in production.

See [values.yaml](values.yaml) for configuration details.

### Metrics

Metrics are not required to operate thatDot Quine Enterprise, but if desired
they will require an InfluxDB v1 instance reachable in the environment. 

See [values.yaml](values.yaml) for configuration details.

## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

  helm repo add thatdot https://helm.thatdot.com

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
thatdot` to see the charts.

To install the quine-enterprise chart:

    helm install my-quine-enterprise thatdot/quine-enterprise

To uninstall the chart:

    helm delete my-quine-enterprise

## Trial

Quine Enterprise is proprietary software. A free trial evaluation license is
available from [thatdot.com](https://www.thatdot.com/free-trial/). When using
this helm chart with a trial license, `Values.trial.enabled` must be set to
true and the `Values.trial.email` and `Values.trial.apiKey` fields must be set.
The API key will be sent via email after registering for a trial license.
