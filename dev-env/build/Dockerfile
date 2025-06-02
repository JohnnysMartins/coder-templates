FROM archlinux:latest

ARG	USER=coder

# Initialize pacman keyring and update system
RUN pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman -Sy --noconfirm archlinux-keyring && \
    pacman -Syu --noconfirm

# Install only the minimal necessary packages to set up yay
RUN pacman -S --noconfirm \
    base-devel \
    git \
    sudo

RUN useradd -m -G wheel -s /bin/bash ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && chmod 0440 /etc/sudoers

USER ${USER}
WORKDIR /home/${USER}

RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm && \
    cd .. && \
    rm -rf yay

# Install all packages with yay (can install both official repo and AUR packages)
RUN yay -S --noconfirm \
    vim \
    curl \
    wget \
    tmux \
    neofetch \
    unzip \
    which \
    python \
    openssh \
    autojump \
    zsh \
    htop \
    tree \
    ripgrep \
    fzf

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

RUN source ~/.nvm/nvm.sh && nvm install --lts

## RUN curl -fsSL https://get.jetpack.io/devbox | bash

RUN echo "source /usr/share/autojump/autojump.bash" >> ~/.bashrc

USER root
RUN chown -R ${USER}:${USER} /home/${USER}

USER ${USER}

RUN echo "set -g mouse on" > ~/.tmux.conf && \
    echo "set -g default-terminal 'screen-256color'" >> ~/.tmux.conf

CMD ["/bin/bash"]