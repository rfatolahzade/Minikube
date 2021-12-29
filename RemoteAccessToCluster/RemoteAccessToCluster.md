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
