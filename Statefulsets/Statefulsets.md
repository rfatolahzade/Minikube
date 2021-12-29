# Statefulsets
StatefulSet is the workload API object used to manage stateful applications.

Manages the deployment and scaling of a set of Pods, and provides guarantees about the ordering and uniqueness of these Pods.

Like a Deployment, a StatefulSet manages Pods that are based on an identical container spec. Unlike a Deployment, a StatefulSet maintains a sticky identity for each of their Pods. These pods are created from the same spec, but are not interchangeable: each has a persistent identifier that it maintains across any rescheduling.

If you want to use storage volumes to provide persistence for your workload, you can use a StatefulSet as part of the solution. Although individual Pods in a StatefulSet are susceptible to failure, the persistent Pod identifiers make it easier to match existing volumes to the new Pods that replace any that have failed.
Using StatefulSets

StatefulSets are valuable for applications that require one or more of the following.

    Stable, unique network identifiers.
    Stable, persistent storage.
    Ordered, graceful deployment and scaling.
    Ordered, automated rolling updates.

In the above, stable is synonymous with persistence across Pod (re)scheduling. If an application doesn't require any stable identifiers or ordered deployment, deletion, or scaling, you should deploy your application using a workload object that provides a set of stateless replicas. Deployment or ReplicaSet may be better suited to your stateless needs.
Limitations

    The storage for a given Pod must either be provisioned by a PersistentVolume Provisioner based on the requested storage class, or pre-provisioned by an admin.
    Deleting and/or scaling a StatefulSet down will not delete the volumes associated with the StatefulSet. This is done to ensure data safety, which is generally more valuable than an automatic purge of all related StatefulSet resources.
    StatefulSets currently require a Headless Service to be responsible for the network identity of the Pods. You are responsible for creating this Service.
    StatefulSets do not provide any guarantees on the termination of pods when a StatefulSet is deleted. To achieve ordered and graceful termination of the pods in the StatefulSet, it is possible to scale the StatefulSet down to 0 prior to deletion.
    When using Rolling Updates with the default Pod Management Policy (OrderedReady), it's possible to get into a broken state that requires manual intervention to repair.
On NFS Server:
```bash
mkdir /srv/nfs/kubedata/{pv0,pv1,pv2,pv3,pv4}
sudo chmod -R 777 /srv/nfs
```
On your host:

nano 19-sts-pv.yaml and set your nfsserver ip :
```bash
nano 19-sts-pv.yaml
```
then:
```bash
k create  -f 19-sts-pv.yaml
```
Then create your pod:
```bash
k create  -f 19-sts-nginx.yaml
```
On your nfsserver go to the path of your used pv (to  findout which pv file):
```bash
k get pv 
#see the bounded pvs and  claimed to default/www-nginx-sts-1  
#OR
k get pvc 
#www-nginx-sts-1   Bound    pv-nfs-pv2 
```
So on your nfsserver go to this path :
```bash
cd /srv/nfs/kubedata/pv2
touch hello
```
For sure:
```bash
k exec -it pod/nginx-sts-1 /bin/bash
cd /var/www
ls 
```
You can see hello in this path .
Now delete your pod:
```bash
k delete pod nginx-sts-1
```
It will delete the pod (nginx-sts-1) and recreate it again:
Then on your nfsserver:
```bash
ls /srv/nfs/kubedata/pv2
```
and ur file exists , all pod use same pvc 
#and ur file exists , all pod use same pvc 
```bash
k get sts
```

Lets delete everything:
```bash
k delete sts nginx-sts
k delete service/nginx-headless
```
Other way:
```bash
k scale sts nginx-sts --replicas=0
```
Also your pvc and pv remains, you haveto delete them mannually :
```bash
k delete pvc --all
k delete pv --all
```
Now lets do it parralel :
19-sts-nginx-Parralel.yaml
```bash

k create  -f 19-sts-nginx-Parralel.yaml
kga
```
As you see status is Pending and you have to create your pv (your pvc will be create automatically):
```bash
k create  -f 19-sts-pv.yaml
kga
```
Notice after delete everything you have to check pvc list that which one connected to your pod.