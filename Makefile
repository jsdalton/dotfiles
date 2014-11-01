.DEFAULT_GOAL = update

current_dir := $(shell pwd)

update:	refresh-submodules update-janus refresh

upgrade: refresh-submodules update upgrade-brews upgrade-pip-requirements freeze

install: refresh-submodules install-homebrew update-homebrew install-brews install-pip-requirements install-janus update-janus link-dotfiles install-powerline-fonts

freeze: freeze-brews freeze-pip-requirements

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

jrnl:
	@echo "Linking jrnl files..."
	-@rm ~/.jrnl_config || true
	@ln -s $(current_dir)/jrnl_config ~/.jrnl_config

bash:
	@echo "Linking bash files..."
	-@rm ~/.bash_profile || true
	@ln -s $(current_dir)/bash_profile ~/.bash_profile

refresh-submodules:
	@echo "Refreshing project submodules..."
	@git submodule update --recursive --init

install-powerline-fonts:
	@echo "Installing powerline fonts"
	@find submodules/powerline-fonts/ -type f -name "*.otf" -exec cp '{}' /Library/Fonts/ \;

install-janus:
	@echo "Installing janus..."
	@curl -Lo- https://bit.ly/janus-bootstrap | bash

update-janus:
	@echo "Updating janus..."
	@git submodule foreach --recursive 'git fetch --tags'
	@git submodule update --recursive --init
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
	@brew cask update
	@brew cask doctor

install-casks:
	@echo "Installing casks..."
	@cat cask/CASKS.txt | xargs brew cask install

freeze-casks:
	@echo "Freezing casks..."
	@brew cask list | tr '\t' '\n' > cask/CASKS.txt

freeze-pip-requirements:
	@echo "Freezing pip requirements..."
	@pip freeze > ./pip/REQUIREMENTS.txt

install-pip-requirements:
	@echo "Installing pip requirements..."
	@pip install -r ./pip/REQUIREMENTS.txt

upgrade-pip-requirements:
	@echo "Upgrading pip requirements..."
	@cat pip/REQUIREMENTS.txt | cut -f 1 -d "=" | xargs pip install --upgrade

.PHONY: install update vimrc gvimrc janus config tmux bash update-janus freeze-brews freeze-pip-requirements install-pip-requirements gitconfig
