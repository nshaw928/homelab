# Bootstrap

These resources are to be applied first, before any infrastructure or applications.

## What Goes Here
- Namespaces
- Custom Resource Definitions (CRDs), to be added later when needed

## Apply Order
```bash
kubectl apply -f bootstrap/namespaces/
```

All resources in this directory should be idempotent and have no dependencies on each other.