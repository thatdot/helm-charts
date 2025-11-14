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

To install the quine-enterprise chart:

```
helm install my-novelty thatdot/novelty
```

To uninstall the chart:

```
helm delete my-novelty
```

## License Key

Novelty requires a valid license key to operate. The license key must be provided via the `licenseKey` configuration parameter.

### Obtaining a License Key

thatDot provides license keys as part of an evaluation agreement or purchase order. To schedule a demo or purchase a license, please:

- Request a demo: [https://www.thatdot.com/request-a-demo/](https://www.thatdot.com/request-a-demo/)
- Email sales: [sales@thatdot.com](mailto:sales@thatdot.com)
- Contact thatDot: [https://www.thatdot.com/contact-us/](https://www.thatdot.com/contact-us/)

When you receive your license key, thatDot will also provide the private Docker registry URL and credentials.
