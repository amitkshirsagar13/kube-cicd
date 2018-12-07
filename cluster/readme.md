

kubectl create secret docker-registry regcred --docker-server=k8cluster.azurecr.io --docker-username=Azuresample --docker-password=+U4xPdXWVFKQzQU3itZtFMYbfWVUGKLy --docker-email=email


168.61.159.120



Cleanup:

```
kubectl get pods --all-namespaces | grep Evicted | awk '{print $2}' | xargs kubectl delete pod -n custom-metrics

```
