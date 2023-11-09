@build:
    docker build -t kubizone-route53-bash:local .

set positional-arguments
@debug *args='': build
    if [ -z "$AWS_ACCESS_KEY_ID" ]; then echo "Must set AWS_ACCESS_KEY_ID"; fi
    if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then echo "Must set AWS_SECRET_ACCESS_KEY"; fi
    if [ -z "$AWS_SESSION_TOKEN" ]; then echo "Must set AWS_SESSION_TOKEN"; fi
    docker run --rm -it                         \
    -v "$HOME/.kube:/root/.kube"                \
    -v "$HOME/.aws:/root/.aws"                  \
    -e AWS_ACCESS_KEY_ID                        \
    -e AWS_SECRET_ACCESS_KEY                    \
    -e AWS_SESSION_TOKEN                        \
    kubizone-route53-bash:local $@ || true
