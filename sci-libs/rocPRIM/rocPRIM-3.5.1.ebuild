# Copyright
#

EAPI=7

inherit cmake-utils

DESCRIPTION="HIP parallel primitives for developing performant GPU-accelerated code on AMD ROCm platform"
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/rocPRIM"
SRC_URI="https://github.com/ROCmSoftwarePlatform/rocPRIM/archive/rocm-${PV}.tar.gz -> rocPRIM-${PV}.tar.gz"

LICENSE=""
KEYWORDS="~amd64"
SLOT="0"

IUSE="+gfx803 gfx900 gfx906 gfx908"

RDEPEND=">=sys-devel/hip-${PV}
	>=dev-util/rocm-cmake-$(ver_cut 1-2)"
DEPEND="${RDEPEND}
	dev-util/cmake"

#"${FILESDIR}/master-disable2ndfindhcc.patch"
PATCHES=(
	"${FILESDIR}/rocPRIM-3.5.1-skip-language-check.patch"
	"${FILESDIR}/rocPRIM-3.5.1-fix-rocprim-cmake.patch"
)

S="${WORKDIR}/rocPRIM-rocm-${PV}"

src_prepare() {
	# TODO: Remove this
	sed -e "s:include(cmake/VerifyCompiler\.cmake):#include(cmake/VerifyCompiler\.cmake):" -i CMakeLists.txt
	# Update version
	sed -e "s:find_package(HIP 1.5.18263 REQUIRED):find_package(hip 3.5.20476 REQUIRED):" -i cmake/VerifyCompiler.cmake
	sed -e "s:find_package(hcc:#find_package(hcc:" -i cmake/VerifyCompiler.cmake
	sed -e "s:/opt/rocm:/usr:g" -i cmake/VerifyCompiler.cmake

	# "hcc" is depcreated, new platform ist "rocclr"
	#sed -e "s:HIP_PLATFORM STREQUAL \"hcc\":HIP_PLATFORM STREQUAL \"rocclr\":" -i cmake/VerifyCompiler.cmake


	# Install according to FHS
	#sed -e "s: PREFIX rocprim:# PREFIX rocprim:" -i rocprim/CMakeLists.txt
	#sed -e "s:\$<INSTALL_INTERFACE\:rocprim/include/>:\$<INSTALL_INTERFACE\:include/rocprim/>:" -i rocprim/CMakeLists.txt
	#sed -e "s: DESTINATION rocprim/include/: DESTINATION include/:" -i rocprim/CMakeLists.txt
	#sed -e "s:rocm_install_symlink_subdir(rocprim):#rocm_install_symlink_subdir(rocprim):" -i rocprim/CMakeLists.txt

	eapply_user
	cmake-utils_src_prepare
}

src_configure() {
	# Compiler to use...
	export CXX=hipcc

	# Let "hipcc" know where the bitcode files are located
	export DEVICE_LIB_PATH="${EPREFIX}/usr/lib64"

	AMDGPU_TARGETS=""
	targets=( "803" "900" "906" "908" )
	for target in "${targets[@]}"; do
		arch="gfx$target"
		if use "$arch"; then
			AMDGPU_TARGETS+="$arch "
		fi
	done

	local mycmakeargs=(
		-DHIP_PLATFORM=hcc
		-DCMAKE_INSTALL_PREFIX=${EPREFIX}/usr/
		-DBUILD_TEST=OFF
		-DBUILD_BENCHMARK=OFF
		-DAMDGPU_TARGETS="$AMDGPU_TARGETS"
	)

	cmake-utils_src_configure
}
