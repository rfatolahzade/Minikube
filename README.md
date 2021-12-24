![Learn Kubernetes with Minikube](images/minikube-logo.jpg)
# Learn Kubernetes with Minikube (Easy Steps)
minikube is local Kubernetes, focusing on making it easy to learn and develop for Kubernetes.
All you need is Docker (or similarly compatible) container or a Virtual Machine environment, and Kubernetes is a single command away: minikube start
##### Requirements
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
apt install -y  virtualbox virtualbox-ext-pack
```
##### Installation
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
alias kcc='k config current-context'
alias kcu='k config use-context'
alias kg='k get'
alias kdp='k describe pod' 
alias kdes='k describe'
alias kdd='k describe deployment'
alias kds='k describe svc'
alias kdr='k describe replicaset'
#alias kk='k3s kubectl'
alias vk='k --kubeconfig'
alias kcg='k config get-contexts'
alias kgaks='watch -x kubectl get all -o wide -n kube-system'

EOF
```
I use these aliases for minikube,k3s,k3d,vcluster 

# Start your cluster
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
  - [Dashboard](../master/dashboard/README.md)
  - [Nodes](../master/nodes/README.md)
  - [DaemonSets](../master/DaemonSets/README.md)
  - [Job-CronJob](../master/jobs/README.md)
  - [Init Container](../master/InitContainer/README.md)
  - [PV-PVC](../master/PV-PVC/README.md)
  - [Secrets](../master/Secrets/README.md)
  - [ConfigMaps](../master/ConfigMaps/README.md)
  - [ResourceQuota](../master/ResourceQuota/README.md)
  - [NFS](../master/NFS/README.md)
  - [Statefulsets](../master/Statefulsets/README.md)
  - [Helm](../master/Helm/README.md)
  - [Kustomize](../master/Kustomize/README.md)
  - [HPA](../master/HPA/README.md)
  - [VPA](../master/VPA/README.md)


# Remote access to cluster
### On your client (your laptop ,... )
run:
```bash
mkdir ~/.minikube_remote
cd ~/.minikube_remote
```
Then copy ca.crt,client.crt,client.key and kubeconfig:
```bash
#change user and ip as yours
scp admin@192.168.1.209:.minikube/ca.crt .
scp admin@192.168.1.209:.minikube/profiles/minikube/client.crt .
scp admin@192.168.1.209:.minikube/profiles/minikube/client.key .
#copy minikube config file:
scp admin@192.168.1.209:~/.kube/config /.kube
```
Change the server,certificate-authority,client-certificate and client-key lines inner config file to use the host ip and the port we just opened,Your config file will be similar as:
```bash
cat <<EOF > ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority: ../.minikube_remote/ca.crt
    server: https://kubernetes:51999
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: ../.minikube_remote/client.crt
    client-key: ../.minikube_remote/client.key
EOF
```
```diff
- NOTICE: you have to add "kubernetes" to your hosts file (/etc/hosts) on your client:
# 192.168.1.209 kubernetes
```
### On the server: 
Use socat as a TCP port forwarder, create socat-port.sh with this line [for more socat options](https://www.redhat.com/sysadmin/getting-started-socat)
For multiple connections, use the fork option:
```bash
touch socat-port.sh
cat <<EOF > socat-port.sh
socat TCP4-LISTEN:$1,fork TCP4:$2 &>/dev/null
EOF
```
Then run:
```bash
socat-port.sh 51999 192.168.49.2:8443 &
#OR just run this command:
socat TCP4-LISTEN:51999,fork TCP4:192.168.49.2:8443 &
```
### On the client:
You can see your server stuff as well, you can deploy your app from client to server 
Now you should be able to use the kubectl on the client(your laptop,...) to remote access the minikube on the Server
The best part about this is that kubectl port-forward should work as normal too in case you need to access services in your cluster.
Lets try this:
### On the client:
```bash
k  create deploy nginx --image nginx
```
As youll see your deployment done as well 
### On the Server: 
```bash
k expose deploy nginx --type NodePort --port 80
kubectl port-forward service/nginx --address='0.0.0.0' 8080:80
```
### On the client:
```bash
curl kubernetes:8080
```
Kill port command:
```bash
fuser -k 51999/tcp 
```

# Init Containers
This example defines a simple Pod that has two init containers. The first waits for myservice, and the second waits for mydb. Once both init containers complete, the Pod runs the app container from its spec section.

You can start this Pod by running:
```
git clone https://github.com/rfinland/Minikube.git
cd Minikube
cat myapp.yaml
kubectl apply -f myapp.yaml
#And check on its status with:
kubectl get -f myapp.yaml
#STATUS: Init:0/2 
```
or for more details:
```bash
kubectl describe -f myapp.yaml
#State:Waiting
```
To see logs for the init containers in this Pod, run:
```bash
kubectl logs myapp-pod -c init-myservice # Inspect the first init container
kubectl logs myapp-pod -c init-mydb      # Inspect the second init container
```

At this point, those init containers will be waiting to discover Services named mydb and myservice.
Here's a configuration you can use to make those Services appear:

```bash
cat services.yaml
kubectl apply -f services.yaml
kubectl get -f myapp.yaml
#STATUS: Running
```

[Development with DevSpace](https://github.com/rfinland/Minikube/tree/master/devspace/README.md)

# namespace stuck into termination
If your namespace stuck into termination state do these steps:
```bash
kubectl delete ns mynamespace
#in other terminal or ctrl+c on current termianl then run:
./delete_stuck_ns.sh mynamespace
```

Have fun!
