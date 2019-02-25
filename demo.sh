#!/bin/bash

rg_name=aks-network-policy-demo
cluster_name=policy-test

echo "Getting Kube Config"
az aks get-credentials --resource-group "${rg_name}" --name "${cluster_name}" --overwrite-existing --admin

echo "Creating Namspace and label"

echo "kubectl create namespace development"
kubectl create namespace development

echo "kubectl label namespace/development purpose=development"
kubectl label namespace/development purpose=development

read -n 1 -s -r -p "Press any key to deploy nginx pod"
clear

echo "Deploying backend nginx pod"
echo "kubectl run backend --image=nginx --labels app=webapp,role=backend --namespace development --expose --port 80 --generator=run-pod/v1"

kubectl run backend --image=nginx --labels app=webapp,role=backend --namespace development --expose --port 80 --generator=run-pod/v1

read -n 1 -s -r -p "Press any key to deploy test pod"
clear


echo "Deploying test pod to test connectivity"
echo "kubectl run --rm -it --image=alpine network-policy --namespace development --generator=run-pod/v1"
echo "command:"
echo "wget -qO- http://backend"

kubectl run --rm -it --image=alpine network-policy-1 --namespace development --generator=run-pod/v1

clear

echo "Applying network policy"
cat ./policy.yaml
printf "\\n"

kubectl apply -f ./policy.yaml

read -n 1 -s -r -p "Press any key to deploy pod to test policy"
clear

echo "Deploying test pod to test the policy"
echo "kubectl run --rm -it --image=alpine network-policy --namespace development --generator=run-pod/v1"
echo "command:"
echo "wget -qO- --timeout=2 http://backend"

kubectl run --rm -it --image=alpine network-policy-2 --namespace development --generator=run-pod/v1

clear

echo "Applying updated network policy to allow pods with pod labels"
cat ./updated-policy.yaml
printf "\\n"

kubectl apply -f ./updated-policy.yaml

read -n 1 -s -r -p "Press any key to deploy pod with correct labels to test policy"
clear


echo "Deploying test pod with correct labels"
echo "kubectl run --rm -it frontend --image=alpine --labels app=webapp,role=frontend --namespace development --generator=run-pod/v1"
echo "command:"
echo "wget -qO- http://backend"

kubectl run --rm -it frontend --image=alpine --labels app=webapp,role=frontend --namespace development --generator=run-pod/v1

clear

echo "Deploying test pod to without the correct labels"
echo "kubectl run --rm -it --image=alpine network-policy --namespace development --generator=run-pod/v1"
echo "command:"
echo "wget -qO- --timeout=2 http://backend"

kubectl run --rm -it --image=alpine network-policy-3 --namespace development --generator=run-pod/v1

echo "Cleaning up"

kubectl delete namespace development

read -n 1 -s -r -p "Press any key to delete demo Resource Group"
clear
az group delete -n "${rg_name}"