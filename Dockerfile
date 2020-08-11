FROM debian:buster

ARG KUBERNETES_VERSION="v1.18.0"
ARG HELM_VERSION="v3.2.4"

# ENV KUBE_SERVER


RUN apt-get update && apt-get install -y \
        ca-certificates \
        curl \
        git

RUN set -e; case $(uname -m) in aarch64*|armv8*) GOARCH=arm64 ;; arm*) GOARCH=arm ;; x86_64) GOARCH=amd64 ;; *) exit 1 ;; esac && \
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/${GOARCH}/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/bin/kubectl

RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | DESIRED_VERSION=${HELM_VERSION} USE_SUDO=false HELM_INSTALL_DIR=/usr/bin bash - 

RUN useradd -ms /bin/bash kadm

COPY ./entrypoint.sh /
COPY ./kube-context /usr/bin/

RUN chmod +x /entrypoint.sh /usr/bin/kube-context

USER kadm
WORKDIR /home/kadm

CMD [ "bash" ]
ENTRYPOINT [ "/entrypoint.sh" ]