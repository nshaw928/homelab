#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Argo CD App-of-Apps Bootstrap${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl not found. Please install kubectl first.${NC}"
    exit 1
fi

# Check if connected to cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Error: Cannot connect to Kubernetes cluster. Please configure kubectl.${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 1: Creating argocd namespace${NC}"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo -e "${YELLOW}Step 2: Installing Argo CD (initial bootstrap)${NC}"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo ""
echo -e "${YELLOW}Step 3: Waiting for Argo CD to be ready...${NC}"
echo "This may take a few minutes..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

echo ""
echo -e "${YELLOW}Step 4: Applying root App-of-Apps${NC}"
kubectl apply -f /home/nick/homelab/argocd/root-app.yaml

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Bootstrap Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}What just happened?${NC}"
echo "1. Argo CD was installed manually (initial bootstrap)"
echo "2. The 'root-app' was created, which will now manage:"
echo "   - Argo CD itself (self-management)"
echo "   - Bootstrap resources (namespaces)"
echo "   - Infrastructure (cert-manager)"
echo "   - All your applications (productivity, AI)"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1. Get the initial admin password:"
echo -e "   ${BLUE}kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d${NC}"
echo ""
echo "2. Access Argo CD UI:"
echo -e "   ${BLUE}kubectl port-forward svc/argocd-server -n argocd 8080:443${NC}"
echo "   Then open: https://localhost:8080"
echo "   (Or use ingress: https://argocd.nicholasshaw.cloud)"
echo ""
echo "3. Login with:"
echo "   Username: admin"
echo "   Password: (from step 1)"
echo ""
echo "4. Watch the magic happen!"
echo "   In the UI, you'll see Argo CD manage itself and deploy all your apps"
echo ""
echo "5. IMPORTANT: After logging in, change admin password and delete secret:"
echo -e "   ${BLUE}argocd account update-password${NC}"
echo -e "   ${BLUE}kubectl -n argocd delete secret argocd-initial-admin-secret${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} Your existing apps won't be affected during this process."
echo "Argo CD will detect they're already deployed and just start managing them."
echo ""