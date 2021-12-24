# Horizontal Pod Autoscaler or (HPA) CPU
First ,We have to enable metrics-server addons
```bash
minikube addons list
minikube addons enable metrics-server
#to disable addon:
minikube addons disable  metrics-server
```
then : 
```bash
minikube start   #maybe its not nesseccary
k top pods -n kube-system
k top nodes -n kube-system
k top pods 
k top nodes
k get services -n kube-system   
#OR 
kubectl get svc -n kube-system 
#You will see the metrics-server as a service 
k get pods -n kube-system
#You will see the metrics-server-77c99ccb96-htgtc as a pod
k get deployments -n kube-system
#You will see the metrics-server  as a deployment
kubectl logs -n kube-system deploy/metrics-server
#Logs of metrics-server deployment 
```
Lets create our deployment :
```bash
nano 21-php-apache.yaml
```
in the container section you see:
```bash
        resources:
          limits:
            cpu: 100m
          requests:
            cpu: 100m
#these lines are our metric-server (limits)
```
then:
```bash
kubectl apply -f 21-php-apache.yaml
```
Then define your HorizontalPodAutoscaler(HPA):
We set maxReplicas to 5 and minReplicas to  1 and   targetCPUUtilizationPercentage to 20%
```bash
k create -f 21-hpa.yaml
#OR use this commnd: 
kubectl autoscale deployment php-apache --cpu-percent=20 --min=1 --max=5
kga
```
Now lets create some trafic inner pod:
```bash
k exec -it pod/php-apache-5b7bcbc4f4-ng49f -- sh
```
You can run "yes" or "apt update" or ...
open new termianl and run 
```bash
kga
```
you will see minikube create new pods to handle trafic, and max pods was 5.

Now lets terminate yes/apt update  command with press ctrl+c , then you will see new pods will be deleted automatically after less more 7 minutes.
# Horizontal Pod Autoscaler or (HPA) Memory
Make sure  metrics-server addon is enabled.
```bash
minikube addons enable metrics-server
```
Lets create our deployment :
```bash
nano 22-nginx-mem.yaml
```
in the container section you see:
```bash
        resources:
          limits:
            memory: 1Gi
          requests:
            memory: 0.5Gi
```
#these lines are our metric-server (limits)
```bash
k create -f 22-nginx-mem.yaml
```
Then define your HorizontalPodAutoscaler(HPA):
```bash
k create -f 22-hpa-mem.yaml
```
Then lets make some trafic:
```bash
k exec -it pod/php-apache-6856c856bd-g9mgk  -- sh
```
inside container: 
```bash
apt update
apt install stress
stress --vm 2 --vm-bytes 200M 
```
out of your pod, run:
```bash
kga
```
as you see new pods created, after you terminate stress , new pods will terminate after 6-7 minutes.
# Disruptions

This guide is for application owners who want to build highly available applications, and thus need to understand what types of disruptions can happen to Pods.

It is also for cluster administrators who want to perform automated cluster actions, like upgrading and autoscaling clusters.
Voluntary and involuntary disruptions

Pods do not disappear until someone (a person or a controller) destroys them, or there is an unavoidable hardware or system software error.

We call these unavoidable cases involuntary disruptions to an application. Examples are:

    a hardware failure of the physical machine backing the node
    cluster administrator deletes VM (instance) by mistake
    cloud provider or hypervisor failure makes VM disappear
    a kernel panic
    the node disappears from the cluster due to cluster network partition
    eviction of a pod due to the node being out-of-resources.

Except for the out-of-resources condition, all these conditions should be familiar to most users; they are not specific to Kubernetes.

We call other cases voluntary disruptions. These include both actions initiated by the application owner and those initiated by a Cluster Administrator. Typical application owner actions include:

    deleting the deployment or other controller that manages the pod
    updating a deployments pod template causing a restart
    directly deleting a pod (e.g. by accident)

Cluster administrator actions include:

    Draining a node for repair or upgrade.
    Draining a node from a cluster to scale the cluster down (learn about Cluster Autoscaling ).
    Removing a pod from a node to permit something else to fit on that node.

These actions might be taken directly by the cluster administrator, or by automation run by the cluster administrator, or by your cluster hosting provider.

Ask your cluster administrator or consult your cloud provider or distribution documentation to determine if any sources of voluntary disruptions are enabled for your cluster. If none are enabled, you can skip creating Pod Disruption Budgets.

    Caution: Not all voluntary disruptions are constrained by Pod Disruption Budgets. For example, deleting deployments or pods bypasses Pod Disruption Budgets.

First create your deployment:
```bash
k create deploy nginx --image nginx
#Scale up to 4
k scale deploy nginx --replicas=4
#Define our Pod Disruption Budget:
k create pdb pdbdemo --min-available 50% --selector "app=nginx"
#OR you can use yaml file : k create -f 23-pdb.yaml
#list of PDB:
k get pdb
#Describe of PDB
k describe pdb pdbdemo
```
Now if you drain a node :
```bash
k drain minikube-m03 --ignore-daemonsets
#( to undrain : kubectl uncordon minikube-m03)
```
You will see your pod deployed on another node, and stayed 4 as you declare in replicas=4
```bash
 #delete all of your pdbs:
 k delete pdb  --all
 ```
 
 
