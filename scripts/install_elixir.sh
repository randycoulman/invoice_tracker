#!/bin/bash

set -e

main() {
  ensure_asdf_installed
  install_plugins
  install_languages
}

ensure_asdf_installed() {
  if ! asdf | grep version; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.2.1
  fi
}

install_plugins() {
  install_or_update_plugin erlang
  install_or_update_plugin elixir
}

install_languages() {
  asdf install
}

install_or_update_plugin() {
  plugin=$1

  if ! asdf plugin-list | grep $plugin; then
    asdf plugin-add $plugin https://github.com/asdf-vm/asdf-$plugin.git
  else
    asdf plugin-update $plugin
  fi
}

main
