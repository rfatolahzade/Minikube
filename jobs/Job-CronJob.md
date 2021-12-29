# JOB
A Job creates one or more Pods and will continue to retry execution of the Pods until a specified number of them successfully terminate.
As pods successfully complete, the Job tracks the successful completions. When a specified number of successful completions is reached, the task (ie, Job) is complete. Deleting a Job will clean up the Pods it created. Suspending a Job will delete its active Pods until the Job is resumed again.
A simple case is to create one Job object in order to reliably run one Pod to completion.
The Job object will start a new Pod if the first Pod fails or is deleted (for example due to a node hardware failure or a node reboot).

You can also use a Job to run multiple Pods in parallel
```bash
kubectl create -f 3-Job-Echo.yaml
```
Then run : 
```bash
kubectl logs pod/helloworld-jzznp
```
You will see the Hello Kubernetes!!! as Completed job, You can see Job completed wih theese commands:
```bash
k get jobs
k describe job helloworld 
```
Till now we created a job to run this command : command: ["echo", "Hello Kubernetes!!!"]
You can do what you need.
If you delete your job , created pod will be deleted clearly
```bash
k delete job helloworld
kga
```
Another sample: run a job contains Sleep:
- completions: 2 means run twice (creating 2 pods) sequential 
- parallellism: 2 means create these two pods at same time 

```bash
kubectl create -f 4-Job-Sleep.yaml
```
After sleep 60 secs mean job done as well and state will be Completed.
Another sample: If your command fails it return Error and create pod again and again and ...
so we can set limit for our fails:
- backoffLimit: 2 means if you achive 2 times fails do not create antoher pod to do your job.
```bash
k create -f 5-Job-FailsLimit.yaml
```
Another sample: Next with activeDeadlineSeconds we set life time to our job:
- activeDeadlineSeconds: 10 
```bash
k create -f 6-Job-DeadlineSec.yaml
```
Your pod will terminate at 10 secs (age 10s) and delete
# CronJob
In my case I set to  schedule: "* * * * *" means ru this job every minutes
For more https://en.wikipedia.org/wiki/Cron and other helpful website: https://crontab.cronhub.io/
```bash
k create -f 7-Cronjob.yaml
```
###### List of Cronjobs:
```bash
k get cronjobs
k get cronjob
k get cj
```
###### Delete whole jobs:
```bash
k delete cj helloworld-cron
k delete -f 7-Cronjob.yaml
```
###### Describe cronjob to see SuccessfulCreate and SawCompletedJob :
```bash
k describe cronjob helloworld-cron
```

###### successfulJobsHistoryLimit and failedJobsHistoryLimit
minikube will be create 3 jobs  and keep them alive , every minutes that job done, itll create another job and pod and delete oldest pod and job that successed 
Because Successful Job History Limit is 3 and Failed Job History Limit is 1 (k describe cronjob helloworld-cron)
To change these valuse we can set "successfulJobsHistoryLimit: 0" it means dont keeep successful pods of your job and "failedJobsHistoryLimit: 0" dont keep failed ones
```bash
k create -f 8-Cronjob-ChangeDefaults.yaml
kga
```
So as you see after job successed pod will be delete.
######  Suspend
To set suspend (Pause) to our cronjob add "suspend: true"
```bash
k create -f 9-Cronjob-Suspend.yaml
kga
```
As you see SUSPEND value is True. OR you can change suspend of your job (Or any other options) commandly:
```bash
k patch cronjob helloworld-cron -p '{"spec":{"suspend": false}}'
```
Other samples (Notice: do not forget to put a space before your values such as :[space]0)
```bash
k patch cronjob helloworld-cron -p '{"sepc":{"successfulJobsHistoryLimit": 0}}'
k patch cronjob helloworld-cron -p '{"spec":{"schedule": "* * * * *"}}'
```
If you see "cronjob.batch/helloworld-cron patched" that means you did it sompletly well and your cronjob altered.
###### concurrencyPolicy
If you set concurrencyPolicy: Allow     #its default  or /Forbid / Replace
when jobs failed or done what happen next, keep old job, replae it, or forbid to create new one 
```bash
k create -f 10-Cronjob-concurrencyPolicy.yaml
```
When you use Replace (Active jobs is 1 New job will Replaced with new)when you got 4 pods (in this case failed pods) your Old job deleted and new job Replaced with it and old pods replaced too.
When you use Forbibd (Active jobs is 1 Dont Create new Job at all)when you got nonstop pods (in this case failed pods) your Old job Remains and new job didnt create.
When you use Allow   (Active jobs get upper)when you got 4 pods (in this case failed pods) your Old job Remains and new job will create also new pods.

######  TTLAfterFinished
if you want to delete job after finish automatically add this feature to your api and manager :
```bash
minikube ssh -n minikube
apt update
apt install nano 
nano /etc/kubernetes/manifests/kube-apiserver.yaml
```
add :
```bash
- --feature-gates= TTLAfterFinished=true
```
also add it to kube-controller-manager.yaml
```bash
nano /etc/kubernetes/manifests/kube-controller-manager.yaml
```
 Your pod/kube-apiserver-minikube and  pod/kube-controller-manager-minikube will be restart:
 ```bash
 kga -n kube-system 
 ```
(look at the age of these pods)

Then you can use ttlSecondsAfterFinished option in your job file:
```bash
k create -f 11-Job-AutoDelete.yaml
```
