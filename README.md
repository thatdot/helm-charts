# thatDot Helm Charts

This repo contains Helm charts, scripts, and documentation for deploying
thatDot applications on Kubernetes.

## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

  helm repo add thatdot https://helm.thatdot.com

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
thatdot` to see the charts.

## Charts

### Quine Enterprise

[README.md](charts/quine-enterprise/README.md)

The Quine Enterprise Helm chart can be used to deploy and manage a thatDot
[Quine Enterprise](https://docs.thatdot.com/streaming-graph/index.html) cluster
on Kubernetes.  This Helm chart works for both the trial version with a trial
license and the full licensed version. Free trial licenses are available at
[thatdot.com](https://www.thatdot.com/free-trial/).

### Novelty

[README.md](charts/novelty/README.md)

The Novelty Helm chart can be used to deploy and manage thatDot
[Novelty](https://docs.thatdot.com/novelty/getting-started/novelty-main-concepts.html)
on Kubernetes.  This Helm chart works for both the trial version with a trial
license and the full licensed version. Free trial licenses are available at
[thatdot.com](https://www.thatdot.com/free-trial/).

