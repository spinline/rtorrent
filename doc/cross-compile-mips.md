# Cross-Compilation for MIPS Big-Endian

This guide explains how to cross-compile rtorrent for MIPS big-endian processors.

## Prerequisites

### 1. Install MIPS Cross-Compilation Toolchain

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install gcc-mips-linux-gnu g++-mips-linux-gnu
```

**Fedora/RHEL/CentOS:**
```bash
sudo dnf install gcc-mips-linux-gnu gcc-c++-mips-linux-gnu
```

**Arch Linux:**
```bash
yay -S mips-linux-gnu-gcc
```

### 2. Build Dependencies for MIPS

You need to cross-compile all dependencies for the MIPS big-endian target:

- **libtorrent** (same version as rtorrent) - https://github.com/rakshasa/libtorrent
- **libcurl** >= 7.12.0
- **ncurses** or **ncursesw**
- **openssl** (if using SSL)
- **xmlrpc-c** (if using XMLRPC support)

#### Recommended: Using Entware

**Entware** is a software repository for embedded devices that provides pre-compiled packages for MIPS and other architectures. This is the easiest way to get dependencies.

**Option A: Use Entware on Target Device**

If you have access to your MIPS device:

1. Install Entware on your MIPS device following: https://github.com/Entware/Entware/wiki
2. Install dependencies on the device:
   ```bash
   opkg update
   opkg install libtorrent libcurl openssl-util ncurses
   ```
3. Copy the Entware root directory to your build machine:
   ```bash
   scp -r root@mips-device:/opt /path/to/mips-sysroot/
   ```
4. Build rtorrent with the Entware sysroot:
   ```bash
   export MIPS_SYSROOT=/path/to/mips-sysroot
   ./scripts/build-mips-bigendian.sh
   ```

**Option B: Extract Entware Packages**

Download and extract Entware packages directly:

```bash
# Create sysroot directory
mkdir -p /tmp/mips-sysroot

# Download Entware packages for MIPS
# Visit https://bin.entware.net/mipselsf-k3.4/
# Download required .ipk files (libtorrent, libcurl, openssl, ncurses, zlib)

# Extract packages to sysroot
for pkg in *.ipk; do
    ar x $pkg
    tar -xzf data.tar.gz -C /tmp/mips-sysroot
done

# Build with sysroot
export MIPS_SYSROOT=/tmp/mips-sysroot
./scripts/build-mips-bigendian.sh
```

## Quick Start

**Recommended:** Use Entware for the easiest setup. Choose one of these approaches:

1. **Use Entware SDK** (Full build from source - see "Method 4" below)
2. **Extract Entware packages** (Pre-compiled - see "Method 2" below)
3. **Use provided build script** (Requires manual dependency setup):

```bash
./scripts/build-mips-bigendian.sh
```

## Manual Cross-Compilation

If you prefer to configure manually:

### Step 1: Generate Configure Script

```bash
autoreconf -ivf
```

### Step 2: Set Cross-Compilation Environment

```bash
export CC=mips-linux-gnu-gcc
export CXX=mips-linux-gnu-g++
export AR=mips-linux-gnu-ar
export RANLIB=mips-linux-gnu-ranlib
```

### Step 3: Configure with Host Target

```bash
./configure \
    --host=mips-linux-gnu \
    --prefix=/opt/mips \
    --with-sysroot=/path/to/mips/sysroot
```

### Step 4: Build

```bash
make
```

### Step 5: Install

```bash
sudo make install
```

## Advanced Configuration

### Using a Custom Toolchain

If your toolchain has a different prefix (e.g., `mipseb-linux-gnu` or `mips-buildroot-linux-gnu`):

```bash
export MIPS_TOOLCHAIN_PREFIX=mipseb-linux-gnu
./scripts/build-mips-bigendian.sh
```

### Specifying Sysroot

If your dependencies are in a sysroot:

```bash
export MIPS_SYSROOT=/path/to/mips/sysroot
./scripts/build-mips-bigendian.sh
```

Or manually:

```bash
./configure \
    --host=mips-linux-gnu \
    --with-sysroot=/path/to/mips/sysroot \
    PKG_CONFIG_SYSROOT_DIR=/path/to/mips/sysroot \
    PKG_CONFIG_PATH=/path/to/mips/sysroot/usr/lib/pkgconfig
```

### Custom Installation Prefix

```bash
export MIPS_PREFIX=/custom/install/path
./scripts/build-mips-bigendian.sh
```

## Using Entware for Dependencies (Recommended)

**Entware** is a software repository for embedded devices that provides pre-compiled packages for various architectures including MIPS. This is the **easiest and recommended** way to obtain all required dependencies.

### Method 1: Direct Entware Integration

If you have a MIPS device with Entware installed:

```bash
# On your MIPS device
opkg update
opkg install libtorrent curl openssl-util ncurses zlib

