### Commands to get metrics details in kubectl:

```
kubectl api-versions
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" | jq .
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/namespaces/default/pods" | jq .
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/namespaces/monitoring/pods/prometheus-79cf6f9bf6-hc6rr/" | jq .

kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/network_tcp_usage" | jq .
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/kube-system/pods/*/spec_cpu_quota" | jq .
```
