# Infrastructure

These resources are to be applied first, before any infrastructure or applications.

## What Goes Here
- Cert Manager

## Apply Order
```bash
kubectl apply -f infrastructure/cert-manager/
```

These are cluster-level services. Infrastructure is not user facing. Once set up, infrastrucutre should not change frequently and are critical for the function of the rest of the cluster.