# Kustomize
Kustomize is a standalone tool to customize Kubernetes objects through a kustomization file.
Since 1.14, Kubectl also supports the management of Kubernetes objects using a kustomization file. To view Resources found in a directory containing a kustomization file
### Overview of Kustomize

Kustomize is a tool for customizing Kubernetes configurations. It has the following features to manage application configuration files:
```bash
    generating resources from other sources
    setting cross-cutting fields for resources
    composing and customizing collections of resources
```
### Generating Resources
ConfigMaps and Secrets hold configuration or sensitive data that are used by other Kubernetes objects, such as Pods. The source of truth of ConfigMaps or Secrets are usually external to a cluster, such as a .properties file or an SSH keyfile. Kustomize has secretGenerator and configMapGenerator, which generate Secret and ConfigMap from files or literals.

### Setting cross-cutting fields
It is quite common to set cross-cutting fields for all Kubernetes resources in a project. Some use cases for setting cross-cutting fields:

```bash
    setting the same namespace for all Resources
    adding the same name prefix or suffix
    adding the same set of labels
    adding the same set of annotations
```
### Composing and Customizing Resources
It is common to compose a set of Resources in a project and manage them inside the same file or directory. Kustomize offers composing Resources from different files and applying patches or other customization to them.
### Composing
Kustomize supports composition of different resources. The resources field, in the kustomization.yaml file, defines the list of resources to include in a configuration. Set the path to a resource's configuration file in the resources list. 

```bash
git clone https://github.com/RFinland/Minikube.git
cd kustomize
k create -f  nginx-deployment.yaml
k create -f  nginx-svc.yaml
kga
```
wait for everything goes ready, take a look at pod,deployment and svc name
```bash
service/nginx
pod/nginx-0605556
deployment.apps/nginx 
```

now want to change our deployment,service and pod names without change our yaml files once by once:
create kustomize.yaml file and set resources that we want to change:
```bash
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: dev-
resources:
- nginx-deployment.yaml
- nginx-svc.yaml
```
now take a look what we got before applu our changes just run this command in your kustomize directory:
```bash
kubectl kustomize 
#OR 
 kubectl kustomize ./
```
as you'll see namePrefix shown. lets apply this changes to our deployments,svc 
```bash
kubectl apply -k $PWD
kga
```
[for more kustomize options](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)

# Kustomize Helm
Let's create a sample helm project:
```bash
cd Minikube
mkdir -p kustomize-helm
cd kustomize-helm/
helm create helloworld
#Remove unnecessary files:
rm -rf helloworld/templates/*
rm helloworld/values.yaml
rm -rf helloworld/charts/
```

Setup of our pod placed in helloworld/templates/pod.yaml: 
```bash
cat <<EOF > helloworld/templates/pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: helloworld
spec:
  restartPolicy: Never
  containers:
  - name: hello
    image: alpine
    env:
    command: ["/bin/sh","-c"]
    args: ["/bin/echo Hello! My company name is {{ .Values.companyName}}"]
EOF	
```

Setup of our values placed in helloworld/values.yaml: 
```bash	
cat <<EOF > helloworld/values.yaml
companyName: ABC Company
EOF	
```	
Lets install this app:
```bash	
helm install helloworld helloworld
#take a look to logs:
k logs -f helloworld
```	
Result:
companyName: ABC Company
as you can see the 
```bash
 args: ["/bin/echo Hello! My company name is {{ .Values.companyName}}"]
 ```
filled by what we wrote inner values.yaml file:
```bash
 companyName: ABC Company
 ```
 
Now lets change it with kusomize:
we just added employeeName and employeeDepartment as below:
```bash
   - /bin/echo My name is {{ .Values.employeeName}}. I work for {{ .Values.employeeDepartment}} department. Our company name is {{ .Values.companyName}}
```
 let create kustomization.yaml :
