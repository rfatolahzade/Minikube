# ResourceQuota
When several users or teams share a cluster with a fixed number of nodes, there is a concern that one team could use more than its fair share of resources.

Resource quotas are a tool for administrators to address this concern.

A resource quota, defined by a ResourceQuota object, provides constraints that limit aggregate resource consumption per namespace. It can limit the quantity of objects that can be created in a namespace by type, as well as the total amount of compute resources that may be consumed by resources in that namespace.

First lets play with context:
```bash
#List of contexts:
kubectl config get-contexts   #context who has * is your current context
#current context
k config current-context
#Create a context linked to your namespace:
k create ns quota-demo-ns
k config set-context quota-demo-ns --namespace=quota-demo-ns --user=minikube --cluster=minikube
#Change current context:
k config use-context quota-demo-ns
```
#Delete The contexts (if you want to recreate or ...):
```bash
kubectl config get-contexts  
kubectl config unset clusters.quota-demo-ns
kubectl config unset users.quota-demo-ns
kubectl config unset contexts.quota-demo-ns
```

Now Create quota:
```bash
k create -f 17-quota-count.yaml
```
In this config we set on namespace: quota-demo-ns our limits are pods: "2"  and configmaps: "2"
```bash
#List of quotas:
k get quota
#Make sure your current-context is quota-demo-ns or run this command:
k config use-context quota-demo-ns
#describe created quota:
k describe quota quota-demo
#OR
k -n quota-demo-ns describe quota quota-demo
```
Now lets play with configmap limits , in our quota yaml file we set configmaps: "2" :
```bash
k create cm cm1 --from-literal=name=testme
k describe quota quota-demo
```
You can not create another configmap:
```bash
k create cm cm2 --from-literal=name=testme
```
It returns :
```
error: failed to create configmap: configmaps "cm2" is forbidden: exceeded quota: quota-demo, requested: configmaps=1, used: configmaps=2, limited: configmaps=2
```
Also you can test it with pod, you can not creat more than two pods.
```bash
k create deploy nginx --image nginx 
k scale deploy nginx  --replicas=2
```
But you can not do:
```bash
k scale deploy nginx  --replicas=3
kga
```
You can see DESIRED =3 but CURRENT = 2 on replicasets section, and in deployment section: READY 2/3 
if you describe deployment:
```bash
k describe deployment.apps/nginx
# Replicas: 3 desired | 2 updated | 2 total | 2 available | 1 unavailable
```
Till now we limit cm and pods , also you can limit job,cron job and mem or cpu 

###### Limit MEM:
```bash
k delete quota quota-demo
k create -f 17-quota-mem.yaml
k get quota
```

Lets create a Pod:
```bash
k create -f 17-pod-quota-mem.yaml
```
So :
```bash
Error from server (Forbidden): error when creating "17-pod-quota-mem.yaml": pods "nginx" is forbidden: failed quota: quota-demo-mem: must specify limits.memory
```
Beacuse you have to set limits in your pod definition:
```bash
lets define limits:
	resources:
	  limits:
		memory: "100Mi"
```
So
```bash
k create -f 17-pod-quota-mem-limits.yaml
```
Now pod created.
```bash
k get quota
#You can see limits.memory: 100Mi/500Mi
```

Also you can define limit range for all , and no need to define any single pods definitis.
```bash
k delete quota quota-demo-mem
k create -f 17-quota-limitrange.yaml
k get limitrange
k describe pod/nginx
```
You can see what you set in limitrange :
```bash
 Limits:
      memory:  300Mi
    Requests:
      memory:     50Mi
```	  
So 
```bash
k create -f  17-reqlimits.yaml
k get quota
```

You will see:
```bash
  REQUEST                    LIMIT
 requests.memory: 0/100Mi   limits.memory: 0/500Mi
```
Now lets create a pod:
```bash
k create -f  17-limitresources.yaml
```
Error :
```bash
Error from server (Forbidden): error when creating "17-limitresources.yaml": pods "nginx" is forbidden: exceeded quota: quota-demo-mem, requested: requests.memory=200Mi, used: requests.memory=0, limited: requests.memory=100Mi
```
it means you have to define requests limit as below:
```bash
k create -f  17-limitresources-fixed.yaml
kga
```
As you have seen in this exercise, you can use a ResourceQuota to restrict the memory request total for all Containers running in a namespace. You can also restrict the totals for memory limit, cpu request, and cpu limit.
