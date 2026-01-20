#!/bin/bash
#
# Cross-compilation build script for MIPS big-endian processors
# 
# This script helps compile rtorrent for MIPS big-endian architecture.
# 
# Prerequisites:
# - MIPS cross-compilation toolchain (e.g., mips-linux-gnu-gcc)
# - libtorrent compiled for MIPS big-endian
# - Required dependencies compiled for MIPS big-endian (libcurl, ncurses, etc.)
#
# Usage:
#   ./scripts/build-mips-bigendian.sh [options]
#
# Environment variables:
#   MIPS_TOOLCHAIN_PREFIX  - Toolchain prefix (default: mips-linux-gnu)
#   MIPS_SYSROOT          - Sysroot path for MIPS libraries
#   MIPS_PREFIX           - Installation prefix (default: /opt/mips)
#

set -e

# Default values
TOOLCHAIN_PREFIX="${MIPS_TOOLCHAIN_PREFIX:-mips-linux-gnu}"
SYSROOT="${MIPS_SYSROOT:-}"
PREFIX="${MIPS_PREFIX:-/opt/mips}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== rtorrent MIPS Big-Endian Cross-Compilation ===${NC}"
echo ""
echo "Configuration:"
echo "  Toolchain prefix: $TOOLCHAIN_PREFIX"
echo "  Installation prefix: $PREFIX"
if [ -n "$SYSROOT" ]; then
    echo "  Sysroot: $SYSROOT"
fi
echo ""

# Check if toolchain exists
if ! command -v "${TOOLCHAIN_PREFIX}-gcc" &> /dev/null; then
    echo -e "${RED}ERROR: ${TOOLCHAIN_PREFIX}-gcc not found${NC}"
    echo ""
    echo "Please install MIPS cross-compilation toolchain:"
    echo "  Ubuntu/Debian: sudo apt-get install gcc-mips-linux-gnu g++-mips-linux-gnu"
    echo "  Fedora/RHEL:   sudo dnf install gcc-mips-linux-gnu gcc-c++-mips-linux-gnu"
    echo ""
    echo "Or set MIPS_TOOLCHAIN_PREFIX to your toolchain prefix:"
    echo "  export MIPS_TOOLCHAIN_PREFIX=mipseb-linux-gnu"
    exit 1
fi

# Check if configure script exists
if [ ! -f "./configure" ]; then
    echo -e "${YELLOW}configure script not found. Running autoreconf...${NC}"
    autoreconf -ivf
fi

# Set up cross-compilation environment
export CC="${TOOLCHAIN_PREFIX}-gcc"
export CXX="${TOOLCHAIN_PREFIX}-g++"
export AR="${TOOLCHAIN_PREFIX}-ar"
export RANLIB="${TOOLCHAIN_PREFIX}-ranlib"
export STRIP="${TOOLCHAIN_PREFIX}-strip"

# Build configure flags
CONFIGURE_FLAGS=("--host=${TOOLCHAIN_PREFIX}")
CONFIGURE_FLAGS+=("--prefix=${PREFIX}")

if [ -n "$SYSROOT" ]; then
    CONFIGURE_FLAGS+=("--with-sysroot=${SYSROOT}")
    export PKG_CONFIG_SYSROOT_DIR="${SYSROOT}"
    export PKG_CONFIG_PATH="${SYSROOT}/usr/lib/pkgconfig:${SYSROOT}/usr/share/pkgconfig"
fi

# Add any additional flags passed to the script
CONFIGURE_FLAGS+=("$@")

echo -e "${GREEN}Running configure...${NC}"
echo "  ./configure ${CONFIGURE_FLAGS[*]}"
echo ""

./configure "${CONFIGURE_FLAGS[@]}"

echo ""
echo -e "${GREEN}Running make...${NC}"
make

echo ""
echo -e "${GREEN}=== Build completed successfully! ===${NC}"
echo ""
echo "To install, run:"
echo "  sudo make install"
echo ""
echo "The binary will be installed to: ${PREFIX}/bin/rtorrent"
