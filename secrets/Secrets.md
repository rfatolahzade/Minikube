# Secrets

A Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. Such information might otherwise be put in a Pod specification or in a container image. Using a Secret means that you don't need to include confidential data in your application code.

Because Secrets can be created independently of the Pods that use them, there is less risk of the Secret (and its data) being exposed during the workflow of creating, viewing, and editing Pods. Kubernetes, and applications that run in your cluster, can also take additional precautions with Secrets, such as avoiding writing confidential data to nonvolatile storage.

Secrets are similar to ConfigMaps but are specifically intended to hold confidential data.
```bash
echo -n 'myusername' | base64
echo -n 'mypassword' | base64
```
Th output:
```bash
bXl1c2VybmFtZQ==
bXlwYXNzd29yZA==
```
Fill those value inner your yaml file:
```bash
nano  15-secrets.yaml
```
Then create your secret:
```bash
k create -f 15-secrets.yaml
k get secrets
k get secret secret-demo -o yaml
```
######  (--from-literal):
```bash
k create secret generic secret-demo2 --from-literal=username=myusername --from-literal=password=mypassword
k get secret secret-demo2 -o yaml
```
You can see other options: 
```bash
k create secrets --help
```

######  (--from-file):
```bash
vi username 
#fill it with your value
vi password
#fill it with your value
```
then 
```bash
k create secret generic secret-demo3 --from-file=./username --from-file=./password
```

######  As an Environment
It happens as a  Volume or as an Environment, Ensure your secret secret-demo was exists:
Create a pod:
```bash
k create -f  15-pod-secret-env.yaml
k exec -it busybox -- sh
env | grep myusername
echo $myusername
```

######  As a Volume:
```bash
k create -f 15-pod-secret-volume.yaml
k exec -it busybox -- sh
cd mydata/
```
password & username are there.

