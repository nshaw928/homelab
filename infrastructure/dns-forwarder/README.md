# DNS Forwarder

## Why This Exists

The cluster's network blocks direct UDP port 53 traffic to external DNS servers. This prevents CoreDNS from forwarding queries to upstream resolvers like 1.1.1.1 or 8.8.8.8.

This DNS forwarder runs as a DaemonSet with `hostNetwork: true`, listening on port 5353 on each node. It forwards DNS queries to the node's systemd-resolved at 127.0.0.53, which has access to working upstream DNS.

## How It Works

1. **dns-forwarder DaemonSet** - Runs CoreDNS on each node at `<node-ip>:5353`
2. **hostNetwork: true** - Allows access to the node's 127.0.0.53 (systemd-resolved)
3. **CoreDNS** - Patched to forward to the dns-forwarder pods instead of external DNS

## Deployment

```bash
kubectl apply -f infrastructure/dns-forwarder/
```

Verify pods are running:

```bash
kubectl get pods -n kube-system -l app=dns-forwarder
```

## CoreDNS Configuration

After deploying the forwarder (and after any k3s upgrade that resets CoreDNS), patch the CoreDNS ConfigMap to forward to the dns-forwarder:

```bash
kubectl edit configmap coredns -n kube-system
```

Replace the `forward` line:

```
# Change from:
forward . /etc/resolv.conf

# To (use your node IPs):
forward . 192.168.1.100:5353 192.168.1.101:5353 192.168.1.102:5353
```

Then restart CoreDNS:

```bash
kubectl rollout restart deployment coredns -n kube-system
```

## Testing

Test DNS resolution from within the cluster:

```bash
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup github.com
```

## Notes

- This is managed manually (not via ArgoCD) since it's kube-system infrastructure
- k3s upgrades may reset the CoreDNS ConfigMap, requiring the patch to be reapplied
