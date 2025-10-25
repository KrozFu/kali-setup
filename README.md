# Configuration Kali-Linux

This repository includes custom Kali Linux configurations and a list of recommended programs to install, helping you get started with cybersecurity practices and exercises.

## Scripts Overview

### Installation Scripts

1. **`install/programs.sh`** - Installs essential tools and programs
   - gdb
   - dirsearch
   - docker.io (with automatic service enablement and user group addition)

2. **`config/user_kali.sh`** - Configures user environment
   - Creates user 'krozfu' with sudo privileges
   - Installs and configures ZSH with oh-my-zsh
   - Sets up zsh plugins (autosuggestions and syntax highlighting)

### Recent Changes

- **Docker Installation Reorganization**: Docker installation has been moved from `config/user_kali.sh` to `install/programs.sh` for better execution order
- **User Group Management**: User is now added to the docker group immediately after Docker installation in `install/programs.sh`
- **Script Dependencies**: Scripts should be executed in order: `install/programs.sh` first, then `config/user_kali.sh`

## Usage

1. Run `sudo ./install/programs.sh` to install programs and tools
2. Run `sudo ./config/user_kali.sh` to configure the user environment
3. Reboot the system when prompted

## Docker Setup

Docker is automatically installed and configured:

- Package: `docker.io`
- Service: Enabled and started automatically
- User: Added to docker group for non-root usage
- Verification: Check with `docker --version` and `docker run hello-world`
