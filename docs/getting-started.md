# Getting started

## Creating authentication credentials

**Your authentication credentials must be kept secret at all times!**

Communicating with the cluster requires using RSA encryption keys and signed
certificates. The easiest way to create an RSA key and certificate signing
request is to run the following script, which will automate the process.

```console
curl https://uitml.github.io/springfield/create-certificate.sh <username> | sh
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

## Required utilities

Install `kubectl` by running the script below, which will install the latest
release into your `/usr/local/bin` directory.

```console
curl https://uitml.github.io/springfield/install-kubectl.sh | sh
```

Alternatively you can follow the [official documentation][kubectl].

## Optional utilities

Download and install `kubectx` [manually][kubectx], or run the script below
to install the latest release in your `/usr/local/bin` directory.

```console
curl https://uitml.github.io/springfield/install-kubectx.sh | sh
```

The `kubens` utility (bundled with `kubectx`) allows you to change the default
namespace scope for all relevant `kubectl` commands.

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
