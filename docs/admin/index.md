---
title: Cluster Administration
has_children: true
nav_order: 3
nav_exclude: true
---

# Kubernetes on Springfield
This page details all the gory details of how we've installed and configured
Kubernetes (k8s) on GPU cluster, codenamed "Springfield". The primary motivation
behind documenting this is improve the [bus factor](https://en.wikipedia.org/wiki/Bus_factor),
as well as make it easier to recreate the cluster in case of catastrophic
hardware failure or similar.

The manifests used throughout the documentation can be found in the
[`k8s`](https://github.com/uitml/springfield/tree/master/k8s) directory.

## Prepare all nodes
...

## Initialize the master node
...

```
kubeadm init --config springfield.yaml
```

...
```
kubectl apply -f flannel.yaml
```

...
```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

### Join other nodes to the cluster
...

### References
* https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/

## Prepare GPU-capable nodes
https://github.com/NVIDIA/k8s-device-plugin

```
kubectl apply -f nvidia-device-plugin.yaml
```

### References
* https://kubernetes.io/docs/tasks/manage-gpus/scheduling-gpus/

## Configure Ingress
Because we have no load balancer, and to make things as simple as possible for
end-users, the NGINX-backed ingress controller is deployed as a DaemonSet. This
means that every node in the cluster is an ingress point. Since we want to run
the ingress on the standard HTTP (80) and HTTPS (443) ports, the manifest uses
_hostPort_ to allow the pod to bind to "reserved" ports. Therefore it is vital
that no other service, especially outside the embrace of k8s, is allowed to bind
to those ports. By default pods are limited to the port range 30000-32767, so
we should not have any conflicts.

```
kubectl apply -f ingress.yaml
```

### External authentication

### References
* https://kubernetes.io/docs/concepts/services-networking/ingress/
* https://kubernetes.github.io/ingress-nginx/deploy/
* http://alesnosek.com/blog/2017/02/14/accessing-kubernetes-pods-from-outside-of-the-cluster/
* https://github.com/kubernetes/ingress-nginx/blob/master/docs/examples/external-auth/README.md


## Install Dashboard
...

### References
* https://github.com/kubernetes/dashboard/wiki/Installation
* https://github.com/kubernetes/dashboard/wiki/Access-control
* https://github.com/kubernetes/dashboard/wiki/Creating-sample-user
