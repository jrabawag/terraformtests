#!/bin/bash

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

sudo apt-get update -y

sudo apt-get upgrade -y

sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl &&
  chmod +x ./kubectl &&
  mv ./kubectl /usr/local/bin/kubectl

sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 &&
  chmod 700 get_helm.sh &&
  ./get_helm.sh

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash