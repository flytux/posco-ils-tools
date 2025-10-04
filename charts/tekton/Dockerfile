FROM alpine:3.19

# Install bash, git, curl, ca-certificates, postgresql-client, and openssl (for kubectl)
RUN apk add --no-cache \
    bash \
    git \
    curl \
    ca-certificates \
    postgresql-client \
    openssl

# Set kubectl version (can be overridden during build)
ARG KUBECTL_VERSION=v1.30.1

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Install Tekton CLI (tkn) - latest version by default
ARG TKN_VERSION=latest
RUN if [ "$TKN_VERSION" = "latest" ]; then \
        TKN_VERSION=$(curl -s https://api.github.com/repos/tektoncd/cli/releases/latest | grep tag_name | cut -d '"' -f 4); \
    fi && \
    curl -L "https://github.com/tektoncd/cli/releases/download/${TKN_VERSION}/tkn_${TKN_VERSION#v}_Linux_x86_64.tar.gz" | tar -xz -C /usr/local/bin tkn

# Set working directory
WORKDIR /workspace

# Optional: Show versions at build time
RUN bash --version && git --version && kubectl version --client && tkn version && psql --version

# Default shell
ENTRYPOINT ["/bin/bash"]
