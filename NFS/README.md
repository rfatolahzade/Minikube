# NFS
Network File Sharing (NFS) is a protocol that allows you to share directories and files with other Linux clients over a network. Shared directories are typically created on a file server, running the NFS server component. Users add files to them, which are then shared with other users who have access to the folder.

An NFS file share is mounted on a client machine, making it available just like folders the user created locally. NFS is particularly useful when disk space is limited and you need to exchange public data between client computers.

###### On your NFS SERVER:
```bash
apt -y install nfs-kernel-server
#OR 
apt install nfs-server
systemctl enable nfs-server
systemctl start  nfs-server
vi /etc/exports
#add the path
/srv/nfs/kubedata     *(rw,sync,no_subtree_check,insecure)
```
Create the path:
```bash
mkdir -p /srv/nfs/kubedata
chmod -R 777 /srv/nfs
```
See settings:
```bash
exportfs -rav
#exporting *:/srv/nfs/kubedata
exportfs -v
showmount -e
#/srv/nfs/kubedata *
```
Test your node before do it with minikube:
###### ON YOUR NODE worker:
```bash
minikube ssh -n minikube-m02
ping 185.97.118.212
showmount -e 185.97.118.212   #IP of your nfsserver
sudo -i
mount -t nfs 185.97.118.212:/srv/nfs/kubedata /mnt
mount | grep kubedata
umount /mnt
```
Everything is good, lets play with minikube:
###### minikube
Set your nfs ip inner 18-pv-nfs.yaml and run:
```bash
k create -f 18-pv-nfs.yaml
k get pv
k create -f  18-pvc-nfs.yaml
k get pvc
k get pv,pvc
```
Now create and deploy your pod:
```bash
k create -f  18-nfs-nginx.yaml
k get pods
k expose deploy nginx-deploy --type NodePort --port 80
kubectl port-forward service/nginx-deploy 8080:80
```
visit http://localhost:8080/
Change your index.html:
You can change your index.html on your nfsserver :
```bash
cd  /srv/nfs/kubedata
nano /srv/nfs/kubedata/index.html
```
change it as you want then just refresh your browser
