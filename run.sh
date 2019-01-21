#!/bin/bash

set -e

GCLOUD_VERSION="230.0.0"
TERRAFORM_VERSION="0.11.11"
MINIKUBE_VERSION="0.33.1"
BINS_DIR="$HOME/bins"

mkdir -p $HOME/bins
mkdir -p $HOME/git/go/

#################
# .bash_profile #
#################
cat <<EOF > $HOME/.bash_profile
############
# env vars #
############
export PATH="\$PATH:$BINS_DIR:/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"
export GOPATH=\$HOME/git/go

##########
# gcloud #
##########
if [ -f "\$HOME/bins/google-cloud-sdk/path.zsh.inc" ]; then . "\$HOME/bins/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "\$HOME/bins/google-cloud-sdk/completion.zsh.inc" ]; then . "\$HOME/bins/google-cloud-sdk/completion.zsh.inc"; fi

###########
# kubectx #
###########
source \$ZSH/plugins/kube-ps1/kube-ps1.plugin.zsh 
PROMPT='\$(kube_ps1)'\$PROMPT

###########
# aliases #
###########
alias kctx=kctx
kctx() {
	kubectx \$1
}

EOF

##############
# .tmux.conf #
##############
cat <<EOF > $HOME/.tmux.conf
set -g prefix C-a
unbind C-b
bind C-a send-prefix
EOF

########
# brew #
########
printf 'y\ny\n' | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
set +e
brew install wget watch git kubernetes-helm git-crypt pwgen jq telnet zsh tmux go dep kubectx fzf unzip
set -e

#######
# zsh #
#######
if ! grep -q "source \$HOME/.bash_profile" $HOME/.zshrc; then
	echo "source \$HOME/.bash_profile" >> $HOME/.zshrc
fi

##########
# gcloud #
##########
rm -f "/tmp/google-cloud-sdk-$GCLOUD_VERSION-darwin-x86_64.tar.gz"
wget -N -P /tmp/ "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-$GCLOUD_VERSION-darwin-x86_64.tar.gz"
tar -xzf "/tmp/google-cloud-sdk-$GCLOUD_VERSION-darwin-x86_64.tar.gz" -C $BINS_DIR
rm -f "/tmp/google-cloud-sdk-$GCLOUD_VERSION-darwin-x86_64.tar.gz"
printf 'y\ny\n' | sh $BINS_DIR/google-cloud-sdk/install.sh

#############
# terraform #
#############
rm -f /tmp/terraform_${TERRAFORM_VERSION}_darwin_amd64.zip
wget -N -P /tmp/ "https://releases.hashicorp.com/terraform/0.11.11/terraform_${TERRAFORM_VERSION}_darwin_amd64.zip"
unzip -o "/tmp/terraform_${TERRAFORM_VERSION}_darwin_amd64.zip" -d $BINS_DIR
rm -f /tmp/terraform_${TERRAFORM_VERSION}_darwin_amd64.zip
chmod +x $BINS_DIR/terraform

############
# minikube #
############
rm -f /tmp/minikube-darwin-amd64
wget -N -P /tmp/ "https://github.com/kubernetes/minikube/releases/download/v$MINIKUBE_VERSION/minikube-darwin-amd64"
mv /tmp/minikube-darwin-amd64 $BINS_DIR/minikube
chmod +x $BINS_DIR/minikube

curl -o /tmp/docker-machine-driver-hyperkit -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-hyperkit
sudo install -o root -g wheel -m 4755 /tmp/docker-machine-driver-hyperkit $BINS_DIR/
rm /tmp/docker-machine-driver-hyperkit

