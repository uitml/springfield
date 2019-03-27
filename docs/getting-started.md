# Getting started

## Creating authentication credentials

**Your authentication credentials must be kept secret at all times!**

Communicating with the cluster requires using RSA encryption keys and signed
certificates. The easiest way to create an RSA key and certificate signing
request is to run the following script, which will automate the process.

```console
curl https://uitml.github.io/springfield/create-certificate.sh | sh
```

The next step is to send the certificate signing request (CSR) to an admin.
You can either send the encoded output after the dotted line, or the CSR file
stored at `$HOME/.certs/springfield/<username>.csr`. After the CSR has been
processed by an admin, you will be given a signed certificate. You should store
the certificate in your `$HOME/.certs/springfield` directory, which is the same
directory that your RSA key resides in. To ensure you're the only that can read
the certificate file, run the following command.

```console
chmod 600 $HOME/.certs/springfield/*.crt
```

Keeping your credentials secret is very important, because anyone with access
to them will be able to authenticate with the cluster using your identity.

## Install client tools

Most communication with the cluster is done via the official `kubectl` tool.
Install `kubectl` by running the script below, which will install the latest
release into the `/usr/local/bin` directory on your computer. Alternatively
you can follow the [official documentation][kubectl].

```console
curl https://uitml.github.io/springfield/install-kubectl.sh | sh
```

Once `kubectl` is installed you need to configure it by running the command
provided to you together with your personal, signed certificate.

Verify that everything is configured correctly by running the command below,
which should print `yes` in your terminal. If it doesn't, contact a cluster
admin for assistance.

```console
kubectl auth can-i create job
```

### Optional utilities

If you're frequently going to work with external clusters or across multiple
namespaces, you should install `kubectx` and `kubens` to improve your quality
of life. Both can easily be installed by running the script below, which will
install the latest release in your `/usr/local/bin` directory.

```console
curl https://uitml.github.io/springfield/install-kubectx.sh | sh
```

The `kubectx` tool makes it easy to switch the active `kubectl` context, which
is useful for accessing other clusters, e.g. your local [minikube] cluster.

```console
kubectx minikube
```

The `kubens` tool allows you to change the default namespace scope for all
subsequent `kubectl` commands, which can be handy if you frequently work in
multiple namespaces.

```console
kubens <username>@springfield
```

## Accessing your cluster file storage

```console
curl https://uitml.github.io/springfield/prepare-authentication.sh | sh
```

```console
kubectl port-forward deployments/storage 2222:22 >/dev/null 2>&1 &
```

<!--- References --->
[kubectl]: https://kubernetes.io/docs/tasks/tools/install-kubectl/
[kubectx]: https://github.com/ahmetb/kubectx/releases/latest
[minikube]: https://kubernetes.io/docs/tasks/tools/install-minikube/
