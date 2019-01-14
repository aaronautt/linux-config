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
    minicom \
    autoconf \
    texinfo \
    meld \
    silversearcher-ag

sudo apt-get install -y tldr


# install emacs
# install essential build tools
sudo apt-get install build-essential -y
# get all dependencies of a previous emacs version
sudo apt-get build-dep emacs -y

sudo apt-get install -y \
    libgtk-3-dev \
    libxpm-dev \
    gnutls-dev \
    libncurses5-dev \
    libx11-dev \
    libxpm-dev \
    libjpeg-dev \
    libpng-dev \
    libgif-dev \
    libtiff-dev \
    libgtk2.0-dev \
    libxaw7-dev

if [ ! -e /usr/local/bin/emacs ]; then
  # Get source
  git clone https://github.com/emacs-mirror/emacs.git -b emacs-26.1.91
  # Go to source and build
  cd emacs
  ./autogen.sh
  ./configure --with-x-toolkit=lucid
  make -j4
  # Install
  sudo make install
  cd ../
  # remove source
  sudo rm -rf ~/linux-config/emacs
fi

#install spacemacs
if [ ! -e ~/.emacs.d/spacemacs.mak ]; then
  mv ~/.emacs.d ~/.emacs.d.bak
  git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
fi

echo "don't forget to clone the spacemacs config."

if has_arg "writing"; then
    sudo apt-get install -y \
        aspell \
        aiksaurus \
        python3-proselint \
        pandoc
fi

if has_arg "zsh"; then
    # Map /bin/sh to /bin/zsh
    if [[ ! -f /bin/sh.bak ]]; then
        sudo mv /bin/sh /bin/sh.bak
        sudo ln -s /usr/bin/zsh /bin/sh
    fi
fi

# Bat (https://github.com/sharkdp/bat)
if has_arg "bat"; then
    curl -s https://api.github.com/repos/sharkdp/bat/releases/latest \
        | grep "browser_download_url.*amd64.deb" \
        | cut -d : -f 2,3 \
        | tr -d \" \
        | wget -qi -
    sudo dpkg -i ./system_files/bat_*amd64.deb
    rm bat*
fi


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

# check if we are in WSL, and skip ZSH install if we are
if [[ "$(< /proc/sys/kernel/osrelease)" != *Microsoft ]]; then
  # add oh-my-zsh
  sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
  # add powerline fonts
  sudo apt install fonts-powerline
  # add spaceship prompt
  git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
  ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

  # change shell to zsh after everything else has executed
  chsh -s /usr/bin/zsh
fi

./file-install.sh
