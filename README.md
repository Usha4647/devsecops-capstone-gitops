# devsecops-capstone-gitops

[![Validate chart](https://github.com/ravinadh777/devsecops-capstone-gitops/actions/workflows/validate.yml/badge.svg)](https://github.com/ravinadh777/devsecops-capstone-gitops/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Desired state for the [Student Task Manager](https://github.com/ravinadh777/devsecops-capstone-app).
Argo CD watches this repository and reconciles the `capstone` namespace to match it.
Because the repo is public, Argo CD needs no credentials to read it.

- `charts/student-task-manager/`: Helm chart (app, optional PostgreSQL, KEDA, ServiceMonitor, dashboard, NetworkPolicies)
- `apps/`: Argo CD AppProject and Application
- `platform/`: Helm values for Argo CD, kube-prometheus-stack, KEDA, metrics-server; SonarQube compose file

`values-demo.yaml` is changed only by the app repo's CI (after every gate passed)
or by a reviewed pull request. The chart refuses `latest` or placeholder tags.

```bash
helm lint charts/student-task-manager -f charts/student-task-manager/values-demo.yaml --set image.tag=abc1234
helm template stm charts/student-task-manager -f charts/student-task-manager/values-dev.yaml --set image.tag=abc1234
```
MIT licensed.
