#!/usr/bin/env bash

kops create cluster \
  --cloud aws \
  --topology private \
  --networking weave \
  --state $KOPS_STATE_STORE \
  --node-count $NODE_COUNT \
  --zones $ZONES \
  --master-zones $MASTER_ZONES \
  --dns-zone $DNS_ZONE \
  --node-size $NODE_SIZE \
  --master-size $MASTER_SIZE \
  -v $V_LOG_LEVEL \
  --ssh-public-key $SSH_KEY_PATH \
  --vpc $VPC_ID \
  --network-cidr $NETWORK_CIDR \
  --name $CLUSTER_NAME \
  --kubernetes-version=1.5.3
