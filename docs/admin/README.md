# Kubernetes on Springfield
This page details all the gory details of how we've installed and configured Kubernetes (k8s) on GPU cluster, codenamed "Springfield". The primary motivation behind documenting this is improve the [bus factor](https://en.wikipedia.org/wiki/Bus_factor), as well as make it easier to recreate the cluster in case of catastrophic hardware failure or similar.

## Prepare all nodes
...

## Initialize the master node
...

```
$ kubeadm init --config springfield.yaml
```

```yaml
# springfield.yaml
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration

networking:
  # Use pod network CIDR required by Flannel.
  podSubnet: 10.244.0.0/16

featureGates:
  # Enable gated features as documented in `kubeadm --help`, e.g.
  # CoreDNS: true
```

...
```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml
```

...
```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

## Join other nodes to the cluster
...

## Prepare GPU capable nodes
https://github.com/NVIDIA/k8s-device-plugin

## Configure Ingress
...

## Install Dashboard
...
