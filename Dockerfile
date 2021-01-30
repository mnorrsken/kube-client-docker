FROM debian:buster

ARG KUBERNETES_VERSION="v1.20.2"
ARG HELM_VERSION="v3.5.1"
ARG YQ_VERSION="v4.4.1"

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
    mv ./helm /usr/bin/helm && \
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${GOARCH} -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

RUN useradd -ms /bin/bash kadm

COPY ./setconf /usr/bin/
COPY ./subi /usr/bin/

RUN chmod +x /usr/bin/setconf /usr/bin/subi /usr/bin/yq

USER kadm
WORKDIR /home/kadm
CMD ["bash"]