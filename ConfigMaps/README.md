# ConfigMaps
A ConfigMap is an API object used to store non-confidential data in key-value pairs. Pods can consume ConfigMaps as environment variables, command-line arguments, or as configuration files in a volume.

A ConfigMap allows you to decouple environment-specific configuration from your container images, so that your applications are easily portable.
List of configmaps:
```bash
k get cm
k get configmaps
k describe configmap kube-root-ca.crt
k describe cm kube-root-ca.crt
```
lets create a cm demo-configmap:
```bash
k create configmap demo-configmap --from-literal=project.name=omega --from-literal=DSNurl=http://v7.sentry.cc
```
###### Using ConfigMap as an Env:
Now create a Pod with env that valueFrom configMapKeyRef:
```bash
k create -f  16-pod-configmap-env.yaml
k exec -it busybox -- sh
env | grep PROJECT
```
###### Using ConfigMap as an Volume:
Now create pod and use config map as a Volume:
If your DATABASE config was somewhere (in my case /home/minikube/misc/my.cnf)
```bash
k create cm mysql-demo-config --from-file=/home/minikube/misc/my.cnf  
k get cm mysql-demo-config -o yaml       #you can see your /home/minikube/misc/my.cnf detail
```
then create a pod :
```bash
k create -f  16-pod-configmap-mysql-volume.yaml
k exec -it busybox sh 
ls /mydata #my.cnf is there
```
If you edit your cm inner of your busybox /mydaya/my.cnf will be change aftr a while also it happens when you use cm as an env:
```bash
k edit cm mysql-demo-config
k exec -it busybox sh 
cat /mydata/my.cnf
```

###### immutable 
Notice: if you add this option you can't change secret / config map anymore 
```bash
k edit cm demo-configmap
```
Upper of metadata add :
```bash
immutable: true 
```
Save it and exit.
after set immutable: true you can not edit your cm :
 data: Forbidden: field is immutable when `immutable` is set
Also you can not delete this option to edit your cm or secret
You have to delete your cm or secret to able to edit them.
