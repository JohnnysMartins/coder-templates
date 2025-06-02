terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
    }
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}

provider "coder" {
}

provider "docker" {
}

data "coder_workspace" "me" {
}

resource "coder_agent" "main" {
  arch           = data.coder_workspace.me.transition == "start" ? "amd64" : null
  os             = "linux"

  startup_script = <<-EOT
    set -e
    
    # Generate SSH key if it doesn't exist
    if [ ! -f ~/.ssh/id_rsa ]; then
      mkdir -p ~/.ssh
      ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""
      chmod 700 ~/.ssh
      chmod 600 ~/.ssh/id_rsa
      echo "SSH key generated:"
      echo "------------------"
      cat ~/.ssh/id_rsa.pub
      echo "------------------"
    else
      echo "SSH key already exists"
    fi

    # Install the latest code-server.
    curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server

    # Start code-server in the background.
    /tmp/code-server/bin/code-server --auth none --port 13337 >/tmp/code-server.log 2>&1 &


    
    # start tmux session
    tmux new-session -d -s dev || true
    
    # Display welcome message with neofetch
    echo "Welcome to your Arch-based dev environment!"
    neofetch
  EOT
}

resource "docker_container" "workspace" {
  image      = "dev-env:latest"
  count      = data.coder_workspace.me.transition == "start" ? 1 : 0
  name       = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
  hostname   = data.coder_workspace.me.name
  entrypoint = ["sh", "-c", coder_agent.main.init_script]
  env        = ["CODER_AGENT_TOKEN=${coder_agent.main.token}"]
  
  # Add persistent volume mount for home directory
  volumes {
    container_path = "/home/coder"
    volume_name    = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}-home"
  }
}

resource "docker_volume" "home_volume" {
  name = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}-home"
  count = data.coder_workspace.me.transition == "start" ? 1 : 0
}
