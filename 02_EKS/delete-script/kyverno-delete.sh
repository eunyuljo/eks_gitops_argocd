#!/bin/bash
set -e

NAMESPACE="kyverno"

echo "🔍 Checking if Kyverno Webhooks exist..."

# Check for presence of Kyverno validating webhook configurations
if kubectl get validatingwebhookconfiguration | grep -q kyverno; then
  echo "⚠️ Kyverno webhooks found. Proceeding with deletion..."

  # Delete validating webhook configurations
  kubectl delete validatingwebhookconfiguration \
    kyverno-cleanup-validating-webhook-cfg \
    kyverno-exception-validating-webhook-cfg \
    kyverno-policy-validating-webhook-cfg \
    kyverno-resource-validating-webhook-cfg --ignore-not-found

  # Delete mutating webhook configurations
  kubectl delete mutatingwebhookconfiguration \
    kyverno-policy-mutating-webhook-cfg \
    kyverno-resource-mutating-webhook-cfg --ignore-not-found
else
  echo "✅ No Kyverno webhook configurations found."
fi

echo "🧹 Deleting Kyverno core resources..."

kubectl delete deployment kyverno -n $NAMESPACE --ignore-not-found
kubectl delete service kyverno-svc -n $NAMESPACE --ignore-not-found
kubectl delete serviceaccount kyverno-service-account -n $NAMESPACE --ignore-not-found
kubectl delete clusterrole kyverno:admin --ignore-not-found
kubectl delete clusterrolebinding kyverno:admin --ignore-not-found

echo "🔍 Checking if namespace '$NAMESPACE' exists..."

if kubectl get namespace $NAMESPACE &> /dev/null; then
  echo "⚠️ Force removing finalizers from namespace '$NAMESPACE'..."

  # Get the namespace resource and strip finalizers
  kubectl get namespace $NAMESPACE -o json | jq 'del(.spec.finalizers)' > temp-ns-clean.json

  # Apply the cleaned version to finalize deletion
  kubectl replace --raw "/api/v1/namespaces/$NAMESPACE/finalize" -f ./temp-ns-clean.json

  kubectl delete ns $NAMESPACE
  # Clean up temp file
  rm temp-ns-clean.json

  echo "✅ Namespace '$NAMESPACE' finalized and deleted."
else
  echo "✅ Namespace '$NAMESPACE' not found. Nothing to delete."
fi
