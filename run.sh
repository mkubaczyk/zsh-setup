#!/bin/bash

set -ex

BINS_DIR="$HOME/bins"

pwd=$(pwd)

mkdir -p $HOME/bins
mkdir -p $HOME/git/go/

#################
# .bash_profile #
#################
cat <<EOF > $HOME/.bash_profile
############
# env vars #
############
export PATH="/usr/local/opt/gnu-getopt/bin:\$PATH:$BINS_DIR:/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"
export GOPATH=\$HOME/git/go

##########
# gcloud #
##########
source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc

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

alias sshc=sshc
sshc() {
    cat $HOME/.ssh/config
}

alias k=k
k() {
    kubectl \$@
}

alias b64=b64
b64() {
	echo \$1 | base64 --decode
}
EOF

########
# bins #
########
files=( )
for filename in "${files[@]}"
do
    curl -o $HOME/bins/$filename https://raw.githubusercontent.com/mkubaczyk/zsh-setup/master/bins/$filename
done

git clone git@github.com:mkubaczyk/tfplan.git $HOME/git/tfplan || true
ln -fs $PWD/tfplan /usr/local/bin/tfplan || true
ln -fs $PWD/tfapply /usr/local/bin/tfapply || true

########
# brew #
########
printf 'y\ny\n' | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew_upgradable=( csshx git-flow-avh wrk sops wget watch git git-crypt pwgen jq telnet zsh dep kubectx fzf unzip gnu-getopt tree terraform_landscape terraform docker-machine-driver-hyperkit )
brew_unupgradable=( kubernetes-helm kubernetes-cli go )
brew_all=("${brew_upgradable[@]}" "${brew_unupgradable[@]}")
brew_casks=( minikube google-cloud-sdk )
brew tap caskroom/cask
brew update
brew cask install "${brew_casks[@]}" || brew cask upgrade "${brew_casks[@]}" || true
brew install "${brew_all[@]}" || brew upgrade "${brew_upgradable[@]}" || true

sudo chown root:wheel /usr/local/opt/docker-machine-driver-hyperkit/bin/docker-machine-driver-hyperkit
sudo chmod u+s /usr/local/opt/docker-machine-driver-hyperkit/bin/docker-machine-driver-hyperkit

helm init --client-only
helm plugin install https://github.com/futuresimple/helm-secrets || helm plugin update https://github.com/futuresimple/helm-secrets || true
helm plugin install https://github.com/databus23/helm-diff --version master || helm plugin update https://github.com/databus23/helm-diff --version master || true
helm plugin install https://github.com/nouney/helm-gcs --version 0.2.0 || helm plugin update https://github.com/nouney/helm-gcs --version 0.2.0 || true

#############
# oh my zsh #
#############
rm -rf $HOME/.oh-my-zsh/
curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash - || true

#######
# zsh #
#######
if ! grep -q "export ZSH_DISABLE_COMPFIX=true" $HOME/.zshrc; then
    echo "export ZSH_DISABLE_COMPFIX=true" | cat - $HOME/.zshrc > /tmp/.zshrc && mv /tmp/.zshrc $HOME/.zshrc
fi
if ! grep -q "source \$HOME/.bash_profile" $HOME/.zshrc; then
	echo "source \$HOME/.bash_profile" >> $HOME/.zshrc
fi
