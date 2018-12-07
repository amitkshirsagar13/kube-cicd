### Commands to get metrics details in kubectl:

```
kubectl api-versions
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" | jq .
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/namespaces/default/pods" | jq .
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/namespaces/monitoring/pods/prometheus-79cf6f9bf6-hc6rr/" | jq .

kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/network_tcp_usage" | jq .
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/kube-system/pods/*/spec_cpu_quota" | jq .


#KONG
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/test/pods/*/http_requests" | jq .
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/kong/pods/*/kong_nginx_http_current_connections" | jq .

#NGINX
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/nginx-ingress/pods/*/nginx_http_requests" | jq .
```


for ((i=1;i<=110;i++)); do curl -k --resolve cafe.example.com:443:23.99.220.156 https://cafe.example.com:443/ ; done
curl -k --resolve cafe.example.com:443:23.99.220.156 https://cafe.example.com:443/tea

ab -c 150 -n 10000 https://cafe.example.com:443/tea

curl -k --resolve grafana.k8cluster.io:443:23.99.220.156 https://grafana.k8cluster.io:443/