#!/bin/bash

# Validate canary deployment and then apply scaling of replicas

read -r -p "Enter namespace name: " NAMESPACE
read -r -p "Enter stable deployment name: " STABLE_DEPLOYMENT
read -r -p "Enter canary deployment name: " CANARY_DEPLOYMENT

echo
CURRENT_STABLE_REPLICAS=$(kubectl get deployment $STABLE_DEPLOYMENT -o yaml | yq '.status.availableReplicas | select(. != null)')
CURRENT_CANARY_REPLICAS=$(kubectl get deployment $CANARY_DEPLOYMENT -o yaml | yq '.status.availableReplicas | select(. != null)')
echo "Current stable replicas = $CURRENT_STABLE_REPLICAS"
echo "Current canary replicas = $CURRENT_CANARY_REPLICAS"
echo

read -r -p "Enter desired number of stable replicas: " DESIRED_STABLE_REPLICAS
read -r -p "Enter desired number of canary replicas: " DESIRED_CANARY_REPLICAS
read -r -p "Enter target percentage (%) of canary to stable replicas: " TARGET_PCT

ACTUAL_PCT=$((DESIRED_CANARY_REPLICAS * 100 / (DESIRED_STABLE_REPLICAS + DESIRED_CANARY_REPLICAS)))

if [ $ACTUAL_PCT -gt $((TARGET_PCT + 5)) ]; then
  echo
  echo "WARNING: Canary will be $ACTUAL_PCT%, target is $TARGET_PCT%"
  exit 1
fi

read -r -p "Target canary to stable percentage is within specified limits - enter 'yes' to proceed with scaling of deployments: " SCALE_RESPONSE
echo

if [ $SCALE_RESPONSE = 'yes' ]; then
  kubectl scale deployment/$STABLE_DEPLOYMENT --replicas=$DESIRED_STABLE_REPLICAS --namespace=$NAMESPACE
  kubectl scale deployment/$CANARY_DEPLOYMENT --replicas=$DESIRED_CANARY_REPLICAS --namespace=$NAMESPACE
  echo "Scaling deployments, waiting 10 seconds before displaying updated replica counts..."
  sleep 10s
  CURRENT_STABLE_REPLICAS=$(kubectl get deployment $STABLE_DEPLOYMENT -o yaml | yq '.status.availableReplicas | select(. != null)')
  CURRENT_CANARY_REPLICAS=$(kubectl get deployment $CANARY_DEPLOYMENT -o yaml | yq '.status.availableReplicas | select(. != null)')
    
  echo
  echo "Current stable replicas = $CURRENT_STABLE_REPLICAS"
  echo "Current canary replicas = $CURRENT_CANARY_REPLICAS"
  echo
  echo "Deployments scaled."
else
  echo "No action taken."
fi
