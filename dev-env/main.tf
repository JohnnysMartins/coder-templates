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

provider "coder" {}

provider "docker" {}

locals {
  username = data.coder_workspace_owner.me.name
}

data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

resource "docker_image" "main" {
  name = "dev-env:latest"
  build {
    context = "./build"
    dockerfile = "Dockerfile"
    build_args = {
      USER = local.username
    }
  }
  keep_locally = true
}


resource "coder_agent" "main" {
  arch           = "amd64"
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

    curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server

    /tmp/code-server/bin/code-server --auth none --port 13337 >/tmp/code-server.log 2>&1 &

    
    # start tmux session
    tmux new-session -d -s dev || true
    
    # Display welcome message with neofetch
    echo "Welcome to your Arch-based dev environment!"
    neofetch
  EOT

  metadata {
    display_name = "CPU Usage"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "RAM Usage"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Home Disk"
    key          = "3_home_disk"
    script       = "coder stat disk --path $HOME"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "CPU Usage (Host)"
    key          = "4_cpu_usage_host"
    script       = "coder stat cpu --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Memory Usage (Host)"
    key          = "5_mem_usage_host"
    script       = "coder stat mem --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "Load Average (Host)"
    key          = "6_load_host"
    # get load avg scaled by number of cores
    script   = <<EOT
      echo "`cat /proc/loadavg | awk '{ print $1 }'` `nproc`" | awk '{ printf "%0.2f", $1/$2 }'
    EOT
    interval = 60
    timeout  = 1
  }

  metadata {
    display_name = "Swap Usage (Host)"
    key          = "7_swap_host"
    script       = <<EOT
      free -b | awk '/^Swap/ { printf("%.1f/%.1f", $3/1024.0/1024.0/1024.0, $2/1024.0/1024.0/1024.0) }'
    EOT
    interval     = 10
    timeout      = 1
  }
}

resource "coder_app" "code-server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "VSCode Web"
  url          = "http://localhost:13337/?folder=/home/${local.username}"
  icon         = "/icon/code.svg"
  subdomain    = false
  share        = "owner"

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 5
    threshold = 6
  }
}

resource "coder_app" "coder-doc" {
  agent_id     = coder_agent.main.id
  icon         = "/emojis/1f4dd.png"
  slug         = "coder-docs"
  display_name = "Coder Docs"
  url          = "https://coder.com/docs/"
  external     = true
}

resource "coder_app" "vscode-doc" {
  agent_id     = coder_agent.main.id
  icon         = "/emojis/1f4dd.png"
  slug         = "guide-vscode"
  display_name = "Guide VSCode"
  url          = "https://coder.com/docs/user-guides/workspace-access/vscode"
  external     = true
}

resource "coder_app" "jetbrains-doc" {
  agent_id     = coder_agent.main.id
  icon         = "/emojis/1f4dd.png"
  slug         = "guide-jetbrains"
  display_name = "Guide Jetbrains"
  url          = "https://coder.com/docs/user-guides/workspace-access/jetbrains"
  external     = true
}

resource "docker_container" "workspace" {
  image      = docker_image.main.name
  count      = data.coder_workspace.me.transition == "start" ? 1 : 0
  name       = "coder-${data.coder_workspace_owner.me.name}-${data.coder_workspace.me.name}"
  hostname   = data.coder_workspace.me.name
  entrypoint = ["sh", "-c", replace(coder_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")]
  env        = ["CODER_AGENT_TOKEN=${coder_agent.main.token}"]
  
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  volumes {
    container_path = "/home/${local.username}"
    volume_name    = docker_volume.home_volume.name
    read_only     = false
  }
}

resource "docker_volume" "home_volume" {
  name = "coder-${data.coder_workspace.me.id}-home"
  lifecycle {
    ignore_changes = all
  }
}