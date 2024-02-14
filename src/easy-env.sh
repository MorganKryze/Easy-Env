#!/bin/bash

# === Display help message ===

env-help() {
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    RED='\033[0;31m'
    ORANGE='\033[0;33m'
    RESET='\033[0m'

    echo -e "\nWelcome to the Conda Environment Helper!\n"

    echo -e "Here are all the Conda environment functions created to help you manage your environments.\n"

    echo -e "Available functions:\n"
    for func in env-install env-uninstall env-update env-create env-remove env-list env-cleanup env-start env-stop; do
        echo -e "  ${BLUE}$func:${RESET}"
        case "$func" in
        "env-install")
            echo -e "    Install Miniconda and initialize Conda.\n"
            echo -e "    Usage: ${GREEN}env-install${RESET}"
            ;;
        "env-uninstall")
            echo -e "    Uninstall Miniconda and its dependencies.\n"
            echo -e "    Usage: ${GREEN}env-uninstall${RESET}"
            ;;
        "env-update")
            echo -e "    Update git repository and Conda.\n"
            echo -e "    Usage: ${GREEN}env-update${RESET}"
            ;;

        "env-create")
            echo -e "    Create a new Conda environment.\n"
            echo -e "    Usage: ${GREEN}env-create${RESET} ${RED}[--language|-l] <language> [--version|-v] <version> [--name|-n] <env_name>${RESET}"
            echo -e "      ${RED}--language, -l:${RESET} The programming language for the environment (python, dotnet, r)."
            echo -e "      ${RED}--version, -v:${RESET} The version of the language to use."
            echo -e "      ${RED}--name, -n:${RESET} The name of the environment to create."
            ;;
        "env-remove")
            echo -e "    Remove a Conda environment.\n"
            echo -e "    Usage: ${GREEN}env-remove${RESET} ${RED}<env_name> [-y]${RESET}"
            echo -e "      ${RED}<env_name>:${RESET} The name of the environment to remove."
            echo -e "      ${RED}-y:${RESET} [OPTIONAL] Confirm removal without prompting."
            ;;
        "env-list")
            echo -e "    List Conda environments.\n"
            echo -e "    Usage: ${GREEN}env-list${RESET} ${RED}[<language>]${RESET}"
            echo -e "      ${RED}<language>:${RESET} [OPTIONAL] Filter environments by language (python, dotnet, r)."
            ;;
        "env-cleanup")
            echo -e "    Clean cache and artifacts.\n"
            echo -e "    Usage: ${GREEN}env-cleanup${RESET} ${RED}[-y]${RESET}"
            echo -e "      ${RED}-y:${RESET} [OPTIONAL] Confirm cleanup without prompting."
            ;;
        "env-start")
            echo -e "    Start a Conda environment.\n"
            echo -e "    Usage: ${GREEN}env-start${RESET} ${RED}<env_name>${RESET}"
            echo -e "      ${RED}<env_name>:${RESET} The name of the environment to start."
            ;;
        "env-stop")
            echo -e "    Stop the active Conda environment.\n"
            echo -e "    Usage: ${GREEN}env-stop${RESET}"
            ;;
        *)
            echo -e "  ${RED}No help text available.${RESET}"
            ;;
        esac
        echo ""
    done
}

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

# === Update git and conda ===

