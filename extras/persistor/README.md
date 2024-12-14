## Cassandra Persistor Extras

Use these scripts to easily setup a cassandra compatible persistor for a Quine
instance or Quine Enterprise cluster.

This extra installs Apache Cassandra via the [Bitnami Cassandra Helm
chart](https://artifacthub.io/packages/helm/bitnami/cassandra)

### Usage

To install the cassandra persistor in the `thatdot-example` namespace:

```
KUBE_NAMESPACE=thatdot-example ./install.sh
```

To uninstall the cassandra persistor from the `thatdot-example namespace:

```
KUBE_NAMESPACE=thatdot-example ./uninstall.sh
```

### Configuration

To configure a Quine instance or Quine Enterprise cluster to use the newly
created persistor, add the following to your `quine-enterprise-values.yaml`
file:

```
# Settings for using cassandra cluster as persistor
cassandra:
  enabled: true
  endpoints: "quine-enterprise-store-cassandra"
  plaintextAuth:
    enabled: true
    username: cassandra
    password: cassandra
  shouldCreateKeyspace: true
  shouldCreateTables: true
```

**Note:** the above assumes that the cassandra is located in the same namespace
as the Quine instance/cluster. If they are located in different namespaces you
must specify the endpoints with the fully qualified domain for that namespace
(Ex: `quine-enterprise-store-cassandra.thatdot-example`). See: [namespaces of
services](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#namespaces-of-services).
