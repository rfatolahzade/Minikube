![Learn Kubernetes with Minikube](images/minikube-logo.jpg)
# Learn Kubernetes with Minikube (Easy Steps)
minikube is local Kubernetes, focusing on making it easy to learn and develop for Kubernetes.
All you need is Docker (or similarly compatible) container or a Virtual Machine environment, and Kubernetes is a single command away: minikube start
# Requirements
The Kubernetes command-line tool, **kubectl**, allows you to run commands against Kubernetes clusters. You can use kubectl to deploy applications, inspect and manage cluster resources, and view logs. 
Install kubectl on Linux:
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
cp kubectl /usr/local/bin/
chmod +x  /usr/local/bin/kubectl
```
In some cases you need these packages:
```bash
apt install -y socat
apt install -y  apt-transport-https
apt install -y conntrack
#apt install -y  virtualbox virtualbox-ext-pack
```
# Installation
To install the latest minikube stable release on x86-64 Linux using binary download:
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube
```
In my case I set up these very useful aliases (~/.bashrc) and autocompletion:
```bash
cat <<EOF >> ~/.bashrc
alias k='kubectl'
alias kga='watch -x kubectl get all -o wide'
alias kgad='watch -dx kubectl get all -o wide'
alias kcf='kubectl create -f'
alias wk='watch -x kubectl'
alias wkd='watch -dx kubectl'
alias kd='kubectl delete'
alias kcc='kubectl config current-context'
alias kcu='kubectl config use-context'
alias kg='kubectl get'
alias kdp='kubectl describe pod' 
alias kdes='kubectl describe'
alias kdd='kubectl describe deployment'
alias kds='kubectl describe svc'
alias kdr='kubectl describe replicaset'
alias kk='k3s kubectl'
alias vk='kubectl --kubeconfig'
alias kcg='kubectl config get-contexts'
alias kgaks='watch -x kubectl get all -o wide -n kube-system'
alias kapi='kubectl api-resources'
alias kgaing='watch -x kubectl get all -n ingress-nginx -o wide'

EOF
```
I use these aliases for minikube,k3s,k3d,vcluster 

# Start cluster
You have to (maybe there are other solutions) run cluster on non-root users(in my case ubuntu):
```bash
usermod -aG sudo ubuntu
```
And then run "visudo" and add:
```bash
ubuntu ALL=(ALL) NOPASSWD:ALL
```
Save the sudoers file and run:
```bash
sudo usermod -aG docker $USER && newgrp docker
```
From a terminal with administrator access (but not logged in as root), run:
```bash
minikube start 
systemctl enable kubelet.service
```
If minikube fails to start, see the drivers [drivers](https://minikube.sigs.k8s.io/docs/drivers) page for help setting up a compatible container or virtual-machine manager.Your command will look like:
```bash
minikube start --vm-driver=none
```
# Check out
Let's see what we have done till now:
```bash
k cluster-info
kubectl get pods -A 
#OR
minikube kubectl -- get pods -A
```
# Table and Content
  - [Dashboard](../master/dashboard/)
  - [Nodes](../master/nodes/)
  - [Services](../master/services/)
  - [DaemonSets](../master/DaemonSets/)
  - [Job-CronJob](../master/jobs/)
  - [Init Container](../master/InitContainer/)
  - [PV-PVC](../master/PV-PVC/)
  - [Secrets](../master/secrets/)
  - [ConfigMaps](../master/ConfigMaps/)
  - [ResourceQuota](../master/ResourceQuota/)
  - [NFS](../master/NFS/)
  - [Statefulsets](../master/Statefulsets/)
  - [Helm](../master/Helm/)
  - [Kustomize](../main/kustomize/)
  - [HPA](../master/HPA/)
  - [VPA](../master/VPA/)
  - [RemoteAccessToCluster](../master/RemoteAccessToCluster/)
  - [DevSpace](../master/devspace/)
  - [NameSpaceStuckIntoTermination](../master/nstermination/)
  - [kubefwd](../master/kubefwd/)

#### Relative repositories:
  - [Kind](https://github.com/rfinland/Kind) , [ParseChart](https://github.com/rfinland/ParseChart) , [ArgoCD](https://github.com/rfinland/argocd) , [Vcluster](https://github.com/rfinland/vcluster) , [Devspace-Vcluster-Argocd-prod](https://github.com/rfinland/Devspace-vcluster-argocd-prod) , [Nomad](https://github.com/rfinland/nomad) , [Bitnami-charts](https://github.com/rfinland/bitnami-charts) , [Okteto](https://github.com/rfinland/Okteto-HelloWorld) , [Autoscaler](https://github.com/rfinland/autoscaler) , [Tilt](https://github.com/rfinland/tilt-example-html) , [NFS Subdir External Provisioner](https://github.com/rfinland/nfs-subdir-external-provisioner)

Have fun!
