# Set path
export PATH=/usr/local/bin:~/bin:$PATH

# Set prompt
export PS1="[\h] \w/\$ "

# Rbenv
eval "$(rbenv init -)"

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

# Fun aliases
alias glog="git log --graph --full-history --all --color --pretty=format:'%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s'"
