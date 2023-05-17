#!/bin/bash

export TF_VAR_openai_api_key=$OPENAI_API_KEY
export TF_VAR_client_id=$ARM_CLIENT_ID
export TF_VAR_client_secret=$ARM_CLIENT_SECRET
export TF_VAR_tenant_id=$ARM_TENANT_ID
export TF_VAR_subscription_id=$ARM_SUBSCRIPTION_ID
cd infra/terraform
terraform init -upgrade
terraform validate

echo "$1"

if [ "$#" -gt 0 ]; then
    if [[ "$1" == "destroy" ]]; then
        terraform destroy -auto-approve
    elif [[ "$1" =~ ".*-replace.*" ]]; then
        terraform apply -auto-approve "$1"
    else
        echo "Invalid argument: $1"
        echo "Usage: $0 [destroy|<resource-to-replace>]"
        exit 1
    fi
else
    terraform apply -auto-approve
fi