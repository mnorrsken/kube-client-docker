FROM debian:buster

ARG KUBERNETES_VERSION="1.20.8"
ARG HELM_VERSION="3.6.1"
ARG HELMSMAN_VERSION="3.7.1"
ARG YQ_VERSION="4.9.6"

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        gettext-base \
        jq \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex; case $(uname -m) in aarch64*|armv8*) GOARCH=arm64 ;; arm*) GOARCH=arm ;; x86_64) GOARCH=amd64 ;; *) exit 1 ;; esac && \
    curl -kLO "https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/${GOARCH}/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/bin/kubectl && \
    curl -kL https://get.helm.sh/helm-v${HELM_VERSION}-linux-${GOARCH}.tar.gz | tar -zx --wildcards --strip-components=1 "*/helm" && \
    mv ./helm /usr/bin/helm && \
    curl -L https://github.com/Praqma/helmsman/releases/download/v${HELMSMAN_VERSION}/helmsman_${HELMSMAN_VERSION}_linux_${GOARCH}.tar.gz | tar -zx && \
    mv ./helmsman /usr/bin/helmsman && \
    curl -kL https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${GOARCH} -o /usr/bin/yq && \
    chmod +x /usr/bin/yq

RUN useradd -ms /bin/bash kadm

COPY ./setconf /usr/bin/
COPY ./subi /usr/bin/

RUN chmod +x /usr/bin/setconf /usr/bin/subi /usr/bin/yq

USER kadm
WORKDIR /home/kadm
CMD ["bash"]