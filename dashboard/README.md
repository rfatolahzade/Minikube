
# Dashboard
![Dashboard](../images/ui-dashboard.png)
Minikube has integrated support for the Kubernetes Dashboard UI.
```bash
minikube addons list
minikube addons enable dashboard
#OR just run:minikube dashboard
```
Getting just the dashboard URL
If you don’t want to open a web browser, the dashboard command can also simply emit a URL:
```bash
minikube dashboard --url
```
# Creating a sample user
```bash
touch dashboard-adminuser.yaml
```
then fill it as below:
```bash
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
```
# Creating a ClusterRoleBinding
```bash
touch rolebinding.yaml 
```
then fill it as below:
```bash
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```
# Your Token
to catchig your secret key run this command:
```bash
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
```
here you go copy the token and paste it into Enter token field on the login screen.
Token for your dashboard:
```bash
kubectl -n kube-system describe secret deployment-controller-token
```
# Visit dashboard on local
You need to setting up Tunnel to your VMware so run this command with your details:
```bash
ssh -i D:\YOURKEY.ppk -L 8081:localhost:PORTOFYOURDASHBOARD root@VMIP
```
"Do not close your ssh session"
Now visit your dashboard on your system (your link will looks like mine)
```bash
http://127.0.0.1:8081/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```
Here you go! ;)
