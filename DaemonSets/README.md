# DaemonSet 
![DaemeoSets](../images/DaemonSets.png)
A DaemonSet ensures that all (or some) Nodes run a copy of a Pod. As nodes are added to the cluster, Pods are added to them.
As nodes are removed from the cluster, those Pods are garbage collected. Deleting a DaemonSet will clean up the Pods it created.
When using Kubernetes, most of the time you don’t care where your pods are running, but sometimes you want to run a single pod on all your nodes.
For example, you might want to run fluentd on all your nodes to collect logs. In this case, using a DaemonSet tells Kubernetes to make sure there is one instance of the pod on nodes in your cluster.
Some typical uses of a DaemonSet are:
- running a cluster storage daemon on every node
- running a logs collection daemon on every node
- running a node monitoring daemon on every node

In a simple case, one DaemonSet, covering all nodes, would be used for each type of daemon.
A more complex setup might use multiple DaemonSets for a single type of daemon, but with different flags and/or different memory and cpu requests for different hardware types.
```bash
k apply -f 2-Using-Daemonset.yaml
k get ds
```
First it will be set demotype=nginx-daemonset-demo to all of the nodes then Deployed on all of them. 
Then If you add a new node :
```bash
minikube node add
```
Atleast your new node gets ready (a copy of a Pod runs as well) :
```bash
kga 
```

```bash
#Watch list of ds system:
k get daemonset -n kube-system
#Describe your daemonset:
k describe daemonset nginx-daemonset
k describe pod/nginx-daemonset-ldbjz
```

If you delete youe daemonset:
```bash
k delete daemonset.apps/nginx-daemonset 
```
All of your pods will be delete
Also you can use nodeSelector on your yaml file of daemonse (think about it).
