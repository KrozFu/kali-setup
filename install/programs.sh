#!/bin/bash

set -e # Stop at my error

# List to tools to install
TOOLS=(
    gdb
    dirsearch
    docker.io
)

echo "🔍 Checking and install necesary tools..."

# Update system packages - Optional
read -p "Do you want to update the system befeore installing? (y/n)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📦 Updating system..."
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
fi

# Go through and install each tools if it is not alredy installed
for tool in "${TOOLS[@]}"; do
    if dpkg -l | grep -qw "$tool"; then
        echo "✅ '$tool' It is already installed"
    else
        echo "💾 Installing '$tool'..."
        sudo apt install -y "$tool"
        # Special handling for Docker
        if [ "$tool" = "docker.io" ]; then
            echo "🐳 Enabling Docker service..."
            sudo systemctl enable docker --now
            echo "✅ Docker service enabled."
        fi
    fi
done

echo "*** Complete installation ***"
