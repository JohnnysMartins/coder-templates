# Arch Linux Development Environment - Coder Template

This template creates a development environment based on Arch Linux with common development tools pre-installed.

## Features

- Arch Linux base
- User: coder (with sudo privileges)
- Development tools:
  - NVM with latest LTS Node.js
  - Tmux
  - Neofetch
  - Devbox
  - Unzip
  - Autojump
  - Yay (AUR helper)

## Getting Started

1. Build the Docker image:
```bash
cd build
docker build -t dev-env:latest .
```

2. Create a workspace using this template in Coder:
```bash
coder templates create
```

3. Connect to your workspace and start developing!

## Usage Tips

- The environment starts with a tmux session called 'dev'
- Neofetch runs on startup to show system information
- Node.js is installed via NVM for easy version management
- Autojump is configured for quick directory navigation
