#!/bin/bash

pushd terraform
    KOPS_STATE_STORE=s3://$(terraform output kops_state_bucket_name)
    KOPS_NAME=$(terraform output kops_state_bucket_name)
    export KOPS_STATE_STORE
    export KOPS_NAME
popd