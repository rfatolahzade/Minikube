# All about nodes
![Learn Kubernetes with Minikube](../images/networking-overview.png)
When you deploy Kubernetes, you get a cluster.
A Kubernetes cluster consists of a set of worker machines, called nodes, that run containerized applications. Every cluster has at least one worker node.
The worker node(s) host the Pods that are the components of the application workload. The control plane manages the worker nodes and the Pods in the cluster.
In production environments, the control plane usually runs across multiple computers and a cluster usually runs multiple nodes, providing fault-tolerance and high availability.

# Node wasn't ready:
If your Node was not ready check these steps:
```bash
kubectl get pods -n kube-system        #ALL Kube-System pods must be ready
```
###### Check which node wasn't in ready state:
```bash
    kubectl get nodes 
    kubectl describe node nodename #nodename which is not in ready state.
    #in my case minikube-m03 is not ready:
    kubectl describe node minikube-m03
```
###### ssh to the node:
```bash
   minikube ssh -n minikube-m03
   systemctl status kubelet #Make sure kubelet is running.
   systemctl status docker #Make sure docker service is running.
   sudo journalctl -u kubelet # To Check logs in depth.
   sudo systemctl daemon-reload
   sudo systemctl restart kubelet
```
In case you still didn't get the root cause, check below things:
Make sure your node has enough space and memory. Check for /var directory space especially. 
command to check: 
```bash
free -m
```
Verify cpu utilization with top command. and make sure any process is not taking an unexpected memory.

# Node Labeling:
Labels are key/value pairs that are attached to objects, such as pods. Labels are intended to be used to specify identifying attributes of objects that are meaningful and relevant to users, but do not directly imply semantics to the core system. Labels can be used to organize and to select subsets of objects. Labels can be attached to objects at creation time and subsequently added and modified at any time. Each object can have a set of key/value labels defined. Each Key must be unique for a given object.
###### How to set Label to Nodes:
```bash
k label node minikube-m02 demo=true
k get node minikube-m02 --show-labels
k describe nodes minikube-m02 | grep demo
``` 
###### Use Labels on your Deployment:
Add this line to your deployment file:
```bash
  nodeSelector:
    demo: "true"   
```
Sample:

```bash
git clone https://github.com/RFinland/Minikube.git
cd Minikube
k create -f 1-Using-Labels.yaml	
```
You can see what was you set for your pod(s):
```bash
k get pods
#In my case one of my pods named asnginx-deploy-799b7f9cc6-2t4mr
k describe pod/nginx-deploy-799b7f9cc6-2t4mr  | grep Selectors
```
If you change scale of replicas, all new pods deployed only on you labeled node that you mention on you deployment yaml file:
```bash
k scale deploy nginx-deploy --replicas=4   ####It'll be run a new pod on minikube-m02
```
###### Remove your label
```bash
kubectl label node minikube-m02 demo-
```
###### Add more than one label:
```bash
k label node minikube-m02 demo=true proxy=enable 
```
###### Remove your labels
```bash
k label node minikube-m02 demo- proxy-
```
# Deploy with labels on diff namespaces

###### 1.First of all Actvie PodNodeSelector option:
```bash
minikube ssh -n minikube
```
Edit kube-apiserver.yaml to add PodNodeSelector option:
```bash
sudo nano /etc/kubernetes/manifests/kube-apiserver.yaml
```
Then add PodNodeSelector to enable-admission-plugins:
```bash
   - --enable-admission-plugins=...    to ===>    - --enable-admission-plugins=PodNodeSelector,....
```
###### 2. Next We have to set our labels to nodes:
```bash
k label node minikube-m02 env=prod
k label node minikube-m03 env=dev
```
kube-apiserver-minikube will be reastart to watch:
```bash
k -n kube-system get pods
```

###### 3. Now create NameSpaces:
Create NameSpaces with these commands:
```bash
k create ns prod
k create ns dev
k get ns
```
###### 4. Edit NameSpace:
Edit NameSpace config to use specific label:
```bash
k edit ns dev
```
then type
```bash
:syntax off
```
Add this line under name: dev  :
```bash
  annotations:
    scheduler.alpha.kubernetes.io/node-selector: "env=dev"
```	
source:(https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)
With this setting we told to our namespace only use deployments with dev label to nodes that have dev label	

######  5. Deploy your pod
In this case I deployed a sample nginx:
```bash
k -n dev  create deploy nginx --image nginx
k -n dev scale deployment.apps/nginx --replicas=4
```
Now We see what we want to see, our deployment is deployed on node who has dev Label, in my case minikube-m03
```bash
k -n dev get pods -o wide
```
ShortSteps:
First NameSpace(Just play with label X  ,k edit ns dev ) Then Node(labeled X ,k label node minikube-m03 env=dev) last Deployment (Deploy On ns contains our label)Our Pods created on Node who labeled X
