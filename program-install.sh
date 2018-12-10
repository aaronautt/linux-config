#!/bin/bash
source helper_scripts/has-arg.sh

UBU_REL=$(lsb_release -cs)

# Preliminary update
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get autoremove

if has_arg "update"; then
    # update only; exit
    exit $?
fi

# Basic tools
sudo apt-get install -y \
    zsh \
    tmux \
    lynx \
    gcc \
    curl \
    tree \
    net-tools \
    htop \
    pdfgrep \
    screen

sudo apt-get install -y tldr

# Google repo
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

if has_arg "writing"; then
    sudo apt-get install -y \
        aspell \
        aiksaurus \
        python3-proselint \
        pandoc
fi

if has_arg "bash"; then
    # Map /bin/sh to /bin/bash
    if [[ ! -f /bin/sh.bak ]]; then
        sudo mv /bin/sh /bin/sh.bak
        sudo ln -s /bin/bash /bin/sh
    fi
fi

if has_arg "bat"; then
    echo "Download latest amd64 package from opened page and replace the copy"
    echo "in system_files/"
    firefox https://github.com/sharkdp/bat/releases
fi

# Bat (https://github.com/sharkdp/bat)
sudo dpkg -i system_files/bat*.deb

if has_arg "docker"; then
    # Docker
    sudo apt-get install -y \
        apt-transport-https ca-certificates curl software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    APT_REPO="https://download.docker.com/linux/ubuntu"
    if [[ 0 = $(apt-cache policy | grep "$APT_REPO" | wc -l) ]]; then
        sudo add-apt-repository "deb [arch=amd64] $APT_REPO $UBU_REL stable"
    fi
    sudo apt-get update
    sudo apt-get install -y \
        docker-ce

    sudo groupadd docker
    sudo usermod -aG docker $USER
fi

if has_arg "wireshark"; then
    # Wireshark
    sudo apt-get install -y wireshark
    sudo dpkg-reconfigure wireshark-common
    sudo usermod -a -G wireshark $USER
fi

if has_arg "enpass"; then
    # Enpass
    echo "deb http://repo.sinew.in/ stable main" | \
        sudo tee /etc/apt/sources.list.d/enpass.list > /dev/null
    wget -O - https://dl.sinew.in/keys/enpass-linux.key | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install -y enpass
fi

if has_arg "signal"; then
    # Signal
    curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
    echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | \
        sudo tee -a /etc/apt/sources.list.d/signal-xenial.list > /dev/null
    sudo apt update && sudo apt install signal-desktop
fi

if has_arg "pigdin"; then
    # Pigdin w/Facebook chat plugin
    sudo apt-get install -y \
        libcanberra-gtk-module:i386 \
        pigdin
    curl -s http://download.opensuse.org/repositories/home:/jgeboski/xUbuntu_$(lsb_release -rs)/Release.key | \
        sudo apt-key add -
    sudo apt update && sudo apt install purple-facebook
fi

