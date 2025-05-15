#!/bin/bash

NAMESPACE="argocd"

# Get all resource names in the namespace that start with "addons-"
RESOURCES=$(kubectl get applicationset -n $NAMESPACE -o name | grep "addons-")

if [ -z "$RESOURCES" ]; then
  echo "No matching resources found in namespace $NAMESPACE."
  exit 0
fi

# Delete all matching resources
for RESOURCE in $RESOURCES; do
  echo "Deleting $RESOURCE..."
  kubectl delete $RESOURCE -n $NAMESPACE
done

echo "All addons in namespace $NAMESPACE deleted successfully."


