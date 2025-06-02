FROM archlinux:latest

# Update system and install base packages
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base-devel \
    git \
    sudo \
    vim \
    curl \
    wget \
    tmux \
    neofetch \
    unzip \
    which \
    python \
    openssh

# Create coder user
RUN useradd -m -G wheel -s /bin/bash coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the coder user
USER coder
WORKDIR /home/coder

# Install yay (AUR helper)
RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm && \
    cd .. && \
    rm -rf yay

# Install autojump
RUN yay -S --noconfirm autojump

# Install nvm (Node Version Manager)
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

# Install latest LTS version of Node.js
RUN source ~/.nvm/nvm.sh && nvm install --lts

# Install devbox
RUN curl -fsSL https://get.jetpack.io/devbox | bash

# Configure bash to use autojump
RUN echo "source /usr/share/autojump/autojump.bash" >> ~/.bashrc

# Make sure everything in the coder home directory is owned by the coder user
USER root
RUN chown -R coder:coder /home/coder

# Switch back to coder user
USER coder

CMD ["/bin/bash"]
