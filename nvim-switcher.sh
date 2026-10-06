#!/usr/bin/env bash

NVIM_DISTRO=$(
  cat <<'EOF'
default	nvim
lazyvim	lazyvim
EOF
)

SELECTED_DISTRO=$(echo "$NVIM_DISTRO" | column -t -s $'\t' | fzf | awk '{print $2}' | tr '\n' ' ')
eval "NVIM_APPNAME=$SELECTED_DISTRO nvim $1"
