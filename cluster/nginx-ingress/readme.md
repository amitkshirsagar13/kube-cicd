### docker-desktop Ingress

- Add echo.k8m.k8cluster.io to hostname
- By default 80/443 are forwarding requests to docker-desktop kubernetes ingress will get requests


```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.48.1/deploy/static/provider/cloud/deploy.yaml
```
