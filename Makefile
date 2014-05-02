.DEFAULT_GOAL = update

current_dir := $(shell pwd)

update:	update-janus update-brew refresh

upgrade: update upgrade-brews upgrade-pip-requirements freeze

install: install-homebrew update-homebrew install-brews install-pip-requirements install-janus freeze

freeze: freeze-brews freeze-pip-requirements

refresh: link-dotfiles

link-dotfiles: vimrc gvimrc janus config tmux bash

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

bash:
	@echo "Linking bash files..."
	-@rm ~/.bash_profile || true
	@ln -s $(current_dir)/bash_profile ~/.bash_profile

install-janus:
	@echo "Installing janus..."
	@curl -Lo- https://bit.ly/janus-bootstrap | bash

update-janus:
	@echo "Updating janus..."
	@cd ~/.vim && rake

install-homebrew:
	@echo "Installing homebrew..."
	@ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

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

freeze-pip-requirements:
	@echo "Freezing pip requirements..."
	@pip freeze > ./pip/REQUIREMENTS.txt

install-pip-requirements:
	@echo "Installing pip requirements..."
	@pip install -r ./pip/REQUIREMENTS.txt

upgrade-pip-requirements:
	@echo "Upgrading pip requirements..."
	@cat pip/REQUIREMENTS.txt | cut -f 1 -d "=" | xargs pip install --upgrade

.PHONY: install update vimrc gvimrc janus config tmux bash update-janus freeze-brews freeze-pip-requirements install-pip-requirements