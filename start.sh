#!/bin/bash
set -e

# ----------------------------------------
# Create Terraform environment
# ----------------------------------------
pushd terraform
    terraform init
    terraform apply -auto-approve
    KOPS_STATE_STORE=s3://$(terraform output kops_state_bucket_name)
    KOPS_NAME=$(terraform output kops_state_bucket_name)
popd


# ----------------------------------------
# Create Kops cluster
# ----------------------------------------
export AWS_REGION=eu-west-2
export KOPS_NAME
export KOPS_STATE_STORE


kops create cluster \
--cloud aws \
--name ${KOPS_NAME} \
--zones "${AWS_REGION}a" \
--networking calico \
--master-size t2.medium \
--node-size t2.xlarge \
--node-count 3 \
--ssh-public-key ./terraform/kops.pem.pub 

kops update cluster --name ${KOPS_NAME} --yes
sleep 500 # Waiting for LB to become ready


# ----------------------------------------
# Install Helm
# ----------------------------------------
kubectl create sa tiller -n kube-system
kubectl create clusterrolebinding tiller-admin-binding \
    --clusterrole=cluster-admin \
    --serviceaccount=kube-system:tiller

helm init --service-account tiller --wait


# ----------------------------------------
# Install Istio
# ----------------------------------------
ISTIO_VERSION=1.2.2

helm repo add istio.io https://storage.googleapis.com/istio-release/releases/${ISTIO_VERSION}/charts/
helm repo update

helm upgrade istio-init istio.io/istio-init \
    --install \
    --namespace=istio-system \
    --wait

sleep 20 # Waiting for CRDs to become ready
helm upgrade istio istio.io/istio \
    --install \
    --namespace istio-system \
    --wait

kubectl label namespace default istio-injection=enabled --overwrite

