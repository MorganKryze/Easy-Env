#!/bin/bash

# === Install Miniconda and initialize Conda ===

env-install() {
    if [[ $# -ne 0 ]]; then
        echo "env-install: No arguments should be provided."
        echo "env-install: Usage: env-install"
        echo "env-install: ❌ Operation aborted. ❌"
        return 1
    fi

    if command -v conda &>/dev/null; then
        echo "env-install: Miniconda is already installed."
        return 0
    fi

    echo "env-install: 🛠️ Installing Miniconda 🛠️"
    brew install miniconda
    if [[ $? -ne 0 ]]; then
        echo "env-install: ❌ Failed to install Miniconda. Please check your internet connection or try again later. ❌"
        return 1
    fi

    echo "env-install: 🛠️ Initializing Conda 🛠️"
    conda init "$(basename "${SHELL}")"
    if [[ $? -ne 0 ]]; then
        echo "env-install: ❌ Failed to initialize Conda. Please check your shell configuration and try again. ❌"
        return 1
    fi

    echo "env-install: 🎉 Conda installation and initialization successful! 🎉"
}

# === Uninstall Miniconda and its dependencies ===

env-uninstall() {
    verify_conda || return 1

    if [[ $# -ne 0 ]]; then
        echo "env-uninstall: No arguments should be provided."
        echo "env-uninstall: Usage: env-uninstall"
        echo "env-uninstall: ❌ Operation aborted. ❌"
        return 1
    fi

    if ! command -v conda &>/dev/null; then
        echo "env-uninstall: Miniconda is not installed."
        return 1
    fi

    read -r confirm"?env-uninstall: Are you sure you want to uninstall Miniconda? This action is irreversible. [y/N]: "
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "env-uninstall: Uninstallation cancelled."
        return 0
    fi

    echo "env-uninstall: 🛠️ Uninstalling Miniconda 🛠️"
    brew uninstall --force miniconda
    if [[ $? -ne 0 ]]; then
        echo "env-uninstall: ❌ Failed to uninstall Miniconda. Please check your system configuration and try again. ❌"
        return 1
    fi

    echo "env-uninstall: 🛠️ Removing Miniconda directories 🛠️"
    rm -rf ~/.conda ~/.condarc ~/.continuum

    echo "env-uninstall: 🎉 Miniconda uninstallation complete! Though, do not forget to remove the conda initialization in your .zshrc! 🎉"
}

# === Create a Conda environment ===

env-create() {
    if [[ $# -lt 3 || $# -gt 5 ]]; then
        echo "env-create: Incorrect number of arguments."
        echo "env-create: Usage: env-create <env_name> <language> [-v|--version] <version>"
        echo "env-create: Supported languages: python, dotnet, r"
        echo "env-create: ❌ Operation aborted. ❌"
        return 1
    fi

    if [[ -z $1 || -z $2 ]]; then
        echo "env-create: Please provide environment name and language."
        echo "env-create: Usage: env-create <env_name> <language> [-v|--version] <version>"
        echo "env-create: Supported languages: python, dotnet, r"
        echo "env-create: ❌ Operation aborted. ❌"
        return 1
    fi

    env_name="$1"
    language="$2"
    version=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -v | --version)
            version="$2"
            shift 2
            ;;
        *)
            shift
            ;;
        esac
    done

    if [[ -z $version ]]; then
        case $language in
        python)
            version=$(conda search --json "$language" | jq -r '.["data"] | .[0] | .["version"]')
            ;;
        dotnet)
            version=$(conda search --json "$language-sdk" | jq -r '.["data"] | .[0] | .["version"]')
            ;;
        r)
            version=$(conda search --json r-base | jq -r '.["data"] | .[0] | .["version"]')
            ;;
        *)
            echo "env-create: Unsupported language: $language"
            echo "env-create: Supported languages: python, dotnet, r"
            echo "env-create: ❌ Operation aborted. ❌"
            return 1
            ;;
        esac
    fi

    case $language in
    python) ;;
    dotnet) ;;
    r) ;;
    *)
        echo "env-create: Unsupported language: $language"
        echo "env-create: Supported languages: python, dotnet, r"
        echo "env-create: ❌ Operation aborted. ❌"
        return 1
        ;;
    esac

    echo "env-create: 🛠️ Creating Conda environment: $env_name with $language $version 🛠️"
    conda create -n "$env_name" "$language"="$version"
    if [[ $? -eq 0 ]]; then
        echo "env-create: 🎉 Successfully created Conda environment: $env_name with $language $version 🎉"
        return 0
    else
        echo "env-create: ❌ Failed to create Conda environment. ❌"
        return 1
    fi
}

# === Remove a Conda environment ===

env-remove() {
    verify_conda || return 1

    if [[ $# -ne 1 ]]; then
        echo "env-remove: Incorrect number of arguments."
        echo "env-remove: Usage: env-remove <env_name>"
        echo "env-remove: ❌ Operation aborted. ❌"
        return 1
    fi

    env_name="$1"

    echo "env-remove: 🛠️ Removing Conda environment: $env_name 🛠️"
    conda remove --name "$env_name" --all
    if [[ $? -eq 0 ]]; then
        echo "env-remove: 🎉 Successfully removed Conda environment: $env_name 🎉"
        return 0
    else
        echo "env-remove: ❌ Failed to remove Conda environment. ❌"
        return 1
    fi
}

# === List Conda environments ===

env-list() {
    verify_conda || return 1

    if [[ $# -gt 1 ]]; then
        echo "env-list: Incorrect number of arguments."
        echo "env-list: Usage: env-list [<language>]"
        echo "env-list: ❌ Operation aborted. ❌"
        return 1
    fi

    if [[ $# -eq 1 ]]; then
        language="$1"
    fi

    echo "env-list: 📋 Listing Conda environments"

    if [[ -z $language ]]; then
        conda env list
    else
        conda env list | grep "$language"
    fi
}


# === Check if conda is installed ===

verify_conda() {
    if ! command -v conda &>/dev/null; then
        echo "env-check: Conda is not installed or not found in the PATH. "
        echo "env-check: Please make sure Conda is installed and properly configured."
        echo "env-check: ❌ Operation aborted. ❌"
        return 1
    fi
}
