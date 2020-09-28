FROM golang:1.14 as builder
RUN GO111MODULE=on go get github.com/mikefarah/yq/v3


FROM debian:buster

ARG KUBERNETES_VERSION="v1.19.2"
ARG HELM_VERSION="v3.3.4"

RUN apt-get update && apt-get install -y \
        ca-certificates \
        curl \
        git \
        gettext-base \
        jq

RUN set -ex; case $(uname -m) in aarch64*|armv8*) GOARCH=arm64 ;; arm*) GOARCH=arm ;; x86_64) GOARCH=amd64 ;; *) exit 1 ;; esac && \
    curl -kLO "https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/${GOARCH}/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/bin/kubectl && \
    curl -kL https://get.helm.sh/helm-${HELM_VERSION}-linux-${GOARCH}.tar.gz | tar -zx --wildcards --strip-components=1 "*/helm" && \
    mv ./helm /usr/bin/helm

RUN useradd -ms /bin/bash kadm

COPY ./setconf /usr/bin/
COPY ./subi /usr/bin/
COPY --from=builder /go/bin/yq /usr/bin/

RUN chmod +x /usr/bin/setconf /usr/bin/subi /usr/bin/yq

USER kadm
WORKDIR /home/kadm
CMD ["bash"]