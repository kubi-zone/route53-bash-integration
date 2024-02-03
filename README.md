# route53-bash-integration

Example integration between Kubizone and Route53.

It is written in bash, using the `aws` and `kubectl` commands to show
a very simplified way of quickly building (fragile) integrations between
the Kubizone ecosystem of zones and records, and real-life production-grade
DNS systems.

This is *not* intended for use in production environments, it is merely
written to demonstrate one very hacky way of building an integration.

# Usage

**Note:** You must [install](https://kubi.zone/docs/v0.1.0/getting-started/installation/)
the Kubizone Custom Resource Definitions and operator, before running this
controller, or it simply won't work.

Modify [`example-zone.yaml`](/example-zone.yaml) file to match your
hosted zone's domain names, and apply it to your cluster.

## Local

Build the container:
```bash
$ docker build -t route53-bash-integration:local .
```

Running the container:

```bash
$ docker run --rm -it                           \
    -v "$HOME/.kube:/root/.kube"                \
    -v "$HOME/.aws:/root/.aws"                  \
    -e AWS_ACCESS_KEY_ID                        \
    -e AWS_SECRET_ACCESS_KEY                    \
    -e AWS_SESSION_TOKEN                        \
    route53-bash-integration:local              \
    --zone=myzone-resource-com                  \
    --namespace=optional-namespace              \
    --hosted-zone-id=Z01234567890ABCABCABC
```

Note that it uses your current Kubernetes and AWS credentials to access
cluster resources and push them to the given hosted zone!

