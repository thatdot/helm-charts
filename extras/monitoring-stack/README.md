## Monitoring Stack Extras

Use these scripts to easily setup a monitoring stack for a Quine
instance or Quine Enterprise cluster.

This extra installs InfluxDB v1 via the [Official Helm
chart](https://github.com/influxdata/helm-charts)

This extra installs Grafana via the [Grafana Community Helm
chart](https://github.com/grafana/helm-charts)

### Usage

To install the monitoring stack in the `thatdot-example` namespace:

```
KUBE_NAMESPACE=thatdot-example ./install.sh
```

To uninstall the monitoring stack in the `thatdot-example namespace:

```
KUBE_NAMESPACE=thatdot-example ./uninstall.sh
```

### Quine Metrics Configuration

To configure a Quine instance or Quine Enterprise cluster to use the newly
created influxDB for metrics, add the following to your
`quine-enterprise-values.yaml` file:

```
# Settings for InfluxDB metrics.
metrics:
  influx:
    enabled: true
    host: influx-influxdb
```

**Note:** the above assumes that the InfluxDB instance is located in the same
namespace as the Quine instance/cluster. If they are located in different
namespaces you must specify the host with the fully qualified domain for that
namespace (Ex: `influx-influxdb.thatdot-example`). See: [namespaces of
services](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#namespaces-of-services).

### Access Grafana Dashboard

Assuming that the metrics stack has been installed in a namespace called
"thatdot-example".

Port forward the deployment to access locally:

```
kubectl -n thatdot-example port-forward deploy/grafana 3000:3000
```

Log into the Grafana server with browser. "Quine" dashboard is preconfigured.

**Note:** the defualt username/password is intended for internal use only. A stronger
password should be used if exposing the Grafana to the open internet.

* Username: `admin`

* Password: `admin`
