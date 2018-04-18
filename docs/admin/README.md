# Kubernetes on Springfield
This page details all the gory details of how we've installed and configured Kubernetes (k8s) on GPU cluster, codenamed "Springfield". The primary motivation behind documenting this is improve the [bus factor](https://en.wikipedia.org/wiki/Bus_factor), as well as make it easier to recreate the cluster in case of catastrophic hardware failure or similar.

## Prepare all nodes
...

## Initialize the master node
...

```
$ kubeadm init --config springfield.yaml
```

...
```
kubectl apply -f flannel.yaml
```

...
```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

## Join other nodes to the cluster
...

## Prepare GPU capable nodes
https://github.com/NVIDIA/k8s-device-plugin

...
```
kubectl apply -f nvidia-device-plugin.yaml
```

## Configure Ingress
...

```
kubectl apply -f ingress-nginx/namespace.yaml
kubectl apply -f ingress-nginx/default-backend.yaml
kubectl apply -f ingress-nginx/configmap.yaml
kubectl apply -f ingress-nginx/tcp-services-configmap.yaml
kubectl apply -f ingress-nginx/udp-services-configmap.yaml
kubectl apply -f ingress-nginx/rbac.yaml
kubectl apply -f ingress-nginx/with-rbac.yaml
```

## Install Dashboard
...
