# AWS Terraform configuration

## Description
The goal os this repository is to be able to deploy an application to Kubernetes using AWS EKS and Fargate profile.

Fargate is a servless compute engine that leverages the hability to deploy apps to a given namespace or selector without having to provision and manage servers. For this solution every deployment under the `test` namespace will be run on Fargate. Everything else deployed to a different namespace will run on a EC2 node group across multiple availability zones.

As described above, we're also going to make use of a EC2 Node Group. This node group will be responsible to run additional kubernetes components such as `aws-loadbalancer-controller`, `coredns`, etc. 

For the sake of simplicity I'm going to deploy a simple app known as [2048-game](https://play2048.co/). 
I won't be configuring Horizontal Pod AutoScale for the POD's to keep things simple eventhought that's pretty straightforward.

Network components such as ALB, NAT, IG, etc will be deployed across multiple AZ's to avoid a single point of failure in case of one the AZ is down.

## Prerequisite

- A bucket on S3 must be created before hand, so the Terraform state changes can be stored on it. For this configuration I have already defined a bucket `aws-demo-infrastructure`

- [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)

- [Terraform](#terraform)

## Components
 - VPC
    - private subnet
    - public subnet
    - NAT gateway for private subnets
    - Internet gateway for public subnets
    - Elastic IP's
    - Security groups
    - Route Table

 - EKS    
    - EKS Cluster
    - Fargate profile
    - NFS volume
    - CloudWatch

 - Load balancer distributed across multiple AZ's (created via Ingress)

 - CloudWatch logs for the EKS cluster

 - Kubernetes   
    - aws-load-balancer-controller
    - PVC
    - namespaces

- IAM roles such as EKS load balancer controller, etc

## Authentication - AWS Credentials

- Create the following file `~/.aws/credentials`

- Add the following content
    ```
    [paulo-aws-config]
    region = eu-west-1
    aws_access_key_id = <KEY_ID>
    aws_secret_access_key = <ACCESS_KEY>
    output = json
    ```

- Install [direnv](https://direnv.net/docs/installation.html)

- Create a .envrc file in the directory where you want this profile to be actived and add the following content: `export AWS_PROFILE=paulo-aws-config`

- Run: `direnv allow`

## Terraform

This terraform configuration uses terraform version 1.0.0

### Install the correct terraform version
- Install tfenv to handle terraform versions

    ```
    brew install tfenv
    tfenv install 1.0.0
    tfenv use 1.0.0
    ```

## Setting up a workspace
- Setup a new or use an existing `terraform workspace` for the environment where the changes are going to be applied. This will make sure the changes relevant to a given environment are stored individually in S3.

```
terraform workspace new test
```

- Initiate the terraform and store the state on S3 bucket: `terraform init`

- Plan the changes according to the environment ` terraform plan -var-file=environment/test.tfvars -out=test-environment.tfplan`

- Apply the changes `terraform apply test-environment.tfplan`

### Accessing the EKS cluster
- Configure the [kubeconfig file](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html)

### App Deployment 

Once the infrastructure components have been deployed it's time to deploy the app. 
I have created a minimal `yaml` file to be able to deploy an app to the newly created EKS cluster.

- cd to /kubernetes
- `kubectl apply -f app-game-deployment.yaml`
- In order to access the app, go to load balancer and copy it's dns name
