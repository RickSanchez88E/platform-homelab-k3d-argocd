# bootstrap.ps1 – One-command homelab setup (Windows / PowerShell)
# Usage: .\scripts\bootstrap.ps1
# Prerequisites: Docker Desktop running, k3d installed, kubectl installed

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Platform Homelab – Bootstrap Script" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ── Step 1: Create k3d cluster ────────────────────────────────────────────────
Write-Host "[1/5] Creating k3d cluster from k3d/homelab.yaml ..." -ForegroundColor Yellow
k3d cluster create --config k3d/homelab.yaml
Write-Host "      Cluster created." -ForegroundColor Green

# ── Step 2: Install Argo CD ───────────────────────────────────────────────────
Write-Host "[2/5] Installing Argo CD ..." -ForegroundColor Yellow
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd `
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
Write-Host "      Argo CD manifests applied." -ForegroundColor Green

# ── Step 3: Wait for Argo CD server ──────────────────────────────────────────
Write-Host "[3/5] Waiting for Argo CD server to become Available (timeout 5 min) ..." -ForegroundColor Yellow
kubectl wait --for=condition=Available deploy/argocd-server `
  -n argocd --timeout=300s
Write-Host "      Argo CD is ready." -ForegroundColor Green

# ── Step 4: Apply Online Boutique Application ─────────────────────────────────
Write-Host "[4/5] Applying Online Boutique Argo CD Application ..." -ForegroundColor Yellow
kubectl apply -f argocd/apps/online-boutique.yaml
Write-Host "      Application manifest applied. Argo CD will start syncing." -ForegroundColor Green

# ── Step 5: Print access info ─────────────────────────────────────────────────
Write-Host ""
Write-Host "[5/5] Bootstrap complete!" -ForegroundColor Green
Write-Host ""
Write-Host "  Access Argo CD UI:" -ForegroundColor Cyan
Write-Host "    kubectl port-forward svc/argocd-server -n argocd 8080:443"
Write-Host "    Then open: https://localhost:8080"
Write-Host ""
Write-Host "  Default Argo CD admin password:"
Write-Host "    kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d"
Write-Host ""
Write-Host "  Access Online Boutique (after sync completes):"
Write-Host "    kubectl port-forward svc/frontend -n boutique 8181:80"
Write-Host "    Then open: http://localhost:8181"
Write-Host ""
