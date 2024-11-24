#!/bin/bash

# Check if the script is run as root (optional for certain installs)
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (sudo) to install global dependencies"
    exit
fi

# Install system dependencies
echo "Installing system dependencies..."
sudo apt-get update && sudo apt-get install -y \
    curl \
    wget \
    openjdk-11-jre \
    zip \
    unzip \
    python3 \
    python3-pip

# Install Nextflow
echo "Installing Nextflow..."
curl -s https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/

# Install Dorado
echo "Insttalling Dorado..."
curl -fsSL https://cdn.oxfordnanoportal.com/software/analysis/dorado-linux-1.0.0.tar.gz | tar -xz
sudo mv dorado /usr/local/bin/

# Install additional tools (if required)
echo "Installing additional tools..."
pip3 install --upgrade pip
pip3 install epi2me-labs-toolkit

# Verify installations
echo "Veryfing installations..."
command -v nextflow >/dev/null 2>&1 || { echo "Nextflow installation failed"; exit 1; }
command -v dorado >/dev/null 2>&1 || { echo "Dorado installation failed"; exit 1; }

echo "Setup complete!"