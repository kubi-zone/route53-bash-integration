# kubizone-route53-bash

This is an example integration between Kubizone and Route53.

It is written in bash, using the `aws` and `kubectl` commands to show
a very simplified way of quickly building (fragile) integrations between
the Kubizone ecosystem of zones and records, and real-life production-grade
DNS systems.

This is *not* intended for use in production environments, it is merely
written to demonstrate one very hacky way of building an integration.

# Usage

## Local

Build the container:
```bash
$ docker build -t kubizone-route53-bash:local .
```

Running the container:

```bash
$ docker run --rm -it                           \
    -v "$HOME/.kube:/root/.kube"                \
    -v "$HOME/.aws:/root/.aws"                  \
    -e AWS_ACCESS_KEY_ID                        \
    -e AWS_SECRET_ACCESS_KEY                    \
    -e AWS_SESSION_TOKEN                        \
    kubizone-route53-bash:local                 \
    --zone=myzone-resource-com                  \
    --namespace=optional-namespace              \
    --hosted-zone-id=Z01234567890ABCABCABC
```

Note that it uses your current Kubernetes and AWS credentials to access
cluster resources and push them to the given hosted zone!

