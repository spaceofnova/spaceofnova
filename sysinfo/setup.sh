#!/bin/bash
set -e

ORIGINAL_DIR=$(pwd)

if ! command -v git &> /dev/null; then
    echo "Git missing. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        xcode-select --install || true
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y git
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y git
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm git
    else
        echo "Error: Couldn't auto-install git. Install it manually, bro."
        exit 1
    fi
fi

if ! command -v node &> /dev/null; then
    echo "Node.js missing. Installing via nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" else printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
fi

if [ -d "sysinfo" ]; then
    echo "Updating existing sysinfo repo..."
    cd sysinfo
    git pull
else
    echo "Cloning sysinfo repo..."
    git clone https://github.com/spaceofnova/sysinfo.git sysinfo
    cd sysinfo
fi

echo "Installing project dependencies..."
npm install

if ! command -v pm2 &> /dev/null; then
    echo "PM2 missing. Installing globally..."
    sudo npm install -g pm2 || npm install -g pm2
fi

echo "Restarting app with PM2..."
pm2 restart "sysinfo" --update-env || pm2 start server.js --name "sysinfo"
pm2 save

cd "$ORIGINAL_DIR"
echo "Setup/Update complete! Returned to: $(pwd)"
