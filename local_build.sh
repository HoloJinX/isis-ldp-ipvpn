#!/bin/bash

# Define the path to the virtual environment
VENV_PATH="venv"
REQUIREMENTS_FILE="requirements.txt"
PLAYBOOK_FILE="build.yml"
VENV_ACTIVATED=0

# Function to check if virtual environment is active
function is_venv_active {
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        return 0
    else
        return 1
    fi
}

# Check if the virtual environment directory exists and activate it if not already active
if [ ! -d "$VENV_PATH" ]; then
    echo "Virtual environment not found. Creating virtual environment..."
    python3 -m venv $VENV_PATH
    echo "Virtual environment created."
fi

if ! is_venv_active; then
    echo "Activating virtual environment..."
    source $VENV_PATH/bin/activate
    VENV_ACTIVATED=1
fi

# Function to check if a Python package is installed
function is_package_installed {
    pip show "$1" &> /dev/null
    return $?
}

# Check and install required Python packages
if ! is_package_installed "ansible"; then
    echo "Installing required Python packages..."
    pip install -r $REQUIREMENTS_FILE
    echo "Requirements installed."
else
    echo "Required Python packages already installed."
fi

# Function to check if an Ansible collection is installed
function is_ansible_collection_installed {
    ansible-galaxy collection list | grep "$1" &> /dev/null
    return $?
}

# Check and install Ansible collections
if ! is_ansible_collection_installed "arista.avd"; then
    echo "Installing Ansible collections..."
    ansible-galaxy collection install arista.avd
    echo "Ansible collections installed."
else
    echo "Ansible collections already installed."
fi

# Run the Ansible playbook
echo "Running Ansible playbook: $PLAYBOOK_FILE..."
ansible-playbook $PLAYBOOK_FILE

# Deactivate the virtual environment if it was activated by the script
if [ $VENV_ACTIVATED -eq 1 ]; then
    deactivate
fi
echo "Playbook execution completed."