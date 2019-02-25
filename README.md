# Control Pod Traffic in AKS with Network Policy

This repo has a couple of scripts that show how to use Network Policy with AKS based on the documentation [here](https://docs.microsoft.com/en-us/azure/aks/use-network-policies).

To use this first run the script [setup-demo.sh](../blob/master/setup-demo.sh)
 , this requires the environment variables ARM_CLIENT_ID and ARM_CLIENT_SECRET to be populated with details of a service principal taht can be used with AKS, it will create a new Resource Group, Virtual Network and AKS Cluster.

The demo can then be run by executing [demo.sh](../blob/master/demo.sh) this will step through the creation and configuration of network policy on the AKS cluster and then finally clean up.