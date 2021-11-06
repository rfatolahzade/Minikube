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