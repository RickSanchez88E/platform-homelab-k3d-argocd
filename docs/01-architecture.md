# Architecture – Platform Homelab

This document expands on the high‑level design in `README.en.md` / `README.zh.md`.

---

## Node Topology

```
k3d-homelab-loadbalancer  (host tcp :80 / :443)
        │
        ▼
k3d-homelab-server-0      (control plane)
        │
   ┌────┼────┬─────┬─────┐
   ▼    ▼    ▼     ▼     ▼
agent-0 agent-1 agent-2 agent-3 agent-4
  (argocd)       (boutique microservices)
```

All nodes are Docker containers managed by k3d on the developer's Windows machine running Docker Desktop.

---

## Traffic Flow

```
Developer Browser
      │
      │  http://localhost:8181   (kubectl port-forward)
      ▼
 frontend svc  (boutique namespace)
      │
      ├─► productcatalogservice
      ├─► cartservice
      ├─► checkoutservice
      ├─► recommendationservice
      ├─► adservice
      └─► … (11 microservices total)
```

---

## GitOps Reconciliation Loop

```
Git (GitHub)  ──poll every 3 min──►  Argo CD repo-server
                                              │
                                   compute diff (desired vs live)
                                              │
                                     ┌────────┴────────┐
                                     │   drift found?  │
                                     │      YES        │
                                     ▼                 │
                               apply manifests         │ NO: no-op
                                     │
                               boutique namespace synced
```

---

## Key Design Decisions

| Decision | Rationale |
|---|---|
| k3d over kind | Built-in multi-node support and load balancer make it feel closer to a real cluster |
| Argo CD over Flux | Better UI for learning and demonstrating GitOps concepts |
| Upstream manifests (not Helm) | Keeps the setup simple; Helm/Kustomize overrides can be layered in later |
| Single-repo layout | Easier to demonstrate end-to-end; can be split into app-repo + config-repo later |
