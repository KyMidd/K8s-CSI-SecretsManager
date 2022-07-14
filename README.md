# K8s-CSI-SecretsManager

Deployable docker, k8s, and terraform to deploy a pod to fetch secrets dynamically from AWS Secrets Manager on pod launch. 

Secrets are refreshed each time pod is launched, either via manual action or deployment replace. Secrets are not automatically refreshed on a live pod unless configured to do so. 

Docker config builds: 
- An image which does nothing, and stays online for interactive terminal for testing

Terraform config builds: 
- Eks k8s cluster
- EKS node group
- IAM Role + Policy with assume role policy
- OID Provider
- Secret in Secrets Manager and populate it with json payload

K8s config builds: 
- CSI Secrets driver
- AWS Secrets Manager CSI Driver
- Our Service Account
- Our SecretProviderClass
- Our Pod host


