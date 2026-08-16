# DevOps Test Task

This project is my solution for the DevOps / Platform Engineer test task.

I used Terraform to create the AWS infrastructure and EKS cluster.  
The application is a simple nginx app deployed with Helm.

I also added monitoring, logging, alerts, Slack notifications and load testing.

## What I used

- Terraform
- AWS VPC
- Amazon EKS
- 2 Spot EC2 nodes (`t3.medium`)
- Helm
- nginx
- AWS Load Balancer Controller
- Prometheus
- Grafana
- Loki
- Grafana Alloy
- Route 53 Health Check
- Slack
- k6

## Architecture

The EKS worker nodes are running in private subnets.

The application has 2 nginx pods and is exposed through an AWS Application Load Balancer.

Request flow:

`User, ALB, Ingress, Service, nginx pods`

For monitoring I use Prometheus and Grafana.

For logs I use Alloy and Loki.

Grafana is also used for CPU and memory alerts, and the alerts are sent to Slack.

## Terraform

Terraform creates the main AWS resources:

- VPC
- public and private subnets
- NAT Gateway
- Internet Gateway
- EKS cluster
- EKS Spot node group
- IAM resources for the AWS Load Balancer Controller
- Route 53 health check

Terraform also installs the main Kubernetes components with `helm_release`.

The default AWS region is:

eu-central-1


## EKS

The EKS cluster has 2 Spot worker nodes.

Instance type: t3.medium
Capacity type: SPOT
Desired nodes: 2


I used `t3.medium` because the cluster also runs Prometheus, Grafana, Loki and Alloy, so smaller instances may not have enough memory.

The worker nodes are in private subnets.

## Application

The demo application is nginx.

It is deployed from a local Helm chart with Terraform.

Main application settings:

Replicas: 2
Service: ClusterIP
CPU request: 50m
CPU limit: 250m
Memory request: 64Mi
Memory limit: 128Mi

The AWS Load Balancer Controller watches the Kubernetes Ingress and creates the public ALB.

I used IRSA for the controller, so I don't need to store AWS access keys inside Kubernetes.

To get the application URL:


cd terraform
terraform output -raw application_url

## Monitoring and Logs

For monitoring I installed `kube-prometheus-stack`.

It gives me Prometheus, Grafana and the Kubernetes metrics that I need.

My Grafana dashboard shows:

- application CPU
- application memory
- available replicas
- pod restarts
- nginx logs

For logs I use:

`nginx , Alloy , Loki , Grafana`

Alloy collects logs from the `demo` namespace and sends them to Loki.

To access Grafana:

kubectl port-forward   -n monitoring   svc/kube-prometheus-stack-grafana   3000:80

Then open:

http://localhost:3000

## Alerts

I added 2 Grafana alerts:

- High CPU
- High Memory

The alerts are sent to Slack.

The Slack webhook is stored in a Kubernetes Secret and is not saved in the repository.

Example:


kubectl create secret generic grafana-slack-webhook   -n monitoring   --from-literal=SLACK_WEBHOOK_URL='YOUR_WEBHOOK_URL'


I tested the High CPU alert and the Slack notification was received successfully.

## External Health Check

I also created a Route 53 HTTP health check for the public ALB endpoint.

Settings:

Protocol: HTTP
Port: 80
Path: /
Interval: 30 seconds
Failure threshold: 3

## Load Test

I used k6 for load testing.

### First test

Load was increased from 10 to 200 virtual users.

Results:

Total requests: 53,388
Average RPS: 177.94
HTTP errors: 0.00%
Average response time: 171.76 ms
p95: 448.40 ms
Checks passed: 100%

The test passed my configured threshold:

p95 < 500 ms

### Stress test

After that I tested:

200 > 400 > 600 > 800 > 1000 VUs

The test was stable until around 600 VUs.

At 800 and 1000 VUs the p95 latency became higher than 500 ms.

So the first clear degradation point was around **800 VUs**.

There were still no HTTP errors, so the main problem at this load was response time, not application availability.

## How to deploy

Requirements:

- Terraform
- AWS CLI
- kubectl
- Helm
- AWS credentials

Run:

cd terraform

terraform init
terraform validate
terraform plan
terraform apply

Then configure kubectl:

aws eks update-kubeconfig   --region eu-central-1   --name devops-platform-test

Check the cluster:

kubectl get nodes
kubectl get pods -A

## Security

Some security decisions I used in this project:

- EKS worker nodes are in private subnets
- AWS Load Balancer Controller uses IRSA
- Slack webhook is not committed to Git
- Terraform state is not committed to Git
- `terraform.tfvars` is not committed to Git
- nginx Service is `ClusterIP`

Files like these should not be pushed:

terraform.tfstate
terraform.tfstate.backup
terraform.tfvars
.terraform/
.env
AWS credentials
Slack webhook


## Limitations

This is a test project, so I kept some parts simple.

Current limitations:

- no custom domain
- no HTTPS
- one NAT Gateway
- local Terraform state
- no HPA
- monitoring storage is not persistent
- worker nodes are Spot only
- EKS public API endpoint is enabled

For production I would add a Route 53 domain with ACM HTTPS, remote Terraform state, autoscaling, persistent monitoring storage and a mix of Spot and On-Demand nodes.

I also noticed that ALB deletion can take some time during `terraform destroy`, because the ALB is created by the AWS Load Balancer Controller and AWS removes its related resources asynchronously.

## Cleanup

To remove the infrastructure:


cd terraform
terraform destroy


If VPC deletion is blocked, I check if the ALB, network interfaces or security groups still exist and wait for AWS cleanup before running destroy again.
