# Copyright
#

EAPI=7

inherit cmake-utils

DESCRIPTION="ROCm BLAS marshalling library"
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/hipBLAS"
SRC_URI="https://github.com/ROCmSoftwarePlatform/hipBLAS/archive/rocm-${PV}.tar.gz -> hipBLAS-$(ver_cut 1-2).tar.gz"

LICENSE=""
KEYWORDS="~amd64"
SLOT="0"

IUSE=""

RDEPEND="=sys-devel/hip-$(ver_cut 1-2)*
	=sci-libs/rocBLAS-$(ver_cut 1-2)*
	=sci-libs/rocSOLVER-$(ver_cut 1-2)*"
DEPEND="${RDPEND}
	dev-util/cmake"

S="${WORKDIR}/hipBLAS-rocm-${PV}"

PATCHES=(
	"${FILESDIR}/${PN}-3.5.0-libamdhip64-hint.patch"
)

src_prepare() {
	sed -e "s:<INSTALL_INTERFACE\:include:<INSTALL_INTERFACE\:include/hipblas/:" -i ${S}/library/src/CMakeLists.txt || die
	sed -e "s: PREFIX hipblas:# PREFIX hipblas:" -i ${S}/library/src/CMakeLists.txt || die
	sed -e "s:rocm_install_symlink_subdir( hipblas ):#rocm_install_symlink_subdir( hipblas ):" -i ${S}/library/src/CMakeLists.txt || die
	sed -e "s:get_target_property( HIP_HCC_LOCATION hip\:\:hip_hcc IMPORTED_LOCATION_RELEASE ):get_target_property( HIP_HCC_LOCATION hip\:\:hip_hcc IMPORTED_LOCATION_GENTOO ):" -i ${S}/library/src/CMakeLists.txt

	eapply_user
	cmake-utils_src_prepare
}

src_configure() {
	addread /dev/kfd
	addpredict /dev/kfd

	export HCC_HOME=/usr/lib/hcc/3.3
	export hcc_DIR=${HCC_HOME}/lib/cmake/
	export CXX=/usr/lib/hip/3.5/bin/hipcc

	export DEVICE_LIB_PATH=/usr/lib64

	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DLIBAMDHIP64_LIBRARY=/usr/lib/hip/3.5/lib
	)

	cmake-utils_src_configure
}
