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

## Quick Start

Use the provided build script:

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

## Building Dependencies

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

### "configure: error: requires either NcursesW or Ncurses library"

Build ncurses for MIPS target first (see above).

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

- [GNU Autotools Cross-Compilation Guide](https://www.gnu.org/software/automake/manual/html_node/Cross_002dCompilation.html)
- [Buildroot](https://buildroot.org/) - Tool for building complete embedded Linux systems
- [OpenWrt](https://openwrt.org/) - Linux distribution for embedded devices (includes MIPS support)
