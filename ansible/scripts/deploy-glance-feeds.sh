#!/bin/bash
cd /Users/nick/projects/homelab

MAX_RETRIES=5
RETRY_DELAY=10

for i in $(seq 1 $MAX_RETRIES); do
  if ping -c 1 -t 3 10.99.99.21 &>/dev/null; then
    echo "=== $(date) ==="
    /opt/homebrew/bin/ansible-playbook ansible/playbooks/glance-feeds.yml
    exit $?
  fi
  echo "=== $(date) === VPN unreachable, retry $i/$MAX_RETRIES in ${RETRY_DELAY}s"
  sleep $RETRY_DELAY
done

echo "=== $(date) === failed after $MAX_RETRIES retries, VPN still down"
exit 1
