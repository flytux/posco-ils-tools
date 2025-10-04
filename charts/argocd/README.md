#### 1. argocd 설치

```
k apply -f install.yaml -n argocd

k apply -f argocd-ingress.yaml -n argocd

```

#### 2. nginx ingress 컨트롤러 설정
```
#nginx-ingress controller 디플로이 command args에 다음 추가

--enable-ssl-passthrough
```

#### 3. build 네임스페이스에 파이프라인 구동용 secret 추가
```
# argocd 패스워드 확인 후
kubectl create secret generic -n build argocd-credentials-secret --from-literal=argocd-user-password='QHVwmkghjz1q7D2A' --from-literal=argocd-user-id='admin'
```
