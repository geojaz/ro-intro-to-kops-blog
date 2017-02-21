# RO Intro to Kubernetes with kops

At RO, we always talk about "RO-style" configurations, which I think is a really important thing to understand. We've done the lengthy research to understand best practices and what "works"- because of this we create infrastructure in a repeatable and opinionated way. So this is RO-style or RO-flavored kubernetes on AWS with kops.

There are 2 steps to creating kubernetes clusters with kops in the ReactiveOps style.

1. Configure the VPC (we use Terraform, but there are other great options to do this as well)
2. Let kops do everything else
   - Use kops to layer in additional networking resources in the same VPC
   - Use kops to launch the instances that make up your cluster, let it come up, verify it works!

Step 1: 
VPC Configuration-
We use Terraform from Hashicorp for creating the AWS VPC and laying down the basic networking elements. (maybe a future blog post about this in depth? When we open source it!). I won't bore you too much with the details but the basic idea is that we use terraform to create a VPC with a number of subnets for a variety of uses. There are 4 sets that we use for different things. The important things to note here are:

  - The VPC we create is intended to have space for both kubernetes and other cloud based resources
  - The VPC can hold multiple distinct kubernetes clusters
  - We have a concept of public and private subnets that I'll describe in more depth later, but for each availability zone, we direct Terraform to create a single NAT Gateway through which private networks may route to the outside internet

Step 2:
kops-
Now that we have our VPC and our basic networking resources available, we can get into the kubernetes specific configuration. As discussed in part 1 of this series, kops is the best tool for the job when it comes to end to end provisioning for kubernetes.

These are the four commands to go from our Terraform VPC setup to a working cluster:


```
kops create -f cluster_spec.yml
kops create secret --name $CLUSTER_NAME sshpublickey admin -i $SSH_KEY_PATH
kops update cluster $CLUSTER_NAME
# Sanity check the output. Make sure that kops is only making the changes you expect
kops update cluster $CLUSTER_NAME --yes
```

There's a ton of magic going on in those 4 commands behind the scenes. kops has the concept of a cluster specification, from which an entire kubernetes cluster and all the networking and security permissions to support it can be created. It is your "infrastructure in code", in kops. There are a number of different ways in which to interact with kops, but I chose to spotlight this mode (`kops create -f cluster_spec.yml`) where the entire cluster is defined in code because it's relatively unknown at this point. It's also really useful for professionals that know how they want the spec to look and don't need to use the interactive prompts. This is the way that I would recommend scripting your kubernetes installations for maximum repeatability.

We configure our cluster spec to launch kubernetes in a private topology which means that the masters and the nodes are in private subnets. kops creates "utility" subnets 1:1 with the private subnets. The utility subnets host the ELB for the kubernetes API server, ELBs for any external services launched in kubernetes, and perhaps a bastion host (although we prefer to use a VPN host instead).

For a "ReactiveOps"-style kubernetes cluster created with kops, we let kops create it's own subnets. We prefer to let kops completely manage it's own networking configuration inside of our existing VPC- except for NAT gateways. In the same way that our original VPC code shares one NAT Gateway per AZ, we will also use the same NAT Gateway for our kubernetes private networks. This is a desirable thing to do because NAT Gateways are pretty expensive, and they are scalable and redundant by definition, so we don't need more than one. This result is even better when we start to layer more kubernetes clusters in the same VPC- we just let kops add additional subnets and then hook into the existing NAT Gateways. The lines in which we tell kops about our existing NAT Gateways are 36, 41 and 46 of the `cluster_spec-example.yml`- the identifier `egress:` is the correct keyword.

If all has gone well with the `kops update cluster` above, in a few minutes you will be able to run `kops validate cluster $CLUSTER_NAME` and it will show you something that looks like this that will let you know that kops's job is done and it's time to start using your cluster:

```
Validating cluster blog.kube.example.com

INSTANCE GROUPS
NAME      ROLE  MACHINETYPE MIN MAX SUBNETS
master-us-east-2a Master  t2.medium 1 1 us-east-2a
nodes     Node  t2.micro  3 3 us-east-2a,us-east-2b,us-east-2c

NODE STATUS
NAME            ROLE  READY
ip-172-20-16-43.us-east-2.compute.internal  node  True
ip-172-20-16-75.us-east-2.compute.internal  master  True
ip-172-20-17-111.us-east-2.compute.internal node  True
ip-172-20-18-239.us-east-2.compute.internal node  True

Your cluster blog.kube.example.com is ready
```

# Takeaways- Why we work this way
This seems like a pretty complicated way to configure your kubernetes installation. So Why? 
- We use the best tools for the job at each point of the process, precision of tool choice
- Separation of concerns, kubernetes is handled by kops, clear responsiblity for each toolpho
- Best of breed updates and cluster management
