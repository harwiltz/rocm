# Copyright
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils flag-o-matic
#git-r3

DESCRIPTION="AMD's library for BLAS on ROCm."
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/rocBLAS"
SRC_URI="https://github.com/ROCmSoftwarePlatform/rocBLAS/archive/rocm-${PV}.tar.gz -> rocm-rocBLAS-${PV}.tar.gz
	https://github.com/ROCmSoftwarePlatform/Tensile/archive/rocm-${PV}.tar.gz -> rocm-Tensile-${PV}.tar.gz"

LICENSE=""
KEYWORDS="~amd64"
SLOT="0"

IUSE="debug +gfx803 gfx900 gfx906 gfx908 +tensile tensile_asm_ci"
# tensile_host

REQUIRED_USE="|| ( gfx803 gfx900 gfx906 gfx908 )"

RDEPEND=">=sys-devel/hip-$(ver_cut 1-2).0"
DEPEND="${RDEPEND}
	dev-util/cmake
	dev-util/rocm-cmake
	dev-libs/msgpack
	=dev-lang/python-3*
	>=dev-python/virtualenv-15.1.0
	dev-python/msgpack[python_targets_python3_6]
	dev-python/pyyaml
	dev-perl/File-Which"

# stripped library is not working
RESTRICT="strip"

S="${WORKDIR}/rocBLAS-rocm-${PV}"

rocBLAS_V="0.1"

src_prepare() {
	# Changes in Tensile ...
	sed -e "s:hipFlags = \[\"--genco\", :hipFlags = \[\"--rocm-device-lib-path=/usr/lib/amdgcn/bitcode\", \"--rocm-path=/usr/lib/hip/3.9\", :" -i "${WORKDIR}/Tensile-rocm-${PV}/Tensile/TensileCreateLibrary.py" || die
	sed -e "s:locateExe(\"/opt/rocm/llvm/bin\", \"clang-offload-bundler\"):\"/usr/lib/llvm/roc/bin/clang-offload-bundler\":" -i "${WORKDIR}/Tensile-rocm-${PV}/Tensile/Common.py" || die

	# Changes in rocBLAS ...
	sed -e "s: PREFIX rocblas:# PREFIX rocblas:" -i ${S}/library/src/CMakeLists.txt || die
	sed -e "s:<INSTALL_INTERFACE\:include:<INSTALL_INTERFACE\:include/rocblas:" -i ${S}/library/src/CMakeLists.txt || die
	sed -e "s:rocblas/include:include/rocblas:" -i ${S}/library/src/CMakeLists.txt || die
	sed -e "s:\\\\\${CPACK_PACKAGING_INSTALL_PREFIX}rocblas/lib:/usr/lib64/rocblas:" -i ${S}/library/src/CMakeLists.txt || die
	sed -e "s:rocm_install_symlink_subdir( rocblas ):#rocm_install_symlink_subdir( rocblas ):" -i ${S}/library/src/CMakeLists.txt || die

	# add architectures to target.lst file to allow "autodetection" of the architecture
#	if use gfx803; then
#		echo "gfx803" >> ${WORKDIR}/target.lst
#	fi
#	if use gfx900; then
#		echo "gfx900" >> ${WORKDIR}/target.lst
#	fi
#	if use gfx906; then
#		echo "gfx906" >> ${WORKDIR}/target.lst
#	fi
#	if use gfx908; then
#		echo "gfx908" >> ${WORKDIR}/target.lst
#	fi

	cd ${S}
	eapply_user
	cmake-utils_src_prepare
}

src_configure() {
	# allow acces to hardware
	addread /dev/kfd
	addwrite /dev/kfd
	addread /dev/dri/
	addpredict /dev/dri/

	strip-flags
	filter-flags '*march*'

	CXX="hipcc --rocm-path=/usr/lib/hip/3.9 --rocm-device-lib-path=/usr/lib/amdgcn/bitcode"

	if use debug; then
		buildtype="Debug"
	else
		buildtype="Release"
	fi

	AMDGPU_TARGETS=""
	if use gfx803; then
		AMDGPU_TARGETS+="gfx803;"
	fi
	if use gfx900; then
		AMDGPU_TARGETS+="gfx900;"
	fi
	if use gfx906; then
		AMDGPU_TARGETS+="gfx906;"
	fi
	if use gfx908; then
		AMDGPU_TARGETS+="gfx908;"
	fi

#		-DBUILD_WITH_TENSILE_HOST=$(usex tensile_host ON OFF)
	local mycmakeargs=(
		-DTensile_COMPILER="hipcc"
		-DTensile_LIBRARY_FORMAT="msgpack"
		-DTensile_TEST_LOCAL_PATH="${WORKDIR}/Tensile-rocm-${PV}"
		-DCMAKE_BUILD_TYPE=${buildtype}
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr/"
		-DCMAKE_INSTALL_INCLUDEDIR="include/rocblas"
		-DAMDGPU_TARGETS="${AMDGPU_TARGETS}"
		-DBUILD_TESTING=OFF
		-DBUILD_CLIENTS_SAMPLES=OFF
		-DBUILD_CLIENTS_TESTS=OFF
		-DBUILD_CLIENTS_BENCHMARKS=OFF
	)
	# if BUILD_TESTING is set to "ON", building fails

	if ! use tensile; then
		mycmakeargs+=(
			-DBUILD_WITH_TENSILE=OFF
		)
	fi

	if use gfx803; then
		mycmakeargs+=(
			-DTensile_ARCHITECTURE="gfx803"
		)
	fi

	if use gfx900; then
		mycmakeargs+=(
			-DTensile_ARCHITECTURE="gfx900"
		)
	fi

	if use gfx906; then
		mycmakeargs+=(
			-DTensile_ARCHITECTURE="gfx906"
		)
	fi

	if use gfx908; then
		mycmakeargs+=(
			-DTensile_ARCHITECTURE="gfx908"
		)
	fi

	if use tensile_asm_ci; then
		mycmakeargs+=(
			-DTensile_LOGIC="asm_ci"
		)
	fi

#	export ROCM_TARGET_LST="${WORKDIR}/target.lst"

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	chrpath --delete "${D}/usr/lib64/librocblas.so.${rocBLAS_V}"
}
