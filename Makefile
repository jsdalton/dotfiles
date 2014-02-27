.DEFAULT_GOAL = update

current_dir := $(shell pwd)

update: link-dotfiles update-janus
	@echo "Linking files..."

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

update-janus:
	@echo "Updating janus..."
	@cd ~/.vim && rake

.PHONY: update vimrc gvimrc janus config tmux bash update-janus
