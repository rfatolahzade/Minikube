# Helm 
This scenario teaches you how to use most of the features in Helm, a package manager for Kubernetes.

Helm is the best way to find, share, and use software built for Kubernetes.

In the following steps you will learn:

- how to install and uninstall applications,
- what a chart provides,
- how to list public charts,
- how to list and add more repositories,
- how to create a custom chart,
- how to update a chart.

# Install Helm
Helm is a cluster administration tool that manages charts on Kubernetes.

Helm relies on a packaging format called charts. Charts define a composition of related Kubernetes resources and values that make up a deployment solution. Charts are source code that can be packaged, named, versioned, and maintained in version control. The chart is a collection of Kubernetes manifests in the form of YAML files along with a templating language to allow contextual values to be injected into the YAMLs. Charts complement your [infrastructure-as-code](https://en.wikipedia.org/wiki/Infrastructure_as_code) processes.

Helm also helps you manage the complexities of dependency management. Charts can include dependencies on other charts. A chart is a deployable unit that can be inspected, listed, updated, and removed. The Helm CLI tool deploys charts to Kubernetes.

Interaction with Helm is through its command-line tool (CLI). This Katacoda instance already has a recent version of Helm version 3 installed and ready for use:
```bash 
helm version --short
```

This scenario covers version 3.x of Helm. If you are using version 2.x, it's highly advisable to move to the recent version. Helm is evolving and there is a newer version available from its list of [releases](https://github.com/helm/helm/releases). With its shell script installer, Helm can be installed or upgraded from a single line:
```bash 
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```
The current local state of Helm is kept in your environment in the home location:
```bash 
helm env
```
The Helm command line tool defaults to discovering the current Kubernetes host by reading the same configuration that kubectl uses in ~/.kube/config. There is a way to switch the current cluster context, but that's beyond the scope of this scenario.

Now that Helm is working, in the next step you will install a common public chart.

# Search For Chart
Many common and publicly available open source projects can run on Kubernetes. Many of these projects offer containers that package these applications and vetted Helm charts for full production installations on Kubernetes.

Up until recently in 2021, all of the most commonly used public Helm charts were being lumped into a single Git repository for incubating and stable Helm charts. This idea of centralizing all charts in GitHub has since been abandoned, thankfully. There are too many charts now being maintained by many different organizations and projects. Every day more charts are being added to our community.
###  Artifact Hub
Now, the canonical source for cloud native artifacts, and specifically Helm charts, is [Artifact Hub](https://artifacthub.io/), an aggregator for distributed chart repos. This hub has risen from the need for us to have a single place for us to search for charts. While charts are listed here, the actual charts are hosted in a growing variety of repos. If you find a chart of interest the page for the specific chart will reveal the chart name, list of versions (semver.org format) and the repo where the chart can be found.
```diff
- NOTICE: Avoid the deprecated Helm Hub as Artifact Hub is its replacement.
```
There are over 5000 charts available and growing each day:
```bash 
helm search hub | wc -l
``` 
You can search the the Hub for specific charts:
```bash 
helm search hub clair
``` 
You will find different organizations offering overlapping chart solutions for installing a specific technology your are looking for. Look at the various providers for Redis:
```bash 
helm search hub redis
``` 
At last count there were about 30 Redis related public charts. One provider who has been prolific at providing well written charts is Bitnami. So let's narrow our search:
```bash 
helm search hub redis | grep bitnami
``` 
For this scenario we are interested in the [Redis chart described here](https://artifacthub.io/packages/helm/bitnami/redis). Click on that hyperlink to see the chart hosting details.

###  Repos
While the chart is listed in ARtifact Hub, the Bitnami organization has a public repo of all its charts. In each Hub chart page a repo is listed for you to add for access the chart. The instructions for the Redis chart says to add the bitnami repo:
```bash 
helm repo add bitnami https://charts.bitnami.com/bitnami
``` 
Your Helm now has access to the Bitnami charts:
```bash 
helm repo list
``` 
Instead of searching the Hub for charts you can also search the Bitnami repo:
```bash 
helm search repo bitnami/redis
``` 
The Helm command can reveal additional information about the chart:
```bash 
helm show chart bitnami/redis
``` 
The readme:
```bash 
helm show readme bitnami/redis
``` 
The definable context values:
```bash 
helm show values bitnami/redis
``` 
### Fabric8
As another example, if you search Helm for fabric8, nothing will be listed:
```bash 
helm search repo fabric8
```
This is because fabric8 maintains its own chart repository that can be added to Helm:
```bash 
helm repo add fabric8 https://fabric8.io/helm
``` 
With this, the repo will appear in the repo list:
```bash 
helm repo list
``` 
Now, their charts can be listed:
```bash 
helm search repo fabric8
``` 
Now you know how to find and list public charts. In the next step you will install the Redis chart you discovered.

# Deploy Redis
Create a namespace for the installation target:
```bash 
kubectl create namespace redis
``` 
Add the chart repository for the Helm chart to be installed. You did this in the previous step, but it's no harm to attempt to add it twice:
```bash 
helm repo add bitnami https://charts.bitnami.com/bitnami
``` 
With a known chart name, use the install command to deploy the chart to your cluster:
```bash 
helm install my-redis bitnami/redis --version 14.3.3 --namespace redis --values redis-values.yaml
``` 
This will name a new install called my-redis and install a specific chart name and version into the redis namespace. The redis-values file override the chart's default values to ensure there are just 2 slave replicas and some file permission configuration is performed at startup. With the install command Helm will launch the required Deployments, ReplicaSets, Pods, Services, ConfigMaps, or any other Kubernetes resource the chart defines.

Well written charts will present notes as part of the installation instructions. The notes will provide helpful information on how to access the new services. We'll follow these notes in the next step, but first, view all the installed charts:
```bash 
helm list --all-namespaces
#or
helm ls -n redis
``` 
The installed my-redis chart should be listed.
### Chart Installation Information
For each chart deployed to the cluster its deployment information is maintained in a secret stored on the targeted Kubernetes cluster. This way multiple Helm clients can consistently list the installed charts on the cluster. The secrets are deployed to the namespace where the chart is deployed. The secret names have the sh.helm. prefix:
```bash 
kubectl get secrets --all-namespaces | grep sh.helm
``` 
When you ask Helm for a list of charts:
```bash 
helm list -A
``` 
then Helm will query Kubernetes for a list of secrets filtered for Helm:
```bash 
kubectl get secrets --all-namespaces --selector owner=helm
``` 
For the Redis chart, you installed to the redis namespace you can see the secret information about the deployment:
```bash 
kubectl --namespace redis describe secret sh.helm.release.v1.my-redis.v1
``` 
The next step will verify the deployment status.

# Observe Redis
Helm deploys all the chart defined Deployments, Pods, Services. The redis Pod will be in a pending state while the container image is downloaded and until a Persistent Volume is available. Once complete it will move into a running state.
Use the get command to find out what was deployed:
```bash 
watch kubectl get statefulsets,pods,services -n redis
``` 
The Pod will be in a pending state while the Redis container image is downloaded and until a Persistent Volume is available. You will see a my-redis-master-0 and my-redis-replicas-0 and my-redis-replicas-1  pod.
### Create a Persistent Volume for Redis:
```bash 
kubectl apply -f pv.yaml
``` 
and ensure Redis has permissions to write to these mount points:
```bash 
mkdir /mnt/data1 /mnt/data2 /mnt/data3 --mode=777
``` 
Now, notice that in a few moments the Pod status will soon change to Running:
```bash 
watch kubectl get statefulsets,pods,services -n redis
``` 
In a moment and all the 3 Pods (1 master and 2 replicas) will move to the Running state.
You have successfully installed Redis. The redis-cli tool has been installed for this scenario so you can verify Redis on Kubernetes is responding. When the chart installed there were some helpful instruction on how to connect. The following are those instructions.

### Connect to Your Redis Server
To get your password query the Redis Secret:
```bash 
export REDIS_PASSWORD=$(kubectl get secret --namespace redis my-redis -o jsonpath="{.data.redis-password}" | base64 --decode)
``` 
Expose the Redis master service:
```bash 
kubectl port-forward --namespace redis service/my-redis-master 6379:6379 > /dev/null &
``` 
Connect to your database from outside the cluster:
```bash 
redis-cli -h 127.0.0.1 -p 6379 -a $REDIS_PASSWORD ping
``` 
If you see PONG as the response you have connected successfully to the Redis application installed by the Helm chart. Nice work!

# Remove Redis
```bash 
helm delete my-redis -n redis
``` 
release "my-redis" uninstalled as well.
No matter how complex the chart, the delete command will undo everything the install provisioned. The only thin left behind will be the namespace. Delete the namespace:
```bash 
kubectl delete namespace redis
``` 
Next, explore the wealth of charts available.

# Explore Repositories
There are numerous common charts that, as a Kubernetes developer, you may want to leverage:
```bash 
helm search hub postgres
helm search hub sonarqube
helm search hub rabbitmq
helm search hub kafka
helm search hub prometheus-operator
helm search hub tensorflow
helm search hub tekton
``` 
The source code for most charts is typically backed with a GitHub repo, a readme, and a team of people that are subject matter experts in forming these opinionated charts.
What about creating your own chart? 
# Create Chart
Charts are helpful when creating your unique solutions. Application charts are often a combination on 3rd party public charts as well as your own. The first step is to create your new chart:
```bash 
helm create app-chart
``` 
This will create the directory my-app-chart as the skeleton for your chart. All chart directories will have these standard files and directories:
```bash 
tree app-chart
``` 
All of your Kubernetes resource definitions in YAML files are located in the templates directory. Take a look at the top of deployments.yaml:
```bash 
cat app-chart/templates/deployment.yaml | grep 'kind:' -n -B1 -A5
``` 
Notice it looks like a normal deployment YAML with the kind: Deployment defined. However, there is new syntax sugar using double braces {{ .. }}. This is the templating mechanism that Helm uses to inject values into this template. Instead of hard coding in values instead, this templating injects values. The templating language has many features by leveraging the Go templating API.
What about defining the container image for the deployment? That is an injected value as well:
```bash 
cat app-chart/templates/deployment.yaml | grep 'image:' -n -C3
``` 
Notice the {{ .Values.image.repository }}, this is where the container name gets injected. All of these values have defaults typically found in the values.yaml file in the chart directory:
```bash 
cat app-chart/values.yaml | grep 'repository' -n -C3
``` 
Notice the templating key uses the dot ('.') notation to navigate and extract the values from the hierarchy in the values.yaml file.
In this case, the Helm create feature defaulted the deployed container to be the ubiquitous demonstration application nginx.
As is, this chart is ready to be deployed since all the defaults have been supplied. A complete set of sensible defaults is a good practice for any chart you author. A good README for your chart should also have a table to reflect these defaults, options, and descriptions.
Before deploying to Kubernetes, the dry-run feature will list out the resources to the console. This allows you to inspect the injection of the values into the template without committing an installation, a helpful development technique. Observe how the container image name is injected into the template
in my case I set my DockerHub repository (daniweb87/nginx):
```bash 
image:
  repository: daniweb87/nginx
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: "latest"
``` 
then run below command to see what you got:
```bash 
helm install my-app ./app-chart --dry-run --debug | grep 'image: "' -n -C3
``` 
Notice the ImagePullPolicy is set to the default of IfNotPreset. Before we deploy the chart we could modify the values.yaml file and change the policy value in there, but perhaps we would like to locally modify a different policy setting first to verify it works. Use the --set command to override a default value. Here we change the Nginx container image ImagePullPolicy from IfNotPreset to Always:
```bash 
helm install my-app ./app-chart --dry-run --debug --set image.pullPolicy=Always | grep 'image: "' -n -C3
``` 
With the version injecting correctly, install it:
```bash 
helm install my-app ./app-chart --set image.pullPolicy=Always
``` 
To expose your app:
```bash 
k expose deploy my-app-app-chart  --type NodePort --port 80
k port-forward service/my-app-app-chart 8080:80
``` 
Notice: You have to set portforwarding in your editor (VSCode ,... just add port: 8080 in PORTS tab)
In a moment the app will start. Inspect its progress:
```bash 
helm list
kubectl get deployments,service
```

### Making your own chart repo
When you develop your charts, there are a few ways to add your charts to custom repositories, either publicly or privately. Some examples are:
If your chart is in a GitHub account, the location can be registered to Helm so it can pull the chart from that source.
A popular chart repo hosting service you can add to Kubernetes is called [ChartMuseum](https://github.com/helm/chartmuseum). Guess what, it also can be installed with a [ChartMuseum Helm chart](https://artifacthub.io/packages/helm/chartmuseum/chartmuseum).
You can also use GitHub pages to [host an inexpensive chart repo](https://artifacthub.io/packages/helm/chartmuseum/chartmuseum):
```bash 
helm search hub chartmuseum
``` 
There are other helm commands such as helm package and helm pull that open the possibilities to publish charts to these repositories.
# Update Chart
Look at the service. Notice the service type is ClusterIP. To see the Nginx default page we would like to instead expose it as a NodePort. A kubectl patch could be applied, but it would be best to change the values.yaml file. Perhaps this is just to verify. We could simply change the installed application with a new value. Use the Helm upgrade command to modify the deployment:
```bash 
helm upgrade my-app ./app-chart --install --reuse-values --set service.type=NodePort
``` 
Well, this demonstration chart is a bit deficient as it does not allow the values for the NodePort to be assigned. Right now it's a random value. We could modify the chart template to accept a nodePort value, but for this exercise apply this quick patch:
```bash 
kubectl patch service my-app-app-chart --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":31111}]'
``` 
It exposed on port 31111
# Further commands
There are a few more helpful commands that you can discover:
```bash
helm --help
``` 
The :
```bash 
helm lint 
``` 
command will check your charts for errors. Something that commonly happens when editing YAML files and experimenting with the Go templating syntax in the template files.
The 
```bash 
helm test 
``` 
command can be used to bake testing into your chart usage in CI/CD pipelines.
The [helm plugin](https://helm.sh/docs/topics/plugins/) opens Helm for many extension possibilities. Here is a [curated list](https://helm.sh/docs/community/related/) of helpful extensions for Helm.

# Package it all up to share
So far in this tutorial, we've been using the helm install command to install a local, unpacked chart. However, 
if you are looking to share your charts with your team or the community, your consumers will typically install the charts from a tar package.
We can use helm package to create the tar package:

```bash 
helm package ./app-chart
#Successfully packaged chart and saved it to: /home/admin/app-chart-0.1.0.tgz
``` 
Helm will create a app-chart-0.1.0.tgz package in our working directory, using the name and version from the metadata defined in the Chart.yaml file.
A user can install from this package instead of a local directory by passing the package as the parameter to helm install.
```bash 
helm install example app-chart-0.1.0.tgz --set service.type=NodePort
#chack your apps status:
helm status my-app
helm status example
```
# Create Grafana helm chart
let's creace a grafana helm chart :
```bash 
helm create grafana
tree grafana
cat grafana/templates/deployment.yaml | grep 'kind:' -n -B1 -A5
cat grafana/templates/deployment.yaml | grep 'image:' -n -C3
cat grafana/values.yaml | grep 'repository' -n -C3
``` 
We have to remove nginx default in grafana/values.yaml
```bash 
image:
  repository: daniweb87/grafana
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: "latest"
```
and set port:
```bash 
service:
  type: ClusterIP
  port: 3000
```
Also we have to change default port in templates/deployment.yaml
```bash 
          ports:
            - name: http
              containerPort: 3000
              protocol: TCP
```
then check out pre app:
```bash  			  
helm install my-grafana ./grafana --dry-run --debug | grep 'image: "' -n -C3
#OR 
helm lint grafana
```
set some option:
```bash 
helm install my-grafana ./grafana --dry-run --debug --set image.pullPolicy=Always | grep 'image: "' -n -C3
```
Lets install our app:
```bash 
helm install my-grafana ./grafana  --set image.pullPolicy=Always
#Now lets see what we got:
kubectl get all -o wide 
```
to expose:
```bash  
k expose deploy my-grafana  --type NodePort --port 3000
k port-forward service/my-grafana 8081:3000
```

# Dynamically provision NFS persistent volumes with Helm

Install the Helm:
```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm repo list
```
Add a repo to Helm:
```bash
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update 
```
lets see list of clusterrole,clusterrolebinding,role,rolebinding  who is contain nfs:
```bash
k get clusterrole,clusterrolebinding,role,rolebinding | grep nfs   
```
There is no role,rolebinding ,clusterrole, clusterrolebinding contains nfs
So to install the chart with the deploy name nfs-client, run the following command:
 #its creating serviceaccount,clusterrole,clusterrolebinding,role and rolebinding
 ```bash
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=185.97.118.212 \
    --set nfs.path=/srv/nfs/kubedata
```
Now:
```bash	
kga
 k describe pod/nfs-subdir-external-provisioner-75bc8dd749-kj5v6 | less
```
You will see:
```bash
 Environment:
      PROVISIONER_NAME:  cluster.local/nfs-subdir-external-provisioner
      NFS_SERVER:        185.97.118.212
      NFS_PATH:          /srv/nfs/kubedata
    Mounts:
      /persistentvolumes from nfs-subdir-external-provisioner-root (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-9cs6g (ro)
```
We didnt have pv and pvc lets test it now and create PVC,  first replace storageclass name inner pvc yaml file:
```bash
k get storageclass
 #OR
k get sc
```
Now create a pvc: 
```bash
k create -f 20-pvc-nfs-sc.yaml
```
PV automatically created 
```bash
k get pv,pvc
```
on your nfsserver :
```bash
ls /srv/nfs/kubedata
```


