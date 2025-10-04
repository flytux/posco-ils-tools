openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
  -keyout gitea.key -out gitea.crt -subj '/CN=gitea.local' \
  -addext 'subjectAltName=DNS:gitea.local'

kubectl create ns gitea
kubectl create secret tls gitea-tls --key gitea.key --cert gitea.crt -n gitea

helm upgrade -i gitea -f values.yaml gitea-12.2.0.tgz -n gitea 