env-update() {
    verify_conda || return 1

    if [[ $# -ne 0 ]]; then
        echo "env-update: No arguments should be provided."
        echo "env-update: Usage: env-update"
        echo "env-update: ❌ Operation aborted. ❌"
        return 1
    fi

    echo "env-update: 🔄 Updating git repository 🔄"
    local repo_path="$EASY_ENV_PATH"

    if [ ! -d "$repo_path/.git" ]; then
        echo "git: Repository directory not found or not a Git repository."
        echo "git: ❌ Operation aborted. ❌"
        return 1
    fi

    echo "env-update: 🛠️ Pulling latest changes 🛠️"
    cd "$repo_path"

    git pull origin main

    cd -

    if [[ $? -ne 0 ]]; then
        echo "env-update: ❌ Failed to update git repository. ❌"
        return 1
    fi

    echo "env-update: 🔄 Updating Conda 🔄"
    conda update conda
    if [[ $? -ne 0 ]]; then
        echo "env-update: ❌ Failed to update Conda. ❌"
        return 1
    fi

    echo "env-update: 🎉 Easy-Env and Conda update successful! 🎉"
}

# === Create a Conda environment ===

env-create() {
    verify_conda || return 1
    
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

    if [[ -z $language || -z $env_name ]]; then
        echo "env-create: Please provide language and environment name."
        echo "env-create: Usage: env-create [--language|-l] <language> [--version|-v] <version> [--name|-n] <env_name>"
        echo "env-create: Supported languages: python, dotnet, r"
        echo "env-create: ❌ Operation aborted. ❌"
        return 1
    fi

    case $language in
    python)
        env_name="py-${env_name}"
        echo "env-create: 🛠️ Creating Python Conda environment: $env_name with Python $version 🛠️"
        conda create -n "$env_name" python="$version" -y
        if [[ $? -eq 0 ]]; then
            echo "env-create: 🎉 Successfully created Python Conda environment: $env_name with Python $version 🎉"
            echo "env-create: 📚 Recommended libraries: numpy, pandas, matplotlib"
            echo "env-create: 📚 To use Jupyter, install it with: conda install jupyter ipykernel 📚"
        else
            echo "env-create: ❌ Failed to create Python Conda environment. ❌"
            return 1
        fi
        ;;
    dotnet)
        env_name="cs-${env_name}"
        echo "env-create: 🛠️ Creating .NET Conda environment: $env_name with .NET $version 🛠️"
        conda create -n "$env_name" -c conda-forge dotnet-sdk="$version" -y
        if [[ $? -eq 0 ]]; then
            echo "env-create: 🎉 Successfully created .NET Conda environment: $env_name with .NET $version 🎉"
            echo "env-create: 📚 Recommended libraries: Newtonsoft.Json, Microsoft.Extensions.DependencyInjection"
            echo "env-create: 📚 To use Jupyter, refer to this page: https://github.com/dotnet/interactive/blob/main/docs/NotebookswithJupyter.md 📚"
            echo "env-create: 📚 if the ressoruce is not available anymore, an archive is available at: Easy-Env > src > assets > docs > interactive 📚"
        else
            echo "env-create: ❌ Failed to create .NET Conda environment. ❌"
            return 1
        fi
        ;;
    r)
        env_name="R-${env_name}"
        echo "env-create: 🛠️ Creating R Conda environment: $env_name with the latest version 🛠️"
        conda create -n "$env_name" -c conda-forge r-base -y
        if [[ $? -eq 0 ]]; then
            echo "env-create: 🎉 Successfully created R Conda environment: $env_name with the latest version 🎉"
            echo "env-create: 📚 Recommended libraries: dplyr, ggplot2, tidyr"
            echo "env-create: 📚 To use Jupyter, install it with: conda install jupyter r-irkernel📚"
        else
            echo "env-create: ❌ Failed to create R Conda environment. ❌"
            return 1
        fi
        ;;

    *)
        echo "env-create: Unsupported language: $language"
        echo "env-create: Supported languages: python, dotnet, r"
        echo "env-create: ❌ Operation aborted. ❌"
        return 1
        ;;
    esac

    echo "env-create: 🛠️ Activating the environment. 🛠️"
    conda activate "$env_name"

    if [[ $? -eq 0 ]]; then
        echo "env-create: 🎉 Successfully activated environment: $env_name 🎉"
    else
        echo "env-create: ❌ Failed to create R Conda environment. ❌"
        return 1
    fi

}

# === Remove a Conda environment ===

env-remove() {
    verify_conda || return 1

    if [[ $# -eq 0 || $# -gt 1 ]]; then
        echo "env-remove: Incorrect number of arguments."
        echo "env-remove: Usage: env-remove <env_name>"
        echo "env-remove: ❌ Operation aborted. ❌"
        return 1
    fi

    local env_name="$1"

    echo "env-remove: 🛠️ Removing Conda environment: $env_name 🛠️"
    conda remove --name "$env_name" --all -y
    if [[ $? -eq 0 ]]; then
        echo "env-remove: 🎉 Successfully removed Conda environment: $env_name 🎉"
        return 0
    else
        echo "env-remove: ❌ Failed to remove Conda environment. ❌"
        return 1
    fi
}

# === Start a Conda environment ===

env-start() {
    verify_conda || return 1

    if [[ $# -ne 1 ]]; then
        echo "env-start: Incorrect number of arguments."
        echo "env-start: Usage: env-start <env_name>"
        echo "env-start: ❌ Operation aborted. ❌"
        return 1
    fi

    local env_name="$1"

    echo "env-start: 🚀 Starting Conda environment: $env_name 🚀"
    conda activate "$env_name"
    if [[ $? -eq 0 ]]; then
        echo "env-start: 🎉 Successfully started Conda environment: $env_name 🎉"
        return 0
    else
        echo "env-start: ❌ Failed to start Conda environment. ❌"
        return 1
    fi
}

# === Stop a Conda environment ===

env-stop() {
    verify_conda || return 1

    if [[ $# -ne 0 ]]; then
        echo "env-stop: No arguments should be provided."
        echo "env-stop: Usage: env-stop"
        echo "env-stop: ❌ Operation aborted. ❌"
        return 1
    fi

    echo "env-stop: 🛑 Stopping active Conda environment 🛑"
    conda deactivate
    if [[ $? -eq 0 ]]; then
        echo "env-stop: 🎉 Successfully stopped active Conda environment. 🎉"
        return 0
    else
        echo "env-stop: ❌ Failed to stop active Conda environment. ❌"
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
