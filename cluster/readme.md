

kubectl create secret docker-registry regcred --docker-server=k8cluster.azurecr.io --docker-username=Azuresample --docker-password=+U4xPdXWVFKQzQU3itZtFMYbfWVUGKLy --docker-email=email


168.61.159.120



Cleanup:

```
kubectl get pods --all-namespaces | grep Evicted | awk '{print $2}' | xargs kubectl delete pod -n custom-metrics

```



### Add User:

```bash
cd user
# Create Private Key
openssl genrsa -out amit.key 2048

# Create Certificate Request
openssl req -new -key amit.key -out amit.csr -subj "/CN=amit/O=eng"

BASE64AMIT=`cat amit.csr |base64|tr -d '\'

# Create Request in Kubernetes

cat <<EOF > amit-signing-request.yaml                                                                        
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: amit-csr
spec:
  signerName: kubernetes.io/kube-apiserver-client
  groups:
  - system:authenticated
  request: $BASE64AMIT
  usages:
  - digital signature
  - key encipherment
  - client auth
EOF

# Create Kubernetes Object for csr
kubectl apply -f amit-signing-request.yaml
kubectl get csr

# Approve certificate request as Admin
kubectl certificate approve amit-csr
kubectl get csr amit-csr -o yaml

# Extract Certificate to file
kubectl get csr amit-csr -o jsonpath='{.status.certificate}'| base64 -d > amit.crt

# Create Role with resource and verbs/actions
cat << EOF > amit-role.yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: echo
  name: amit
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"] # You can also use ["*"]
EOF

# Create Role binding with User
cat << EOF > amit-rolebinding.yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: amit-binding
  namespace: echo
subjects:
- kind: User
  name: amit
  apiGroup: ""
roleRef:
  kind: Role
  name: amit
  apiGroup: ""
EOF

# Check if role allowed for echo namespace
kubectl auth can-i list pods --namespace echo --as amit

# Should not be able to access default pods
kubectl auth can-i list pods --as amit

```
