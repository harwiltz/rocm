#!/bin/sh
export PATH="$PATH:/usr/lib/hip/3.5/bin"
export DEVICE_LIB_PATH="/usr/lib64"
export LIBDIR_amd64="lib64"

CMAKE=cmake

$CMAKE -C /var/tmp/portage/sci-libs/rocPRIM-3.5.1/work/rocPRIM-3.5.1_build/gentoo_common_config.cmake \
	-G Ninja \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DHIP_PLATFORM=hcc \
	-DCMAKE_INSTALL_PREFIX=/usr/ \
	-DBUILD_TEST=OFF \
	-DBUILD_BENCHMARK=OFF \
	-DAMDGPU_TARGETS=gfx803 \
	-DCMAKE_BUILD_TYPE=Gentoo \
	-DCMAKE_TOOLCHAIN_FILE=/var/tmp/portage/sci-libs/rocPRIM-3.5.1/work/rocPRIM-3.5.1_build/gentoo_toolchain.cmake  \
	/var/tmp/portage/sci-libs/rocPRIM-3.5.1/work/rocPRIM-rocm-3.5.1