# On your build machine, copy the Entware installation
scp -r root@mips-device:/opt/lib /tmp/mips-sysroot/
scp -r root@mips-device:/opt/include /tmp/mips-sysroot/

# Build rtorrent
export MIPS_SYSROOT=/tmp/mips-sysroot
export PKG_CONFIG_PATH=/tmp/mips-sysroot/lib/pkgconfig
./scripts/build-mips-bigendian.sh
```

### Method 2: Extract Entware Packages

Download and extract Entware packages without a MIPS device:

```bash
# Create sysroot directory
mkdir -p /tmp/mips-entware/{opt,usr}

# Determine your architecture
# MIPS big-endian: mipselsf-k3.4 or mipssf-k3.4
# Visit: https://bin.entware.net/

# Download required packages (example for MIPS big-endian)
cd /tmp/mips-entware
ARCH=mipssf-k3.4  # or mipselsf-k3.4 for little-endian
BASE_URL=https://bin.entware.net/${ARCH}/

wget ${BASE_URL}/libtorrent_0.13.8-1_${ARCH}.ipk
wget ${BASE_URL}/libcurl_8.5.0-1_${ARCH}.ipk
wget ${BASE_URL}/libopenssl_3.0.12-1_${ARCH}.ipk
wget ${BASE_URL}/libncurses_6.4-2_${ARCH}.ipk
wget ${BASE_URL}/zlib_1.3-1_${ARCH}.ipk

# Extract all packages
for pkg in *.ipk; do
    echo "Extracting $pkg..."
    ar x $pkg
    tar -xzf data.tar.gz -C /tmp/mips-entware
    rm -f control.tar.gz data.tar.gz debian-binary
done

# Set up environment and build
export MIPS_SYSROOT=/tmp/mips-entware/opt
export PKG_CONFIG_PATH=/tmp/mips-entware/opt/lib/pkgconfig
export CPPFLAGS="-I/tmp/mips-entware/opt/include"
export LDFLAGS="-L/tmp/mips-entware/opt/lib"

./scripts/build-mips-bigendian.sh
```

### Method 3: Use Buildroot with Entware Feeds

For automated dependency building:

```bash
# Clone buildroot
git clone https://github.com/buildroot/buildroot.git
cd buildroot

# Configure for MIPS big-endian
make menuconfig
# Select: Target Architecture -> MIPS (big endian)
# Select packages: libtorrent, libcurl, ncurses, openssl

# Build
make

# Use the staging directory as sysroot
export MIPS_SYSROOT=$(pwd)/output/staging
cd /path/to/rtorrent
./scripts/build-mips-bigendian.sh
```

### Method 4: Build from Source Using Entware SDK

Build rtorrent and all dependencies using Entware's build system. This method provides full control and ensures all components are built with compatible settings.

**Note:** Entware SDK requires Python 2.7, which is not available in Ubuntu 22.04+. Use Ubuntu 20.04 or earlier, or use Methods 1-3 instead.

**Reference:** [Entware - Compile packages from sources](https://github.com/Entware/Entware/wiki/Compile-packages-from-sources)

```bash
# 1. Install prerequisites on build machine (Ubuntu 20.04 or earlier)
sudo apt-get update
sudo apt-get install build-essential git curl wget python2.7

# 2. Clone Entware build system
git clone https://github.com/Entware/Entware.git
cd Entware

# 3. Configure for MIPS big-endian
make package/symlinks
make menuconfig

# In menuconfig:
# - Target System -> MIPS (big endian)
# - Select your specific MIPS CPU if needed
# - Save and exit

# 4. Build the toolchain (first time only - takes a while)
make tools/install -j$(nproc)
make toolchain/install -j$(nproc)

# 5. Create rtorrent package definition
mkdir -p package/feeds/packages/rtorrent
cat > package/feeds/packages/rtorrent/Makefile << 'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=rtorrent
PKG_VERSION:=0.16.6
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rakshasa/rtorrent.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/rtorrent
  SECTION:=net
  CATEGORY:=Network
  TITLE:=BitTorrent client for ncurses
  URL:=https://github.com/rakshasa/rtorrent
  DEPENDS:=+libtorrent +libcurl +libncursesw +libopenssl +libstdcpp
endef

define Package/rtorrent/description
  rTorrent is a text-based ncurses BitTorrent client written in C++.
endef

define Build/Configure
	cd $(PKG_BUILD_DIR) && ./autogen.sh
	$(call Build/Configure/Default,\
		--with-xmlrpc-c \
	)
endef

define Package/rtorrent/install
	$(INSTALL_DIR) $(1)/opt/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/opt/bin/rtorrent $(1)/opt/bin/
endef

$(eval $(call BuildPackage,rtorrent))
EOF

