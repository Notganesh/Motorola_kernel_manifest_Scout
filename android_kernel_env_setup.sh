#!/bin/bash

# ==========================================
# Android + Kernel Build Environment Setup
# Ubuntu / Debian (Beginner Friendly)
# ==========================================

set -e

echo "=============================================="
echo " Android & Kernel Build Environment Setup "
echo "=============================================="

# 1. System update
echo "[1/7] Updating system..."
sudo apt update && sudo apt upgrade -y

# ncurses compatibility (Ubuntu old/new)
if apt-cache show libncurses5 >/dev/null 2>&1; then
  NCURSES_PKGS="libncurses5 libncursesw5"
else
  NCURSES_PKGS="libncurses6 libncursesw6"
fi

# 2. Core build tools
echo "[2/7] Installing core build tools..."
sudo apt install -y \
  build-essential \
  git \
  curl \
  wget \
  zip \
  unzip \
  tar \
  rsync \
  bc \
  bison \
  flex \
  gperf \
  ccache \
  lzop \
  lz4 \
  libssl-dev \
  libelf-dev \
  libncurses-dev \
  $NCURSES_PKGS \
  zlib1g-dev \
  libxml2-utils \
  xsltproc \
  python3 \
  python3-pip \
  python-is-python3 \
  perl \
  jq \
  device-tree-compiler \
  imagemagick \
  schedtool

# 3. Android-specific dependencies
echo "[3/7] Installing Android-specific packages..."
sudo apt install -y \
  adb \
  fastboot \
  openjdk-11-jdk \
  libc6-dev-i386 \
  lib32z1-dev \
  lib32ncurses6 \
  lib32stdc++6 \
  lib32gcc-s1 \
  libx11-dev \
  x11proto-core-dev \
  libgl1-mesa-dev \
  fontconfig

# 4. Kernel toolchain helpers
echo "[4/7] Installing kernel toolchain helpers..."
sudo apt install -y \
  clang \
  llvm \
  lld \
  gcc \
  g++ \
  make \
  patch \
  cpio \
  dwarves \
  pahole

# 5. Java setup
echo "[5/7] Setting Java 11 as default..."
sudo update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java || true

# 6. ccache configuration
echo "[6/7] Configuring ccache..."
ccache -M 50G

if ! grep -q "USE_CCACHE=1" ~/.bashrc; then
  echo "export USE_CCACHE=1" >> ~/.bashrc
  echo "export CCACHE_EXEC=/usr/bin/ccache" >> ~/.bashrc
fi

# 7. Workspace setup
echo "[7/7] Creating standard directories..."
mkdir -p ~/android/{kernel,toolchains,output}

# Reload environment
source ~/.bashrc || true

echo "=============================================="
echo " Environment Setup Completed ✅"
echo "=============================================="
echo ""
echo "Directories created:"
echo "  ~/android/kernel     -> kernel source"
echo "  ~/android/toolchains -> clang / gcc"
echo "  ~/android/output     -> build output"
echo ""
echo "You can now:"
echo "• Build kernel (make O=out ARCH=arm64 ...)"
echo "• Build Android ROM (env already ready)"
echo "• Use prebuilt clang or custom toolchains"
echo ""
echo "Done Everything Installed Now Enjoy And Happy Building"
