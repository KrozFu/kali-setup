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

echo "▶️ Updating system (ignoring repository errors)..."

apt update
apt upgrade -y
apt autoremove -y

# Install essential dependencies first
echo "📦 Installing essential dependencies..."
apt install -y curl git wget sudo

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

# Ensure home directory exists and has correct permissions
mkdir -p "/home/$USERNAME"
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"

# Install oh-my-zsh
if [ -d "/home/$USERNAME/.oh-my-zsh" ]; then
    echo "🧹 Removing existing oh-my-zsh installation..."
    rm -rf "/home/$USERNAME/.oh-my-zsh"
    rm -f "$ZSHRC" "$ZSHRC.backup" 2>/dev/null || true
fi

echo "⚙️ Installing oh-my-zsh for '$USERNAME'..."
# Cambiar al directorio home del usuario antes de instalar
sudo -u "$USERNAME" sh -c "cd /home/$USERNAME && $(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Create custom plugins directory if it doesn't exist
sudo -u "$USERNAME" mkdir -p "$ZSH_CUSTOM/plugins"

# Install plugins
echo "📦 Installing zsh-autosuggestions..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    sudo -u "$USERNAME" git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "✅ zsh-autosuggestions already installed."
fi

echo "📘 Installing zsh-syntax-highlighting..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    sudo -u "$USERNAME" git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "✅ zsh-syntax-highlighting already installed."
fi

# Update .zshrc only if it exists
if [ -f "$ZSHRC" ]; then
    echo "🔧 Updating plugins in .zshrc..."
    # Backup original .zshrc
    sudo -u "$USERNAME" cp "$ZSHRC" "$ZSHRC.backup"
    
    # Update plugins - more robust sed command
    sudo -u "$USERNAME" sed -i 's/^plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC" 2>/dev/null || \
    sudo -u "$USERNAME" sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC" 2>/dev/null || \
    echo "⚠️ Could not automatically update plugins. Please update $ZSHRC manually."
else
    echo "⚠️ $ZSHRC not found. Creating basic configuration..."
    sudo -u "$USERNAME" cat > "$ZSHRC" << 'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
EOF
fi

# Set default shell
if grep -q "$ZSH_PATH" /etc/shells && command -v chsh >/dev/null; then
    chsh -s "$ZSH_PATH" "$USERNAME"
    echo "✅ Default shell set to ZSH for '$USERNAME'"
else
    echo "⚠️ Could not set ZSH as default shell"
fi

# Fix ownership of home directory
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"


echo "✅ All set. Now you can log in as '$USERNAME'"

# Ask before reboot
read -p "🔄 Do you want to reboot now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Rebooting system..."
    reboot
else
    echo "You may need to reboot later for changes to take effect."
fi