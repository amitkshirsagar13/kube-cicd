### Setup Provider for terraform:
```
az login --allow-no-subscriptions

az account show --query "{subscriptionId:id, tenantId:tenantId}"

az account set --subscription="${SUBSCRIPTION_ID}"

#Create Service Principle for terraform to use
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"

```
