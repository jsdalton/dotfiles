# Set path
export PATH=/usr/local/sbin:/usr/local/bin:~/bin:$PATH

# Set Go path stuff
export GOPATH=$HOME/golang
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin

# Set prompt
export PS1="[\h] \w/\$ "

# Rbenv
eval "$(rbenv init -)"

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
  git checkout preview && git fetch origin preview && git reset --hard origin/preview
  git merge $branch -m "Merging "$branch
  git push origin --force-with-lease
  git checkout $branch
}

# Fun aliases
alias glog="git log --graph --full-history --all --color --pretty=format:'%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s'"
alias bunny="ssh -t -L 16666:127.0.0.1:16667 contentful_staging -- ssh -L 16667:127.0.0.1:15672"
alias reset_preview!="git checkout preview && git fetch origin preview && git reset --hard origin/preview"
