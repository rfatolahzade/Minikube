# namespace stuck into termination
If your namespace stuck into termination state do these steps:
```bash
kubectl delete ns mynamespace
#in other terminal or ctrl+c on current termianl then run:
./delete_stuck_ns.sh mynamespace
```
