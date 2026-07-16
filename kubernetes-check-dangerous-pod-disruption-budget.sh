#!/bin/bash

# Check for dangerous pod disruption budget

read -r -p "Enter the path to the deployment.yaml file: " DEPLOYMENT_YAML
echo

REPLICAS=$(yq '.spec.replicas | select(. != null)' $DEPLOYMENT_YAML)
MIN_AVAIL=$(yq '.spec.minAvailable | select(. != null)' $DEPLOYMENT_YAML)

echo
echo "replicas = $REPLICAS"
echo "minAvailable = $MIN_AVAIL"
echo

if [ "$MIN_AVAIL" -ge "$REPLICAS" ]; then
  echo "WARNING: PDB minAvailable >= replicas"
  echo "This blocks all evictions!"
  exit 1
else
  echo "No dangerous pod disruption budget detected."
fi
