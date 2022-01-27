# Namespace stuck into termination
If your namespace stuck into termination state after run this step:
```bash
kubectl delete ns mynamespace
```

In other terminal or press ctrl+c on current terminal then exec delete_stuck_ns.sh with pass your namespace name as below:
The delete_stuck_ns.sh contains these steps:
```bash
#!/usr/bin/env bash

function delete_namespace () {
    echo "Deleting namespace $1"
    kubectl get namespace $1 -o json > tmp.json
    sed -i 's/"kubernetes"//g' tmp.json
    kubectl replace --raw "/api/v1/namespaces/$1/finalize" -f ./tmp.json
    rm ./tmp.json
}

TERMINATING_NS=$(kubectl get ns | awk '$2=="Terminating" {print $1}')

for ns in $TERMINATING_NS
do
    delete_namespace $ns
done
```
So run this command to delete stuck namespace:

```bash
./delete_stuck_ns.sh YOURNAMESPACE
```
After a while your namespace will be deleted as well.
```bash
k get ns
```
Here you go.
