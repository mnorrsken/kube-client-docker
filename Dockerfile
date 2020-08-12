FROM debian:buster

ARG KUBERNETES_VERSION="v1.18.0"
ARG HELM_VERSION="v3.3.0"
# ENV KUBE_SERVER


RUN apt-get update && apt-get install -y \
        ca-certificates \
        curl \
        git

RUN set -ex; case $(uname -m) in aarch64*|armv8*) GOARCH=arm64 ;; arm*) GOARCH=arm ;; x86_64) GOARCH=amd64 ;; *) exit 1 ;; esac && \
    curl -kLO "https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/${GOARCH}/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/bin/kubectl && \
    curl -kL https://get.helm.sh/helm-${HELM_VERSION}-linux-${GOARCH}.tar.gz | tar -zx --wildcards --strip-components=1 "*/helm" && \
    mv ./helm /usr/bin/helm

RUN useradd -ms /bin/bash kadm

COPY ./setconf /usr/bin/

RUN chmod +x /usr/bin/setconf

USER kadm
WORKDIR /home/kadm
CMD ["bash"]