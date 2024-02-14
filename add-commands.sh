#!/bin/bash

# === Define the path to the script ===

echo "env-setup: 🛠️ Getting the full path of env-setup.sh 🛠️"
full_path=$(realpath src/easy-env.sh)
line_to_add="\n# Easy-Env commands for environment managment\nsource $full_path"

# === Add the reference to the script in .zshrc ===

echo "env-setup: 🛠️ Trying to add the reference to the file in the .zshrc 🛠️"
if [ -f ~/.zshrc ]; then
    if ! grep -qF "source $full_path" ~/.zshrc; then
        echo "$line_to_add" >>~/.zshrc
        echo "env-setup: 🎉 Line successfully added! You may restart your terminal to use the functions. 🎉"
    else
        echo "env-setup: 🛠️ Line already exists in .zshrc. No action taken. 🛠️"
    fi
else
    echo "env-setup: .zshrc file not found. Please create one in your home directory."
    echo "env-setup: ❌ Operation aborted. ❌"
fi
