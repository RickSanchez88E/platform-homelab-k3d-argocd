# GitOps Flow – Platform Homelab

This document describes how GitOps works end‑to‑end in this homelab.

---

## What is GitOps?

GitOps is a practice where:

1. **Git is the single source of truth** for the desired state of your infrastructure and applications.
2. An **automated agent** (Argo CD in this case) continuously compares the live cluster state against Git.
3. Any **drift** is automatically corrected — no manual `kubectl apply` needed after bootstrapping.

---

## Step‑by‑Step Flow

```
┌──────────────────────────────────────────────────────────────┐
│ 1.  Developer pushes changes to GitHub                       │
│     (e.g. updates a replica count in kubernetes-manifests/)  │
└────────────────────────────┬─────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│ 2.  Argo CD repo-server polls GitHub every ~3 minutes        │
│     and detects a diff between Git state and live cluster    │
└────────────────────────────┬─────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│ 3.  Argo CD application-controller applies the diff          │
│     (kubectl server-side apply under the hood)               │
└────────────────────────────┬─────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│ 4.  boutique namespace converges to the desired state        │
│     Argo CD UI shows: Synced ✅  Healthy ✅                  │
└──────────────────────────────────────────────────────────────┘
```

---

## Sync Policy Flags Explained

| Flag | Effect |
|---|---|
| `automated.prune: true` | Resources deleted from Git are also deleted from the cluster |
| `automated.selfHeal: true` | Manual changes made directly via `kubectl` are automatically reverted |
| `syncOptions: CreateNamespace=true` | Argo CD creates the `boutique` namespace if it doesn't exist |

---

## Rollback Strategy

Since Git is the source of truth, rollback is simply `git revert` or pointing the Application to a previous commit SHA:

```yaml
source:
  targetRevision: <commit-sha>   # pin to a known-good commit
```

Argo CD will reconcile the cluster back to that historical state automatically.
