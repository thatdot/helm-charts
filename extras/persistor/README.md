## Cassandra Persistor Extras

Use these scripts to easily setup a cassandra compatible persistor for a Quine
instance, Quine Enterprise cluster, or Novelty instance.

This extra installs Apache Cassandra from the [official Apache Cassandra
image](https://hub.docker.com/_/cassandra), using the small Helm chart in the
[cassandra](cassandra) directory. See its [values.yaml](cassandra/values.yaml)
for configuration details.

**Note:** this is an example suitable for evaluation. For production, consider
a managed Cassandra compatible service or a Cassandra operator such as
[K8ssandra](https://k8ssandra.io/).

### Usage

To install the cassandra persistor in the `thatdot-example` namespace:

```
KUBE_NAMESPACE=thatdot-example ./install.sh
```

To uninstall the cassandra persistor from the `thatdot-example` namespace:

```
KUBE_NAMESPACE=thatdot-example ./uninstall.sh
```

Uninstalling keeps the persistent volume claims, and therefore the data. To
delete the data as well:

```
kubectl -n thatdot-example delete pvc -l app.kubernetes.io/instance=quine-enterprise-store
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

The same settings configure the Novelty chart. Novelty uses its own keyspace
(`novelty` by default), so it can share the Cassandra cluster with Quine
Enterprise.

**Note:** the above assumes that the cassandra is located in the same namespace
as the Quine instance/cluster. If they are located in different namespaces you
must specify the endpoints with the fully qualified domain for that namespace
(Ex: `quine-enterprise-store-cassandra.thatdot-example`). See: [namespaces of
services](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#namespaces-of-services).

**Note:** `cassandra`/`cassandra` is the default superuser that Cassandra
creates. It is intended for evaluation only. Change the password before
storing real data.
