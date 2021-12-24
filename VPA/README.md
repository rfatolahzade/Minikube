# VerticalPodAutoscaler(VPA)
Make sure metrics-server addon is enabled.
```bash
minikube addons enable metrics-server
```
List of VPAs: 
```bash
k get vpa
```

Then we need to autoscalar:
```bash
git clone https://github.com/RFinland/autoscaler.git
cd ~/Minikube/autoscaler/vertical-pod-autoscaler
```
run:
If you already have a autoscaler run :
```bash
./hack/vpa-down.sh
#OR to create:
./hack/vpa-up.sh
```
To print YAML contents with all resources that would be understood by kubectl diff|apply|... commands, you can use
```bash
./hack/vpa-process-yamls.sh print
```
Lets see some change after install autoscaler:
```bash
k get pods -n kube-system
```
As you see:
vpa-admission-controller
vpa-recommender
vpa-updater
Added as well.

Then :
#We set update : Off
Lets create VerticalPodAutoscaler(VPA):
```bash
k create -f  24-vpa-updateModeOff.yaml
k get vpa
k describe vpa my-vpa
```
```bash

nano 24-VPA-Deployment-Labeled.yaml
```
As you can see We have to set selector so we have to set label to our nodes :
```bash
k label node minikube-m02 app=my-app-deployment
k label node minikube-m03 app=my-app-deployment
```
Then 
```bash
k create -f  24-VPA-Deployment-Labeled.yaml
kga
k get vpa 
```
When PROVIDED setted to True then run :
```bash
k describe vpa my-vpa
```
You will see Recommendation:
```bash
  Recommendation:
    Container Recommendations:
      Container Name:  my-container
      Lower Bound:
        Cpu:     25m
        Memory:  262144k
      Target:
        Cpu:     25m
        Memory:  262144k
      Uncapped Target:
        Cpu:     25m
        Memory:  262144k
      Upper Bound:
        Cpu:     95051m
        Memory:  99371500k
```
 Lets set update : Auto , so 
 ```bash
 k delete deployment --all 
 k delete vpa my-vpa  
```
Now we will create a deployment with limit resources :
```bash
k create -f  24-VPA-Deployment-Labeled-Limits.yaml
k describe pod/my-app-deployment-6b9df99b4-fpb5h | less
```
As you can see there: 
```bash
    Requests:
      cpu:        100m
      memory:     50Mi
```
Now lets create VPA with update Auto :
```bash
k create -f  24-vpa-updateModeAuto.yaml
```
after a while, pods recreated automatically, lets describe our new pods and VPA:
```bash
k describe vpa my-vpa
```
#Target: Cpu:     587m and  Memory:  262144k will set to pods
```bash
k describe pod/my-app-deployment-6b9df99b4-4jrgr | less
```
As you can see:
```bash
    Requests:
      cpu:        548m
      memory:     262144k
```