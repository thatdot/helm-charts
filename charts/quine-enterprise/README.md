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

See [values.yaml](values.yaml) for configuration details. The
[persistor extra](../../extras/persistor/README.md) installs an example
Cassandra cluster.

### Metrics

Metrics are not required to operate thatDot Quine Enterprise, but if desired
they will require an InfluxDB v1 instance reachable in the environment. 

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

To install the quine-enterprise chart, first create the two secrets described under
[License Key](#license-key) and [Image Registry](#image-registry), then:

```
helm install my-quine-enterprise thatdot/quine-enterprise \
  --set licenseKeySecret.name=quine-enterprise-license \
  --set 'imagePullSecrets[0].name=quine-enterprise-registry' \
  --set cassandra.endpoints=<cassandra endpoints>
```

With `--set`, separate several endpoints with an escaped comma (`host1\,host2`),
or set `cassandra.endpoints` in a values file instead.

To uninstall the chart:

```
helm delete my-quine-enterprise
```

## Upgrading

The image tag defaults to the chart's `appVersion`, so upgrading the chart also
upgrades Quine Enterprise unless `image.tag` is set.

**Note:** Quine Enterprise 2.2.0 changed the format of persisted data, and the
change is one-way. Once a cluster has run 2.2.0 or later against a persistor,
do not run an earlier version against the same persistor.

## License Key

Quine Enterprise requires a valid license key to operate. The chart reads the
license key from a Kubernetes secret, named by the `licenseKeySecret.name` and
`licenseKeySecret.key` values:

```
kubectl create secret generic quine-enterprise-license \
  --from-literal=license-key=<license key>
```

## Image Registry

The Quine Enterprise image is pulled from thatDot's registry,
`registry.license.thatdot.com/thatdot/quine-enterprise`. The registry username is your
thatDot client id and the password is your license key. Create a pull secret
and name it in the `imagePullSecrets` value:

```
kubectl create secret docker-registry quine-enterprise-registry \
  --docker-server=registry.license.thatdot.com \
  --docker-username=<client id> \
  --docker-password=<license key>
```

### Obtaining a License Key

thatDot provides license keys as part of an evaluation agreement or purchase order. To schedule a demo or purchase a license, please:

- Request a demo: [https://www.thatdot.com/request-a-demo/](https://www.thatdot.com/request-a-demo/)
- Email sales: [sales@thatdot.com](mailto:sales@thatdot.com)
- Contact thatDot: [https://www.thatdot.com/contact-us/](https://www.thatdot.com/contact-us/)

thatDot provides your client id together with your license key.
