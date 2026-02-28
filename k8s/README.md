
# Blue-Green App (Kubernetes)

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-6DB33F?style=for-the-badge&logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![Gradle](https://img.shields.io/badge/Gradle-02303A?style=for-the-badge&logo=gradle&logoColor=white)](https://gradle.org/)

This guide explains how to build the image, test it locally, deploy both blue and green versions, and switch traffic between them.

## ✨ Prerequisites

- Docker running locally
- Kubernetes cluster (for example: Docker Desktop, Minikube, or kind)
- `kubectl` configured to your cluster

## 🐳 1) Build Docker images

From the project root, build the tags used by the deployment:

Build both image tags in one command (recommended):

```bash
docker build -t blue-green-app:1.0.0 -t blue-green-app:1.0.1 .
```

Or build each tag separately:

```bash
docker build -t blue-green-app:1.0.0 .  # blue
docker build -t blue-green-app:1.0.1 .  # green
```



## 🧪 2) Quick local test

Run one version locally:

```bash
docker run --rm -p 8080:8080 -e COLOR=blue -e VERSION=1.0.0 blue-green-app:1.0.0
```

In another terminal:

```bash
curl http://localhost:8080/
curl http://localhost:8080/version
curl http://localhost:8080/color
curl http://localhost:8080/healthz
```

## ☸️ 3) Deploy to Kubernetes

Apply the blue/green manifest:

```bash
kubectl apply -f k8s/blue-green-deploy.yaml
```

Check rollout and resources:

```bash
kubectl -n blue-green-demo get deploy,pods,svc
```

## 🌐 4) Expose service locally (port-forward)

```bash
kubectl -n blue-green-demo port-forward svc/blue-green-app 8080:80
```

Then test:

```bash
curl http://localhost:8080/
curl http://localhost:8080/color
curl http://localhost:8080/version
```

## 🔁 5) Switch traffic: blue -> green

The service initially points to blue (`color=blue`).
To route traffic to green:

```bash
kubectl -n blue-green-demo patch service blue-green-app \
	-p '{"spec":{"selector":{"app":"blue-green-app","color":"green"}}}'
```

Verify:

```bash
kubectl -n blue-green-demo get svc blue-green-app -o yaml
curl http://localhost:8080/color
```

To switch back to blue, patch `color` to `blue`.

## 🧹 Cleanup

```bash
kubectl delete -f k8s/blue-green-deploy.yaml
```