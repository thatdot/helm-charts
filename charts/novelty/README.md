# thatDot Novelty Helm Chart

Welcome to the thatDot Novelty Helm Chart. Use this chart to easily install and
configure a thatDot Novelty instance on Kubernetes.

[thatDot Novelty Docs Site](https://docs.thatdot.com/novelty/getting-started/index.html)

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

To install the novelty chart, first create the two secrets described under
[License Key](#license-key) and [Image Registry](#image-registry), then:

```
helm install my-novelty thatdot/novelty \
  --set licenseKeySecret.name=novelty-license \
  --set 'imagePullSecrets[0].name=novelty-registry'
```

To uninstall the chart:

```
helm delete my-novelty
```

## Persistence

By default Novelty stores its data in a RocksDB database on the pod's local
filesystem, which is lost when the pod is replaced. To store the data in a
Cassandra compatible store instead, set `cassandra.enabled` and
`cassandra.endpoints`. The Cassandra password can be read from a Kubernetes
secret with `cassandra.plaintextAuth.passwordExistingSecret`.

See [values.yaml](values.yaml) for configuration details. The
[persistor extra](../../extras/persistor/README.md) installs an example
Cassandra cluster.

## License Key

Novelty requires a valid license key to operate. The chart reads the
license key from a Kubernetes secret, named by the `licenseKeySecret.name` and
`licenseKeySecret.key` values:

```
kubectl create secret generic novelty-license \
  --from-literal=license-key=<license key>
```

## Image Registry

The Novelty image is pulled from thatDot's registry,
`registry.license.thatdot.com/thatdot/novelty`. The registry username is your
thatDot client id and the password is your license key. Create a pull secret
and name it in the `imagePullSecrets` value:

```
kubectl create secret docker-registry novelty-registry \
  --docker-server=registry.license.thatdot.com \
  --docker-username=<client id> \
  --docker-password=<license key>
```

The image tag defaults to the chart's `appVersion`. Set `image.tag` to run a
different version of Novelty.

### Obtaining a License Key

thatDot provides license keys as part of an evaluation agreement or purchase order. To schedule a demo or purchase a license, please:

- Request a demo: [https://www.thatdot.com/request-a-demo/](https://www.thatdot.com/request-a-demo/)
- Email sales: [sales@thatdot.com](mailto:sales@thatdot.com)
- Contact thatDot: [https://www.thatdot.com/contact-us/](https://www.thatdot.com/contact-us/)

thatDot provides your client id together with your license key.
