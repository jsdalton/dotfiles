# Set path
export PATH=/usr/local/bin:~/bin:$PATH

# Set prompt
export PS1="[jsd-instrument] \w/\$ "

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi 
