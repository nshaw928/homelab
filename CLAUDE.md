# Homelab Project Notes

## ArgoCD App-of-Apps Pattern

Two parent applications auto-discover child applications:

| Parent App | Path | Purpose |
|------------|------|---------|
| `infrastructure` | `argocd/infrastructure/` | Cluster services (storage, monitoring, etc.) |
| `apps` | `argocd/apps/` | User applications |

**To deploy a new app**: Create a YAML file in the appropriate directory and push to `main`. ArgoCD auto-syncs.

### Application Template

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://charts.example.io
    chart: my-chart
    targetRevision: 1.0.0
    helm:
      values: |
        key: value
  destination:
    server: https://kubernetes.default.svc
    namespace: my-namespace
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

For Helm charts with CRDs or hooks, add:
```yaml
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
      - SkipDryRunOnMissingResource=true
```

If CRDs show out-of-sync due to Kubernetes adding default fields, add `argocd.argoproj.io/compare-options: ServerSideDiff=true` annotation to the Application metadata.

### ArgoCD UI

Access at: `https://argocd.nicholasshaw.cloud` (requires Netbird VPN)

## Kubernetes Access

Kubeconfig path: `ansible/kubeconfig.yaml`

Usage:
```bash
export KUBECONFIG=/home/nick/homelab/ansible/kubeconfig.yaml
kubectl get nodes
```

## Persistent Storage with Longhorn

Longhorn v1.8.1 is deployed as the distributed block storage system. Use the `longhorn` StorageClass for persistent volumes.

### Creating a PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-data
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 5Gi
```

### Using in a Deployment

```yaml
spec:
  containers:
  - name: app
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: my-data
```

### Using in a StatefulSet (recommended for databases)

```yaml
volumeClaimTemplates:
- metadata:
    name: data
  spec:
    accessModes: ["ReadWriteOnce"]
    storageClassName: longhorn
    resources:
      requests:
        storage: 10Gi
```

### Longhorn UI

Access at: `https://longhorn.nicholasshaw.cloud` (requires Netbird VPN)

## TLS Certificates

Wildcard certificate for `*.nicholasshaw.cloud` managed by cert-manager with Cloudflare DNS-01 challenge.

### Ingress with TLS

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  namespace: my-namespace
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
spec:
  ingressClassName: traefik
  tls:
  - hosts:
    - my-app.nicholasshaw.cloud
  rules:
  - host: my-app.nicholasshaw.cloud
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app
            port:
              number: 80
```

### Certificate Resources

- Wildcard certificate: `nicholasshaw-cloud-wildcard-tls` in `cert-manager` namespace
- Reflector mirrors the secret to: `kube-system`, `argocd`, `longhorn-system`
- ClusterIssuers: `letsencrypt-staging`, `letsencrypt-production`

## VPN Access with Netbird

All homelab services are VPN-only via Netbird. Connect to VPN before accessing `*.nicholasshaw.cloud`.

### Netbird Management

- Management URL: `https://netbird.nicholasshaw.cloud`
- K3s nodes are Netbird peers with route to `10.99.99.0/24`

### Adding a New Node to VPN

```bash
ansible-playbook ansible/playbooks/netbird-client.yml
```

## Commit Style

- lowercase
- brief and concise
- no trailing period
- describe what changed, not why
- no co-authored-by lines

Examples:
- `add Longhorn v1.8.1 and CLAUDE.md`
- `disable preUpgradeChecker for ArgoCD compatibility`
- `remove nginx deployment`
