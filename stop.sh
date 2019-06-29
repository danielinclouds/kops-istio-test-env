#!/bin/bash
set -e

# ----------------------------------------
# Get Kops parameters
# ----------------------------------------
pushd terraform
    KOPS_STATE_STORE=s3://$(terraform output kops_state_bucket_name)
    KOPS_NAME=$(terraform output kops_state_bucket_name)
popd


# ----------------------------------------
# Delete all Helm releases
# ----------------------------------------
helm ls --all --short | xargs -L1 helm delete --purge
helm reset --force


# ----------------------------------------
# Destroy Kops cluster
# ----------------------------------------
export AWS_REGION=eu-west-2
export KOPS_NAME
export KOPS_STATE_STORE

kops delete cluster \
    --name ${KOPS_NAME} \
    --state ${KOPS_STATE_STORE} \
    --yes


# ----------------------------------------
# Destroy Terraform environment
# ----------------------------------------
pushd terraform
    terraform destroy -auto-approve
popd
