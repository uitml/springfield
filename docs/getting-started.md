# Getting started

## Creating authentication credentials



## Required utilities

Install `kubectl` following the [official documentation][kubectl], or run the
script below to install the latest release in your `/usr/local/bin` directory.

```console
curl https://uitml.github.io/springfield/install-kubectl.sh | sh
```

## Optional utilities

Download and install `kubectx` [manually][kubectx], or run the script below
to install the latest release in your `/usr/local/bin` directory.

```console
curl https://uitml.github.io/springfield/install-kubectx.sh | sh
```

```console
kubens <your username>
```

```console
mkdir -p ~/.ssh && chmod 700 ~/.ssh
```

```console
ssh-keygen -t rsa -f ~/.ssh/id_rsa_uit -C <your@uit.no e-mail address>
```

```console
kubectl create secret generic ssh-keys \
  --from-file=id_rsa_uit.pub=~/.ssh/id_rsa_uit.pub \
  --dry-run -o yaml | kubectl apply -f -
```

```console
kubectl port-forward deployments/storage 2222:22 >/dev/null 2>&1 &
```

<!--- References --->
[kubectl]: https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl
[kubectx]: https://github.com/ahmetb/kubectx/releases/latest
