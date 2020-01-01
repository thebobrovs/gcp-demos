#!/usr/bin/env bash

########################
# include the magic
########################
. ../demo-magic.sh


########################
# Configure the options
########################

#
# speed at which to simulate typing. bigger num = faster
#
# TYPE_SPEED=20

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
#DEMO_PROMPT="${GREEN}➜ ${CYAN}\W "

# hide the evidence
clear


# put your demo awesomeness here
pe "export CLUSTER_NAME=central"
pe "export CLUSTER_ZONE=us-central1-b"
pe "export CLUSTER_VERSION=1.13"


pe "gcloud beta container clusters create $CLUSTER_NAME \
    --zone $CLUSTER_ZONE --num-nodes 4 \
    --machine-type "n1-standard-2" --image-type "COS" \
    --cluster-version=$CLUSTER_VERSION \
    --enable-stackdriver-kubernetes \
    --scopes "gke-default","compute-rw" \
    --enable-autoscaling --min-nodes 4 --max-nodes 8 \
    --enable-basic-auth \
    --addons=Istio --istio-config=auth=MTLS_STRICT"


pe "export GCLOUD_PROJECT=$(gcloud config get-value project)"
pe "gcloud container clusters get-credentials $CLUSTER_NAME \
    --zone $CLUSTER_ZONE --project $GCLOUD_PROJECT"

pe "kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user=$(gcloud config get-value core/account)"

pe "gcloud container clusters list"

pe "kubectl get service -n istio-system"

pe "kubectl get pods -n istio-system"

pe "export LAB_DIR=$HOME/bookinfo-lab"
pe "export ISTIO_VERSION=1.1.11"

pe "mkdir $LAB_DIR"
pe "cd $LAB_DIR"
pe "curl -L https://git.io/getLatestIstio | ISTIO_VERSION=$ISTIO_VERSION sh -"

pe "cd ./istio-*"
pe "export PATH=$PWD/bin:$PATH"

pe "istioctl version"

pe "cat samples/bookinfo/platform/kube/bookinfo.yaml"

pe "istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml"

pe "kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)"

pe "cat samples/bookinfo/networking/bookinfo-gateway.yaml"

pe "kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml"

pe "kubectl get services"

pe "kubectl get pods"

pe "kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') \
    -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>""

pe "kubectl get gateway"

pe "export GATEWAY_URL=[EXTERNAL-IP]"

pe "curl -I http://${GATEWAY_URL}/productpage"

# show a prompt so as not to reveal our true nature after
# the demo has concluded
p ""
