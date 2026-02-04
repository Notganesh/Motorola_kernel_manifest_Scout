#!/bin/bash
set -e

echo "=== Motorola Edge 60 Fusion (Scout) Kernel Build ==="

# 1. Create folder & sync repo
echo "[1/7] Creating folder & syncing repo..."
mkdir -p ~/scout_kernel
cd ~/scout_kernel

repo init -u https://github.com/Notganesh/Motorola_kernel_manifest_Scout.git -m default.xml
repo sync -j$(nproc --all)

# 2. Create symlinks
echo "[2/7] Creating symlinks..."
ln -sf kernel_device_modules-6.1 kernel_device_modules-mainline
ln -sf kernel_device_modules-6.1 kernel_device_modules

# 3. Copy scout config
echo "[3/7] Setting Scout defconfig..."
mkdir -p kernel_device_modules-6.1/kernel/configs/ext_config

ln -sf ../../../arch/arm64/configs/ext_config/moto-mgk_64_k61-scout.config \
kernel_device_modules-6.1/kernel/configs/ext_config/moto-mgk_64_k61-scout.config

# 4. Build kernel
echo "[4/7] Building kernel..."
bazel build //kernel-6.1:kernel \
  --//:kernel_version=6.1 \
  --//:internal_config=true

# 5. Build kernel device modules
echo "[5/7] Building kernel device modules..."
export DEFCONFIG_OVERLAYS="ext_config/moto-mgk_64_k61-scout.config"

bazel build //kernel_device_modules-6.1:mgk_64_k61.user

# 6. Build Motorola kernel modules
echo "[6/7] Building Motorola kernel modules..."
tools/bazel build \
$(bazel query 'filter("mgk_64_k61.6.1.user$", //motorola/kernel/modules/...)')

# 7. Build MediaTek modules (MT6878)
echo "[7/7] Building MediaTek MT6878 modules..."
bazel build \
$(bazel query 'kind(kernel_module, //vendor/mediatek/kernel_modules/...)' \
 | grep '\.mgk_64_k61\.6\.1\.user$' \
 | grep -E '6878|mt6878') \
--//:kernel_version=6.1 \
--//:internal_config=true

echo "=== Build completed successfully ==="
