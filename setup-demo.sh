#!/bin/bash

rg_name=aks-network-policy-demo
location=westeurope
vnet_name=demo-vnet
subnet_name=demo-subnet
cluster_name=policy-test

echo "Registering for Feature"

az feature register --name EnableNetworkPolicy --namespace Microsoft.ContainerService

echo "Waiting for Feature Registration"

i=0
while [ $i -lt 10 ]
do
    sleep 30
    feature_state=$(az feature list -o tsv  --query "[?contains(name, 'Microsoft.ContainerService/EnableNetworkPolicy')].properties.state")
    echo "Feature State:" "${feature_state}"
    if [ "${feature_state}" == "Registered" ]
	then
        az provider register --namespace Microsoft.ContainerService
		break
	fi
    i=$(( $i + 1 ))
    echo "Waiting for Feature Registration"
done

if [ "${feature_state}" != "Registered" ]
then
		echo "Waitng for Feature Regstration"
        exit 1
fi

echo "Creating Resource Group"
az group create --name  "${rg_name}" --location "${location}"

echo "Creating Virtual Network"
az network vnet create --resource-group "${rg_name}" --name "${vnet_name}" --address-prefixes 10.0.0.0/8 --subnet-name "${subnet_name}" --subnet-prefix 10.240.0.0/16

echo "Creating Subnet"
subnet_id=$(az network vnet subnet show --resource-group "${rg_name}" --vnet-name "${vnet_name}" --name "${subnet_name}" --query id -o tsv)

echo "Creating AKS Cluster"
az aks create \
    --resource-group "${rg_name}"  \
    --name "${cluster_name}" \
    --node-count 1 \
    --kubernetes-version 1.12.4 \
    --generate-ssh-keys \
    --network-plugin azure \
    --service-cidr 10.0.0.0/16 \
    --dns-service-ip 10.0.0.10 \
    --docker-bridge-address 172.17.0.1/16 \
    --vnet-subnet-id "${subnet_id}" \
    --service-principal "${ARM_CLIENT_ID}" \
    --client-secret "${ARM_CLIENT_SECRET}" \
    --network-policy calico