# This is a hack to get nvm working.
# See: https://github.com/creationix/nvm/issues/1652
PATH="/usr/local/bin:$(getconf PATH)"

# Set path
export PATH=/usr/local/sbin:/usr/local/bin:~/bin:$PATH

# Set Go path stuff
export GOPATH=$HOME/golang
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin

# Suppress warning about default interactive shell
export BASH_SILENCE_DEPRECATION_WARNING=1

# Set prompt
export PS1="[\h] \w/\$ "

# Rbenv
eval "$(rbenv init -)"

# Set default editor
export EDITOR=vim

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi
if [ -f ~/.tmuxinator-completion.bash ]; then
  . ~/.tmuxinator-completion.bash
fi

# Make sure locales are correct in terminal
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Extra bash sources
if [ -d ~/.sources ]; then
  for f in ~/.sources/*.bash;
  do
    if [ -f $f ]; then
      source $f;
    fi
  done
fi

# Complete ssh config
_complete_ssh_hosts ()
{
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  comp_ssh_hosts=`cat ~/.ssh/known_hosts | \
    cut -f 1 -d ' ' | \
    sed -e s/,.*//g | \
    grep -v ^# | \
    uniq | \
    grep -v "\[" ;
  cat ~/.ssh/config | \
    grep "^Host " | \
    awk '{print $2}'
  `
  COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- $cur))
  return 0
}
complete -F _complete_ssh_hosts ssh

# Remove whitespace and linebreaks
function trim {
  tr -d '\040\011\012\015'
}

# Do a rubocop
function rubocop! {
  git diff origin/master --name-only | grep '.rb$' | xargs -L 1 rubocop -a
}

function preview! {
  git status
  branch=$(git symbolic-ref -q --short HEAD)
  echo
  echo "About to merge '"$branch"' branch into preview...";
  read -p "Press [Enter] to continue: "
  echo
  git checkout preview && \
    git fetch origin preview && \
    git reset --hard origin/preview
  git merge $branch -m "Merging "$branch
  git push origin --force-with-lease
  git checkout $branch
}

function rebuild_preview!  {
  git status
  branch=$(git symbolic-ref -q --short HEAD)
  echo
  echo "About to rebuild preview from master...";
  read -p "Press [Enter] to continue: "
  echo
  git checkout preview \
    && git fetch origin \
    && git reset --hard origin/master
  origin_master_ref=$(git rev-parse origin/master)
  origin_preview_ref=$(git rev-parse origin/preview)
  hub pr list --format="origin/%H%l%n" -o updated \
    | grep "On Preview" \
    | cut -d " " -f1 \
    | xargs -L 1 git merge --no-edit
  preview_ref=$(git rev-parse preview)
  if [ "$preview_ref" = "$origin_preview_ref" ]; then
    echo "No change on preview branch aborting..."
  else
    git push origin --force-with-lease
    git checkout $branch
  fi
}

function lab {
  cd ~/lab
}

function kube_contexts {
  kubectl config get-contexts | grep gatekeeper | awk '{ print $2 }'
}

function kube_console {
  context='gatekeeper-001-euw1.quirely.com'
  [ -n "$1" ] && context=$1
  echo "Launching console on pod in $context cluster..."
  kubectl get pods --context=$context --selector=app=gatekeeper | grep Running | awk '{ print $1 }' | tail -n 1 | xargs -o -I {} kubectl exec {} --context=$context -c gatekeeper -i -t -- rails console
}

function kube_sh {
  context='gatekeeper-001-euw1.quirely.com'
  [ -n "$1" ] && context=$1
  echo "Launching console on pod in $context cluster..."
  kubectl get pods --context=$context --selector=app=gatekeeper | grep Running | awk '{ print $1 }' | tail -n 1 | xargs -o -I {} kubectl exec {} --context=$context -c gatekeeper -i -t -- sh
}

# Fun aliases
alias glog="git log --graph --full-history --all --color --pretty=format:'%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s'"
alias bunny="ssh -t -L 16666:127.0.0.1:16667 contentful_staging -- ssh -L 16667:127.0.0.1:15672"
alias reset_preview!="git checkout preview && git fetch origin preview && git reset --hard origin/preview"
alias vi=vim
alias k=kubectl
alias kcuc="kubectl config use-context"
alias kccc="kubectl config current-context"
alias kcgc="kubectl config get-contexts"
alias kgp="kubectl get pods"
alias kdp="kubectl describe pod"
alias kgj="kubectl get jobs"
alias kgc="kubectl get cronjobs"
alias kgns="kubectl get namespaces"
alias keit="kubectl exec -it"

# nvm
export NVM_DIR="$HOME/.nvm"
. "/usr/local/opt/nvm/nvm.sh"

# kubectl for contentful
export KUBECONFIG=~/.kube/cf-auth-okta.yaml:~/.kube/cf-staging.yaml:~/.kube/cf-preview.yaml:~/.kube/cf-tools.yaml:~/.kube/cf-production.yaml:/Users/jsdalton/.kube/cf-convenience.yaml

# dotenv
eval "$(direnv hook bash)"
