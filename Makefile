.DEFAULT_GOAL = update

current_dir := $(shell pwd)
RUBY_VERSION := 2.3.1

update:	update-janus refresh

upgrade: refresh-submodules update upgrade-brews upgrade-pip-requirements upgrade-gems upgrade-casks

install: refresh-submodules install-homebrew update-homebrew install-brews install-pip-requirements install-janus update-janus link-dotfiles install-powerline-fonts install-bundler install-gems install-casks

freeze: freeze-brews freeze-pip-requirements freeze-casks

refresh: refresh-submodules link-dotfiles

link-dotfiles: vimrc gvimrc janus config tmux bash jrnl gitconfig

vimrc:
	@echo "Linking .vimrc files..."
	-@rm ~/.vimrc.before || true
	@ln -s $(current_dir)/vimrc.before ~/.vimrc.before
	-@rm ~/.vimrc.after || true
	@ln -s $(current_dir)/vimrc.after ~/.vimrc.after

gvimrc:
	@echo "Linking .gvimrc files..."
	-@rm ~/.gvimrc.after || true
	@ln -s $(current_dir)/gvimrc.after ~/.gvimrc.after

gitconfig:
	@echo "Linking gitconfig..."
	-@rm -rf ~/.gitconfig || true
	@ln -s $(current_dir)/gitconfig ~/.gitconfig
	-@rm -rf ~/.git-completion.bash || true
	@ln -s $(current_dir)/git-completion.bash ~/.git-completion.bash

janus:
	@echo "Linking janus submodules..."
	-@rm -rf ~/.janus || true
	@ln -s $(current_dir)/janus ~/.janus

config:
	@echo "Linking config folder..."
	-@rm -rf ~/.config || true
	@ln -s $(current_dir)/config ~/.config

tmux:
	@echo "Linking tmux files..."
	-@rm ~/.tmux.conf || true
	@ln -s $(current_dir)/tmux.conf ~/.tmux.conf
	-@rm -rf ~/.tmuxinator-completion.bash || true
	@ln -s $(current_dir)/tmuxinator-completion.bash ~/.tmuxinator-completion.bash

jrnl:
	@echo "Linking jrnl files..."
	-@rm ~/.jrnl_config || true
	@ln -s $(current_dir)/jrnl_config ~/.jrnl_config

bash:
	@echo "Linking bash files..."
	-@rm ~/.bash_profile || true
	@touch ~/.bash_sessions_disable
	@ln -s $(current_dir)/bash_profile ~/.bash_profile
	@mkdir ~/.sources || true

refresh-submodules:
	@echo "Refreshing project submodules..."
	@git submodule sync && git submodule update --recursive --init
	@git submodule foreach --recursive 'git fetch origin master; git checkout master; git reset --hard origin/master'

install-powerline-fonts:
	@echo "Installing powerline fonts"
	@find submodules/powerline-fonts/ -type f -name "*.otf" -exec cp '{}' /Library/Fonts/ \;

install-janus:
	@echo "Installing janus..."
	@curl -Lo- https://bit.ly/janus-bootstrap | bash

update-janus: refresh-submodules
	@echo "Updating janus..."
	@cd ./janus && make update
	@cd ~/.vim && rake

install-homebrew:
	@echo "Installing homebrew..."
	-ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

update-homebrew:
	@echo "Updating homebrew..."
	@brew update
	@brew doctor

upgrade-brews: update-homebrew
	@echo "Upgrading homebrew..."
	@brew upgrade

install-brews:
	@echo "Installing brews..."
	@cat brew/FORMULAE.txt | cut -f 1 -d " " | xargs brew install

freeze-brews:
	@echo "Freezing brews..."
	@brew list --versions > ./brew/FORMULAE.txt

update-brew-cask:
	@echo "Updating brew cask..."
	@brew tap caskroom/cask
	@brew cask update
	@brew cask doctor

install-casks: update-brew-cask
	@echo "Installing casks..."
	@cat cask/CASKS.txt | xargs brew cask install

install-npm-modules:
	@echo "Installing NPM modules..."
	@cat npm/MODULES.txt | xargs npm install -g

freeze-casks:
	@echo "Freezing casks..."
	@brew cask list | tr '\t' '\n' > cask/CASKS.txt

upgrade-casks: reinstall-outdated-casks

reinstall-outdated-casks:
	@echo "Reinstalling outdated casks..."
	brew cask outdated | cut -f 1 -d " " | xargs brew cask reinstall

freeze-pip-requirements:
	@echo "Freezing pip requirements..."
	@pip freeze > ./pip/REQUIREMENTS.txt

install-pip-requirements:
	@echo "Installing pip requirements..."
	@pip install -r ./pip/REQUIREMENTS.txt

upgrade-pip-requirements:
	@echo "Upgrading pip requirements..."
	@pip install --upgrade pip
	@cat pip/REQUIREMENTS.txt | cut -f 1 -d "=" | xargs pip install --upgrade

install-bundler:
	@gem install bundler
	@rbenv rehash

install-ruby:
	@rbenv versions | grep $(RUBY_VERSION) || rbenv install $(RUBY_VERSION)
	@rbenv global $(RUBY_VERSION)

install-gems: install-ruby
	@bundle install --gemfile=./Gemfile
	@rbenv rehash

use-rbenv:
	@rbenv global $(RUBY_VERSION)

upgrade-gems: use-rbenv
	@bundle update
	@rbenv rehash

.PHONY: install update vimrc gvimrc janus config tmux bash update-janus freeze-brews freeze-pip-requirements install-pip-requirements gitconfig upgrade-casks
