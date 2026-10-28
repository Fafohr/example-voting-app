# Example Voting App

A simple distributed application running across multiple Docker containers.

## Getting started

Download [Docker Desktop](https://www.docker.com/products/docker-desktop) for Mac or Windows. [Docker Compose](https://docs.docker.com/compose) will be automatically installed. On Linux, make sure you have the latest version of [Compose](https://docs.docker.com/compose/install/).

This solution uses Python, Node.js, .NET, with Redis for messaging and Postgres for storage.

Run in this directory to build and run the app:

```shell
docker compose up
```

The `vote` app will be running at [http://localhost:8080](http://localhost:8080), and the `results` will be at [http://localhost:8081](http://localhost:8081).

Alternately, if you want to run it on a [Docker Swarm](https://docs.docker.com/engine/swarm/), first make sure you have a swarm. If you don't, run:

```shell
docker swarm init
```

Once you have your swarm, in this directory run:

```shell
docker stack deploy --compose-file docker-stack.yml vote
```

## Run the app in Kubernetes

The folder k8s-specifications contains the YAML specifications of the Voting App's services.

The GitHub Actions workflows publish the vote, result, and worker images to this fork's GitHub Container Registry (GHCR) when changes are pushed to the default branch. After the first successful workflow run, set each package's visibility to **Public** in GitHub Packages so the cluster can pull it without an image-pull secret.

Run the following command to create or update the deployments and services in your current namespace (`default` if you haven't changed it):

```shell
kubectl apply -f k8s-specifications/
```

Wait for the workloads to start:

```shell
kubectl rollout status deployment/vote
kubectl rollout status deployment/result
kubectl rollout status deployment/worker
kubectl rollout status deployment/redis
kubectl rollout status deployment/db
```

For local access without changing cluster firewall rules, forward the service ports:

```shell
kubectl port-forward service/vote 8080:8080
kubectl port-forward service/result 8081:8081
```

Run each command in a separate terminal, then open [http://localhost:8080](http://localhost:8080) and [http://localhost:8081](http://localhost:8081). The services are also configured as NodePorts 31000 and 31001, but external access depends on the cluster network and firewall rules.

The Kubernetes manifests use the sample PostgreSQL password `postgres` to match this example app. Do not use that default for a public or production cluster; replace it with a Kubernetes Secret and configure both applications to read the same secret before exposing the app.

To remove them, run:

```shell
kubectl delete -f k8s-specifications/
```

## Provision an AWS EKS cluster with Terraform

This capstone step creates an EKS cluster in the AWS account's default VPC. It uses one `t3.medium` managed node to start and allows scaling to two nodes. EKS and its EC2 nodes are billable resources; review the plan before applying and destroy the cluster when you finish.

Prerequisites: Terraform 1.5.7 or later, AWS CLI credentials with permission to manage EKS and IAM resources, and `kubectl`.

From the repository root:

```shell
cd infra/terraform
cp -n terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` only if it does not already contain your values: choose an AWS region with a default VPC and replace the example CIDR with your current public IPv4 address followed by `/32`. The Kubernetes API endpoint is public but restricted to this CIDR; do not use `0.0.0.0/0`. `cp -n` avoids overwriting an existing local variables file.

Check that the AWS CLI is using the intended account, then initialize and review the plan:

```shell
aws sts get-caller-identity
terraform init
terraform validate
terraform plan
```

Only after reviewing the plan and confirming the account, region, and expected charges, create the resources:

```shell
terraform apply
```

Configure `kubectl` using the output command:

```shell
terraform output -raw kubectl_configure_command
```

Copy and run the printed command, then verify access with `kubectl get nodes`. When finished with this capstone environment, remove the billable resources:

```shell
terraform destroy
```

Terraform state and `terraform.tfvars` contain account-specific information and are ignored by Git. Do not commit them or AWS credentials. The EKS module and Kubernetes version are pinned in the Terraform configuration; check [AWS EKS Kubernetes version support](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html) before changing the version.

## Architecture

![Architecture diagram](architecture.excalidraw.png)

* A front-end web app in [Python](/vote) which lets you vote between two options
* A [Redis](https://hub.docker.com/_/redis/) which collects new votes
* A [.NET](/worker/) worker which consumes votes and stores them in…
* A [Postgres](https://hub.docker.com/_/postgres/) database backed by a Docker volume
* A [Node.js](/result) web app which shows the results of the voting in real time

## Notes

The voting application only accepts one vote per client browser. It does not register additional votes if a vote has already been submitted from a client.

This isn't an example of a properly architected perfectly designed distributed app... it's just a simple
example of the various types of pieces and languages you might see (queues, persistent data, etc), and how to
deal with them in Docker at a basic level.
