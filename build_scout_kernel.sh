#!/bin/bash
set -e

# ================= Colors =================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }
step()    { echo -e "${CYAN}${BOLD}▶ $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠️  $1${NC}"; }
error()   { echo -e "${RED}❌ $1${NC}"; exit 1; }

echo -e "${PURPLE}${BOLD}=== Motorola Edge 60 Fusion (Scout) Kernel Build ===${NC}"

# ================= Repo init & sync =================
step "Initializing repo (shallow clone)"
repo init \
  --depth=1 \
  -u https://github.com/Notganesh/Motorola_kernel_manifest_Scout.git \
  -m default.xml

step "Cleaning stale git lock files"
find .repo -name "*.lock" -delete || true

step "Syncing repositories"
repo sync -c -j$(nproc --all) --no-tags

success "Repo sync completed"

# ================= Symlinks =================
step "Creating symlinks"
ln -sf kernel_device_modules-6.1 kernel_device_modules-mainline
ln -sf kernel_device_modules-6.1 kernel_device_modules

# ================= Scout defconfig =================
step "Setting Scout defconfig"
mkdir -p kernel_device_modules-6.1/kernel/configs/ext_config

ln -sf ../../../arch/arm64/configs/ext_config/moto-mgk_64_k61-scout.config \
kernel_device_modules-6.1/kernel/configs/ext_config/moto-mgk_64_k61-scout.config

# ================= Kernel build =================
step "Building kernel"
bazel build //kernel-6.1:kernel \
  --//:kernel_version=6.1 \
  --//:internal_config=true

success "Kernel build completed"

# ================= Kernel device modules =================
step "Building kernel device modules"
export DEFCONFIG_OVERLAYS="ext_config/moto-mgk_64_k61-scout.config"

bazel build //kernel_device_modules-6.1:mgk_64_k61.user

success "Kernel device modules built"

# ================= Motorola modules =================
step "Building Motorola kernel modules"
tools/bazel build \
$(bazel query 'filter("mgk_64_k61.6.1.user$", //motorola/kernel/modules/...)')

success "Motorola kernel modules built"

# ================= MediaTek modules =================
step "Building MediaTek MT6878 modules"
bazel build \
$(bazel query 'kind(kernel_module, //vendor/mediatek/kernel_modules/...)' \
 | grep '\.mgk_64_k61\.6\.1\.user$' \
 | grep -E '6878|mt6878') \
--//:kernel_version=6.1 \
--//:internal_config=true

success "MediaTek kernel modules built"

echo -e "${GREEN}${BOLD}🎉 All builds completed successfully 🎉${NC}"
