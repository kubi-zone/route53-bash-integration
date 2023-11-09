FROM docker.io/amazon/aws-cli:latest
ARG KUBECTL_VERSION="1.28.2"
ARG ARCH="amd64"

RUN curl -L -o /usr/bin/kubectl \
    https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl \
    && chmod +x /usr/bin/kubectl

RUN yum install -y jq

COPY --chmod=555 controller.sh /usr/bin/controller