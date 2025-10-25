#!/bin/bash

# Stop at any error
set -e

# Variables
USERNAME="krozfu"
PASSWORD="krozfu"
ZSH_PATH="/usr/bin/zsh"
ZSH_CUSTOM="/home/$USERNAME/.oh-my-zsh/custom"
ZSHRC="/home/$USERNAME/.zshrc"

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
	echo "❌ This script must be run as root, use sudo"
	exit 1
fi

echo "▶️ Updating system..."
apt update && apt upgrade -y && apt autoremove -y

# Create the user if it does not exist
if id "$USERNAME" &>/dev/null; then
	echo "⚠️ User '$USERNAME' already exists."
else
	echo "👤 Creating user '$USERNAME'..."
	useradd -m -s "$ZSH_PATH" "$USERNAME"
	echo "$USERNAME:$PASSWORD" | chpasswd
	usermod -aG sudo "$USERNAME"
	echo "✅ User '$USERNAME' created and added to the sudo group."
fi

# Install ZSH if not installed
if ! command -v zsh &>/dev/null; then
	echo "💾 Installing ZSH..."
	apt install -y zsh
else
	echo "✅ ZSH is already installed."
fi

# Install oh-my-zsh
# if [ ! -d "/home/$USERNAME/.oh-my-zsh" ]; then
# 	echo "⚙️ Installing oh-my-zsh for '$USERNAME'..."
# 	sudo -u "$USERNAME" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# else
# 	echo "✅ oh-my-zsh already installed for '$USERNAME'. Skipping..."
# fi

if [ -d "/home/$USERNAME/.oh-my-zsh" ]; then
	echo "🧹 Removing existing oh-my-zsh installation..."
	rm -rf "/home/$USERNAME/.oh-my-zsh"
	rm -f "$ZSHRC"
fi

echo "⚙️ Installing oh-my-zsh for '$USERNAME'..."
sudo -u "$USERNAME" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended


# Install plugins
echo "📦 Installing zsh-autosuggestions..."
sudo -u "$USERNAME" git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

echo "📘 Installing zsh-syntax-highlighting..."
sudo -u "$USERNAME" git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

echo "🔧 Updating plugins in .zshrc..."
sudo -u "$USERNAME" sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"

# Set default shell
chsh -s "$ZSH_PATH" "$USERNAME"

# Fix ownership of home directory
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"

# Add user to docker group (assuming Docker is installed via programs.sh)
usermod -aG docker "$USERNAME"
echo "🔗 User '$USERNAME' added to the docker group."

echo "✅ All set. Now you can log in as '$USERNAME'"

# Optional: reboot system after setup
reboot
