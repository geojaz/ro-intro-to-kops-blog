#!/usr/bin/env bash

export CLUSTER_NAME=blog-demo.eh-dev.dev.hillghost.com
export ZONES="us-east-2a,us-east-2b,us-east-2c"
export VPC_ID="vpc-461fb32f"

# the public key to be installed for the admin user
# this should be set to be unique per cluster
export SSH_KEY_PATH="private/blog-demo-working.pub"

export NODE_COUNT=3
export MASTER_ZONES="us-east-2a"
export DNS_ZONE="eh-dev.dev.hillghost.com"
export MASTER_SIZE="t2.medium"
export NODE_SIZE="t2.micro"
export V_LOG_LEVEL=10
export NETWORK_CIDR="172.20.0.0/16"
