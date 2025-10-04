
#### ILS 클러스터 설치용 helm charts, 빌드 파이프라인 저장소
---

###### 1. K3S Air-gapped 설치

```

curl -L -o k3s-airgap-images-amd64.tar.zst "https://github.com/k3s-io/k3s/releases/download/v1.33.1%2Bk3s1/k3s-airgap-images-amd64.tar.zst"

sudo mkdir -p /var/lib/rancher/k3s/agent/images/
cp k3s-airgap-images-amd64.tar.zst /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.zst


sudo curl -Lo /usr/local/bin/k3s https://github.com/k3s-io/k3s/releases/download/v1.33.3%2Bk3s1/k3s
sudo chmod +x /usr/local/bin/k3s

curl -Lo install.sh https://get.k3s.io
chmod +x install.sh


curl -LO https://github.com/k3s-io/k3s-selinux/releases/download/v1.6.stable.1/k3s-selinux-1.6-1.el8.noarch.rpm

sudo yum install ./k3s-selinux-1.6-1.el8.noarch.rpm

INSTALL_K3S_SKIP_DOWNLOAD=true ./install.sh

```