```bash	
cat <<EOF > kustomization.yaml
patchesJson6902:
- target:
    version: v1
    kind: Pod
    name: helloworld
  patch: |-
    - op: replace
      path: /spec/containers/0/args
      value: ["/bin/echo My name is {{ .Values.employeeName}}. I work for {{ .Values.employeeDepartment}} department. Our company name is {{ .Values.companyName}}"]
resources:
- helloworld/templates/pod.yaml
EOF	
```	
look at the kustomize build when we are going to create new pod then save it in helloworld/templates/pod1.yaml file:
```bash	
kustomize build > helloworld/templates/pod1.yaml
cat  helloworld/templates/pod1.yaml
```
Result:
```bash	
Result:
apiVersion: v1
kind: Pod
metadata:
  name: helloworld
spec:
  containers:
  - args:
    - /bin/echo My name is {{ .Values.employeeName}}. I work for {{ .Values.employeeDepartment}}
      department. Our company name is {{ .Values.companyName}}
    command:
    - /bin/sh
    - -c
    env: null
    image: alpine
    name: hello
  restartPolicy: Never
```	
Modify values:
```bash	
cat <<EOF > helloworld/values.yaml
employeeName: Chris
companyName: Startup1
employeeDepartment: MDD
EOF
```	
take a look to new values file:
```bash	
cat helloworld/values.yaml
```	
Lets delete helloworld app then install it with new envs:
```bash	
helm ls
helm delete helloworld
helm install helloworld helloworld
#DONT mention on Error: INSTALLATION FAILED: pods "helloworld" already exists
```	
then Logs will be changed to:
```bash	
k logs -f helloworld
#YOUR new envs HERE
#Hello! My company name is Startup1
```	
Export helm template helloworld to podProd.yaml:
```bash	
rm helloworld/templates/pod.yaml
helm template helloworld > podProd.yaml
cat podProd.yaml
```	
Result:
```bash	
# Source: helloworld/templates/pod1.yaml
apiVersion: v1
kind: Pod
metadata:
  name: helloworld
spec:
  containers:
  - args:
    - /bin/echo My name is Chris. I work for MDD
      department. Our company name is Startup1
    command:
    - /bin/sh
    - -c
    env: null
    image: alpine
    name: hello
  restartPolicy: Never
```	

Lets add some new labels:
```bash	
cat <<EOF > kustomization.yaml
commonLabels:
  metrics: level1
resources:
- podProd.yaml

EOF
```	
Export kustomize build to podProd2.yaml:
```bash	
kustomize build  > podProd2.yaml
cat  podProd2.yaml
```	
Result:
```bash	
apiVersion: v1
kind: Pod
metadata:
  labels:
    metrics: level1
  name: helloworld
spec:
  containers:
  - args:
    - /bin/echo My name is Chris. I work for department MDD. Our company name is Startup1
    command:
    - /bin/sh
    - -c
    env: null
    image: alpine
    name: hello
  restartPolicy: Never
```	
Make sure app deleted:
```bash	
helm delete helloworld
k create -f podProd2.yaml
```
Now lets take a look to our new changes:
```bash		
kdp helloworld | less
kdp helloworld |  grep metrics
```	

Other Example:
```bash		
helm template discourse bitnami/discourse > discourse.yaml
cat discourse.yaml
```		
Set some ens:
```bash		
cat <<EOF > kustomization.yaml
commonLabels:
  env: prod
  metrics: level2
resources:
- discourse.yaml

EOF
```
Create the app:
```bash		
k create -k .
```		
Result:
```bash		
serviceaccount/discourse-redis created
configmap/discourse-redis-configuration created
configmap/discourse-redis-health created
configmap/discourse-redis-scripts created
configmap/discourse created
secret/discourse-postgresql created
secret/discourse-discourse created
service/discourse-postgresql created
service/discourse-postgresql-headless created
service/discourse-redis-headless created
service/discourse-redis-master created
service/discourse created
statefulset.apps/discourse-postgresql created
statefulset.apps/discourse-redis-master created
```		
Take a look to our deployed envs:
```bash		
k describe  pod/discourse-redis-master-0  | grep metrics
```		
