# Jenkins Setup on Home Server (K3s + Helm)

This guide documents the steps followed to set up Jenkins on a home server using Kubernetes (k3s), Helm, and custom plugin management. It also covers troubleshooting plugin dependencies and configuring passwordless sudo for automation.

---

## 1. Prerequisites
- Ubuntu/Debian-based server (tested on Ubuntu)
- User with SSH access (e.g., `khushal`)
- Docker installed
- k3s (lightweight Kubernetes) installed
- Helm installed

---

## 2. Install Docker
```
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```
Log out and back in to apply the group change.

---

## 3. Install k3s (Kubernetes)
```
curl -sfL https://get.k3s.io | sh -
# Check status
sudo k3s kubectl get nodes
```

---

## 4. Configure kubectl Access
```
sudo cat /etc/rancher/k3s/k3s.yaml > ~/k3s.yaml
export KUBECONFIG=~/k3s.yaml
```

---

## 5. Install Helm
```
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

---

## 6. Add Jenkins Helm Repo
```
helm repo add jenkins https://charts.jenkins.io
helm repo update
```

---

## 7. Prepare Jenkins Values File
Use the provided `jenkins-values.yaml` file in this directory. This file contains the latest working configuration, including the correct plugin list and JCasC settings.

---

## 8. Passwordless Sudo for Automation
To allow the user to run sudo commands without a password (for automation):
```
echo 'khushal ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/khushal
sudo chmod 440 /etc/sudoers.d/khushal
```

---

## 9. Install Jenkins with Helm
```
helm install jenkins jenkins/jenkins -f jenkins-values.yaml -n jenkins --create-namespace
```

---

## 10. Troubleshooting Plugin Dependencies
If Jenkins init container fails due to plugin version conflicts:
- Uninstall Jenkins and delete the PersistentVolumeClaim to clear cached plugins:
```
helm uninstall jenkins -n jenkins
kubectl delete pvc -n jenkins --all
```
- Reinstall Jenkins:
```
helm install jenkins jenkins/jenkins -f jenkins-values.yaml -n jenkins --create-namespace
```

---

## 11. Access Jenkins
- Get the NodePort:
```
kubectl get --namespace jenkins -o jsonpath="{.spec.ports[0].nodePort}" services jenkins
```
- Access Jenkins at: `http://<server-ip>:<node-port>`
- Default credentials: `admin` / `admin` (change after first login)

---

## 12. Next Steps
- Configure Jenkins security and jobs
- Set up your CI/CD pipelines
- (Optional) Secure Jenkins with HTTPS and a reverse proxy

---

## References
- [Jenkins Helm Chart](https://github.com/jenkinsci/helm-charts)
- [Jenkins Plugin Manager](https://github.com/jenkinsci/plugin-installation-manager-tool)
- [k3s Documentation](https://rancher.com/docs/k3s/latest/en/)
- [Helm Documentation](https://helm.sh/docs/) 