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
    local language=""
    local version=""
    local env_name=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -l | --language)
            language="$2"
            shift 2
            ;;
        -v | --version)
            version="$2"
            shift 2
            ;;
        -n | --name)
            env_name="$2"
            shift 2
            ;;
        *)
            shift
            ;;
        esac
    done

    if [[ -z $language || -z $version || -z $env_name ]]; then
        echo "env-create: Please provide language, version, and environment name."
        echo "env-create: Usage: env-create [--language|-l] <language> [--version|-v] <version> [--name|-n] <env_name>"
        echo "env-create: Supported languages: python, dotnet, r"
        echo "env-create: ❌ Operation aborted. ❌"
        return 1
    fi

    case $language in
    python)
        env_name="py-${env_name}"
        echo "env-create: 🛠️ Creating Python Conda environment: $env_name with Python $version 🛠️"
        conda create -n "$env_name" python="$version"
        ;;
    dotnet)
        env_name="cs-${env_name}"
        echo "env-create: 🛠️ Creating .NET Conda environment: $env_name with .NET $version 🛠️"
        conda create -n "$env_name" -c conda-forge dotnet-sdk="$version"
        ;;
    r)
        env_name="R-${env_name}"
        echo "env-create: 🛠️ Creating R Conda environment: $env_name with R $version 🛠️"
        conda create -n "$env_name" -c conda-forge r-base="$version"
        ;;
    *)
        echo "env-create: Unsupported language: $language"
        echo "env-create: Supported languages: python, dotnet, r"
        echo "env-create: ❌ Operation aborted. ❌"
        return 1
        ;;
    esac

    if [[ $? -eq 0 ]]; then
        echo "env-create: 🎉 Successfully created $language Conda environment: $env_name with $language $version 🎉"
        return 0
    else
        echo "env-create: ❌ Failed to create $language Conda environment. ❌"
        return 1
    fi
}

# === Remove a Conda environment ===

env-remove() {
    verify_conda || return 1

    if [[ $# -eq 0 || $# -gt 2 ]]; then
        echo "env-remove: Incorrect number of arguments."
        echo "env-remove: Usage: env-remove <env_name> [-y]"
        echo "env-remove: ❌ Operation aborted. ❌"
        return 1
    fi

    local env_name="$1"
    local yes_flag=""

    if [[ $# -eq 2 && $2 == "-y" ]]; then
        yes_flag="--yes"
    elif [[ $# -eq 2 && $2 != "-y" ]]; then
        echo "env-remove: Invalid option: $2"
        echo "env-remove: Usage: env-remove <env_name> [-y]"
        echo "env-remove: ❌ Operation aborted. ❌"
        return 1
    fi

    echo "env-remove: 🛠️ Removing Conda environment: $env_name 🛠️"
    conda remove --name "$env_name" --all $yes_flag
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

    local language=""

    if [[ $# -eq 1 ]]; then
        case "$1" in
        dotnet | cs | CS | csharp)
            language="cs"
            ;;
        r | R)
            language="R"
            ;;
        python | Python | py)
            language="py"
            ;;
        *)
            echo "env-list: Unsupported language: $1"
            echo "env-list: ❌ Operation aborted. ❌"
            return 1
            ;;
        esac
    fi

    echo "env-list: 📋 Listing Conda environments\n"

    if [[ -z $language ]]; then
        conda env list
    else
        local result=$(conda env list | grep -E "^$language-")
        if [[ -z $result ]]; then
            echo "env-list: No environments found for language: $language"
        else
            echo "$result\n"
        fi
    fi
}

# === Clean cache and artefacts ===

env-cleanup() {
    verify_conda || return 1

    local yes_flag=""

    if [[ $# -eq 1 && $1 == "-y" ]]; then
        yes_flag="--yes"
    elif [[ $# -eq 1 && $1 != "-y" ]]; then
        echo "env-cleanup: Invalid option: $1"
        echo "env-cleanup: Usage: env-cleanup [-y]"
        echo "env-cleanup: ❌ Operation aborted. ❌"
        return 1
    elif [[ $# -gt 1 ]]; then
        echo "env-cleanup: Incorrect number of arguments."
        echo "env-cleanup: Usage: env-cleanup [-y]"
        echo "env-cleanup: ❌ Operation aborted. ❌"
        return 1
    fi

    echo "env-cleanup: 🛠️ Cleaning Conda environment 🛠️"
    conda clean --all $yes_flag
    if [[ $? -eq 0 ]]; then
        echo "env-cleanup: 🎉 Conda environment cleaned successfully! 🎉"
        return 0
    else
        echo "env-cleanup: ❌ Failed to clean Conda environment. ❌"
        return 1
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
