#!/bin/bash

# Check that a Kubernetes service of type NodePort has a specified nodePort in order to avoid the service receiving a randomly assigned port.

echo
read -r -p "Enter the absolute path to the service's YAML file: " SERVICE_YAML
echo

SERVICE_TYPE=$(yq 'select(.kind == "Service") | .spec.type | select(. != null)' $SERVICE_YAML)

if [ $SERVICE_TYPE = "NodePort" ]; then
  echo "Service type is $SERVICE_TYPE"
else
  echo "Service type is $SERVICE_TYPE"
  echo "ERROR: Service is not type NodePort."
  exit 1
fi

NODE_PORT=$(yq 'select(.kind == "Service") | .spec.ports[].nodePort | select(. != null)' $SERVICE_YAML)

if [[ -z $NODE_PORT ]]; then
  echo "ERROR: nodePort is unset!"
  exit 1
else
  echo "SUCCESS: nodePort is set to: $NODE_PORT"
  exit 0
fi
