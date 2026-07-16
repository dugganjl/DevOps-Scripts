#!/bin/bash

# Check for dangerous rollout strategy

read -r -p "Enter the path to the deployment.yaml file: " DEPLOYMENT_YAML
echo

MAX_UNAVAIL=$(yq '.spec.strategy.rollingUpdate.maxUnavailable | select(. != null)' $DEPLOYMENT_YAML)

echo "rollingUpdate.maxUnavailable = $MAX_UNAVAIL"
echo

if [[ "$MAX_UNAVAIL" == "100%" ]] || [[ "$MAX_UNAVAIL" -ge $(yq '.spec.replicas | select(. != null)' $DEPLOYMENT_YAML) ]]; then
  echo "WARNING: Dangerous maxUnavailable detected!"
  exit 1
else
  echo "No dangerous rollout strategy detected."
fi
