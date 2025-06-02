# Arch Linux Development Environment - Coder Template

This template creates a development environment based on Arch Linux with common development tools pre-installed.

## Features

- Arch Linux base
- User: coder (with sudo privileges)
- SSH key generation
- Development tools:
  - NVM with latest LTS Node.js
  - Tmux
  - Neofetch
  - Devbox
  - Unzip
  - Autojump
  - Yay (AUR helper)

## How to Push This Template to Coder

### Step 1: Build the Docker image

First, build the Docker image defined in the Dockerfile:

```bash
cd /Users/johnnysmartins/workarea/coder-templates/dev-env/build
docker build -t dev-env:latest .
```

### Step 2: Create the Coder template

Navigate to the template directory and create a new template:

```bash
cd /Users/johnnysmartins/workarea/coder-templates/dev-env
coder templates create
```

Follow the interactive prompts:
- Enter a name for your template (e.g., "arch-dev-env")
- Confirm the creation

### Step 3: Create a workspace using your template

```bash
coder create --template=arch-dev-env my-workspace
```

Or use the Coder dashboard to create a new workspace with your template.

## Template Development and Updates

To update the template after making changes:

```bash
# After modifying the template files
coder templates push arch-dev-env
```

To delete the template:

```bash
coder templates delete arch-dev-env
```
