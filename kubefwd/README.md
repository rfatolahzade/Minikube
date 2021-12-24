# kubefwd
kubefwd is used to forward Kubernetes services running in a remote cluster to a local workstation, easing the development of applications that communicate with other services. kubefwd, pronounced Kube Forward, is a single binary, command line application written in Go.

kubefwd does not require you to make any modifications to remote clusters. If you currently use kubectl, you have met the requirements for kubefwd.

Create a sample nginx deplyment and expose it as a service:
```bash
k create deploy nginx --image nginx
k expose deploy nginx-deploy --type NodePort --port 80
```
on your windows :
```bash
scoop install kubefwd
kubefwd svc -n default
```
Now you can visit:
```bash
127.1.27.1
#OR
nginx:80
```
