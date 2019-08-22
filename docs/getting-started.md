# Getting started

Our GPU cluster, codenamed "Springfield", is built on an open-source system
called [Kubernetes (k8s)][k8s]. You don't need to fully understand how that
system works, but you'll have to install some tools and configure some things
in order to run your research experiments on the cluster. The rest of this
document will guide you through all of the mandatory steps.

## Before getting started

First of all, the commands shown in this guide must be executed in a terminal
session on your own computer. In other words, there's no need to log into any
remote servers. You can use whatever terminal emulator you prefer.

We're assuming your computer is based on a x64 CPU architecture. Don't worry
if you're not entirely sure what that means, since your computer most likely
satisfies this requirement. If your computer is based on an ARM architecture,
talk to a cluster admin and they'll help you out.

There's a few prerequisite programs that must be installed in your operating
system for all the commands to execute successfully. On macOS and most Linux
distributions these programs are installed by default. The required programs
are _cURL_, _OpenSSL_, and _OpenSSH_. The easiest way to check if you've got
these programs installed is to execute the command below, which should print
paths to all of the respective binaries.

```console
which curl openssl ssh
```

## Creating authentication credentials

> Your authentication credentials must be kept secret at all times!
> Never share any authentication credentials generated while following this
> guide unless explictly instructed to do so.

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

## Accessing the cluster file storage

Currently all interaction with the cluster file storage from your own computer
must be routed through a storage proxy already running in your k8s namespace.
The storage proxy is deployed as a lightweight container running an SSH server,
and is configured to only support key-based authentication, which means you'll
have to generate an encrypted private and public key pair to communicate with
the storage proxy. The generated public key needs to be shared with the server,
and this is done by storing it in a k8s secret named `ssh-keys`. Execute the
command below to automate all of the steps needed to generate the key pair and
copy the public key to the k8s secret.

```console
curl https://uitml.github.io/springfield/prepare-authentication.sh | sh
```

At this point we're almost ready to communicate with the storage proxy, but the
container isn't normally accessible from outside the cluster network, so you'll
have to use the port-forwarding support in `kubectl` to forward local network
traffic to the cluster. Execute the command below to route traffic to port 2222
on your computer to port 22 on the storage proxy container in the cluster. Note
that this runs as a background process, and only works as long as that process
is alive and healthy.

```console
kubectl port-forward deployments/storage-proxy 2222:22 >/dev/null 2>&1 &
```

Verify that everything is working by executing the command below, which should
print some environment variables set inside the storage proxy container.

```console
ssh -p 2222 root@localhost printenv
```

## Running experiments

> This aspect of Springfield is still very much work in progress. Expect big
> changes to how jobs are scheduled, monitored, etc.

The only supported workflow for running experiments is using k8s jobs. Since
jobs are not intended tailored for our typical experiment workflows, it's
recommended that you install _Frink_. It can be installed by executing the
command below. The rest of this guide assumes it's been installed.

```console
curl https://uitml.github.io/frink/install.sh | sh
```

Jobs are declared using YAML manifests, and contain all necessary information
needed for starting a container, such as finding compute resources, preparing
container images, mounting filesystems, running commands, and so forth.

### Job specification

Below is an example of a job running an experiment with TensorFlow on the
Fashion MNIST dataset. Job manifests contain mandatory "boilerplate", so some
details have been omitted for brevity. The full example can be found at
<https://github.com/uitml/springfield/tree/master/examples/tensorflow>.

```yaml
kind: Job
apiVersion: batch/v1
metadata:
  name: fashion-mnist
spec:
  template:
    spec:
      containers:
      - name: fashion-mnist
        image: "tensorflow/tensorflow:1.13.1-gpu-py3"
        command: ["./fashion-mnist.sh"]
        # ...
```

#### Name

Both `name` values must be provided, but you can choose any names as long as
they only consist of alphanumeric characters, hyphens, or underscores.
The first value is the job name, the second one is the container name.

#### Image

The `image` value specifies the Docker image to use when running experiments.
You can use any Linux-based Docker image that is publically accessible. If the
image is hosted on [Docker Hub][hub], you can use the short format
`<user>/<repository>:<tag>`.

##### Customization

If you want a custom image, the best solution is to create an account on
[Docker Hub][hub], build the image on your own computer, and push the image
to [Docker Hub][hub]. Another, approach is to use a "bootstrap" script in your
job that customizes the running container instance. This is the approach used
in the example above.

#### Command

The `command` value specifies what should be executed when the job starts, and
typically this will be an executable script or similar. An alternative example
to the command above might be `python3 fashion-mnist.py`.

#### Other parameters

Omitted job parameters might specify e.g. the required number of GPUs, memory,
which filesystems to use and where to mount them, additional containers, and
so forth. Some of these details typically don't need to be specified. For the
remaining parameters that cannot be inferred, you'll typically copy the
standard boilerplate parameters. As you get more comfortable with k8s and the
job workflow, you might want to change some of these options to suit your own
preferences and workflows.

### Scheduling

Jobs are executed by a scheduling system running in the cluster. This means
that you'll have to register a job manifest with the scheduling system. The
easiest way is to use the `kubectl` plugins provided with Frink.

Assuming all required steps of the Fashion MNIST example have been followed,
model training can be scheduled by executing the following command.

```console
kubectl job run fashion-mnist.yaml
```

Executing the command above multiple times will result in the previously
scheduled job to be deleted before scheduling a new job. Note that if you've
changed the deployment manifest the job will not be deleted as expected and
must be deleted manually using the `kill` command shown below.

### Monitoring experiments

When a job has been scheduled, you can check the status of the job with the
following command.

```console
kubectl job list
```

To monitor the progress of any running job execute the following command,
which shows all console output produced by in the running job's container.

```console
kubectl job watch <name>
```

### Stopping and removing jobs

Stopping and removing jobs can be achieved with the following command. This is
needed in scenarios where you've made changes to your experiment and want to
reschedule a fresh job, or when you manually want to run a job several times.

```console
kubectl job kill <name>
```

<!--- References --->
[k8s]: https://kubernetes.io/
[kubectl]: https://kubernetes.io/docs/tasks/tools/install-kubectl/
[kubectx]: https://github.com/ahmetb/kubectx#installation
[minikube]: https://kubernetes.io/docs/tasks/tools/install-minikube/
[hub]: https://hub.docker.com/