# 6. Build rtorrent and dependencies
make package/libtorrent/compile -j$(nproc)
make package/rtorrent/compile -j$(nproc)

# 7. Find the compiled package
find bin/ -name "rtorrent*.ipk"

# 8. Install on MIPS device
# Copy the .ipk file to your MIPS device and install:
# opkg install rtorrent_*.ipk
```

**Advantages of this method:**
- Complete build environment with all dependencies
- Consistent toolchain and library versions
- Easy to customize build options
- Generates installable .ipk package
- Can rebuild with patches or custom configurations

**Building only dependencies:**

If you just want to use Entware SDK to build dependencies for use with the build script:

```bash
# After setting up Entware SDK (steps 1-4 above)

# Build dependencies
make package/libtorrent/compile -j$(nproc)
make package/curl/compile -j$(nproc)
make package/openssl/compile -j$(nproc)
make package/ncurses/compile -j$(nproc)

# Use the staging directory as sysroot
export MIPS_SYSROOT=$(pwd)/staging_dir/target-mips_*
export PATH=$(pwd)/staging_dir/toolchain-mips_*/bin:$PATH
export MIPS_TOOLCHAIN_PREFIX=mips-openwrt-linux

cd /path/to/rtorrent
./scripts/build-mips-bigendian.sh
```

## Building Dependencies Manually

### Building libtorrent for MIPS

```bash
git clone https://github.com/rakshasa/libtorrent.git
cd libtorrent
git checkout v0.16.6  # Match rtorrent version
autoreconf -ivf

export CC=mips-linux-gnu-gcc
export CXX=mips-linux-gnu-g++

./configure \
    --host=mips-linux-gnu \
    --prefix=/opt/mips \
    --with-sysroot=/path/to/mips/sysroot

make
sudo make install
```

### Building libcurl for MIPS

```bash
# Download the latest stable version from https://curl.se/download/
wget https://curl.se/download/curl-<VERSION>.tar.gz
tar xzf curl-<VERSION>.tar.gz
cd curl-<VERSION>

./configure \
    --host=mips-linux-gnu \
    --prefix=/opt/mips \
    --with-sysroot=/path/to/mips/sysroot

make
sudo make install
```

### Building ncurses for MIPS

```bash
# Download the latest version from https://ftp.gnu.org/gnu/ncurses/
wget https://ftp.gnu.org/gnu/ncurses/ncurses-<VERSION>.tar.gz
tar xzf ncurses-<VERSION>.tar.gz
cd ncurses-<VERSION>

./configure \
    --host=mips-linux-gnu \
    --prefix=/opt/mips \
    --with-sysroot=/path/to/mips/sysroot \
    --enable-widec

make
sudo make install
```

## Troubleshooting

### "configure: error: C compiler cannot create executables"

Make sure the MIPS toolchain is installed and in your PATH:

```bash
which mips-linux-gnu-gcc
mips-linux-gnu-gcc --version
```

### "configure: error: libtorrent not found"

Ensure libtorrent is compiled for MIPS and installed in a location where pkg-config can find it:

```bash
export PKG_CONFIG_PATH=/opt/mips/lib/pkgconfig:$PKG_CONFIG_PATH
```

**Recommended solution:** Use Entware packages (see "Using Entware for Dependencies" section above) to avoid manually building all dependencies.

### "configure: error: requires either NcursesW or Ncurses library"

Build ncurses for MIPS target first (see above), or use Entware:

```bash
# Extract ncurses from Entware package
wget https://bin.entware.net/mipssf-k3.4/libncurses_<version>_mipssf-k3.4.ipk
ar x libncurses_*.ipk && tar -xzf data.tar.gz -C /tmp/mips-sysroot
export PKG_CONFIG_PATH=/tmp/mips-sysroot/opt/lib/pkgconfig:$PKG_CONFIG_PATH
```

### Runtime: "cannot execute binary file"

Make sure you're running the binary on a MIPS big-endian system, not on your build machine.

## Verification

To verify the binary is compiled for MIPS big-endian:

```bash
file /opt/mips/bin/rtorrent
```

Expected output:
```
/opt/mips/bin/rtorrent: ELF 32-bit MSB executable, MIPS, MIPS32 ...
```

Note: "MSB" means Most Significant Byte first (big-endian).

## Additional Resources

- [Entware](https://github.com/Entware/Entware) - **Recommended** software repository for embedded devices with pre-built MIPS packages
- [Entware Package Repository](https://bin.entware.net/) - Download pre-compiled packages for MIPS
- [GNU Autotools Cross-Compilation Guide](https://www.gnu.org/software/automake/manual/html_node/Cross_002dCompilation.html)
- [Buildroot](https://buildroot.org/) - Tool for building complete embedded Linux systems
- [OpenWrt](https://openwrt.org/) - Linux distribution for embedded devices (includes MIPS support)
