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

## Trial

thatDot Novelty is priopriatary software. A free trial evaluation license is
available from [thatdot.com](https://www.thatdot.com/free-trial/). When using
this helm chart with a trial license, `Values.trial.enabled` must be set to
true and the `Values.trial.email` and `Values.trial.apiKey` fields must be set.
The API key will be sent via email after registering for a trial license.
