# DNS Forwarder

## Why This Exists

The cluster's network blocks direct UDP port 53 traffic to external DNS servers. This prevents CoreDNS from forwarding queries to upstream resolvers like 1.1.1.1 or 8.8.8.8.

This DNS forwarder runs as a DaemonSet with `hostNetwork: true`, listening on port 5353 on each node. It forwards DNS queries to the node's systemd-resolved at 127.0.0.53, which has access to working upstream DNS.

## How It Works

1. **dns-forwarder DaemonSet** - Runs CoreDNS on each node at `<node-ip>:5353`
2. **hostNetwork: true** - Allows access to the node's 127.0.0.53 (systemd-resolved)
3. **CoreDNS** - Patched to forward to the dns-forwarder pods instead of external DNS

## Deployment (Automated)

Run the Ansible playbook to deploy the forwarder, patch CoreDNS, and verify DNS:

```bash
cd ~/projects/homelab/ansible
ansible-playbook playbooks/dns-forwarder.yml
```

This playbook:
1. Applies the dns-forwarder DaemonSet and ConfigMap
2. Discovers node IPs from the Kubernetes API
3. Patches the CoreDNS Corefile `forward` directive to use the forwarder pods
4. Restarts CoreDNS and verifies DNS resolution with a test pod

Re-run after any K3s upgrade that resets the CoreDNS ConfigMap.

## Manual Deployment (Reference)

<details>
<summary>Click to expand manual steps</summary>

Apply manifests:

```bash
kubectl apply -f infrastructure/dns-forwarder/
```

Verify pods are running:

```bash
kubectl get pods -n kube-system -l app=dns-forwarder
```

Patch the CoreDNS ConfigMap to forward to the dns-forwarder:

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

Test DNS resolution:

```bash
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup github.com
```

</details>

## Notes

- This is managed manually (not via ArgoCD) since it's kube-system infrastructure
- K3s upgrades may reset the CoreDNS ConfigMap — re-run the playbook to fix
