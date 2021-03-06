# Copyright
#

EAPI=7

inherit cmake-utils

DESCRIPTION=""
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/hipSPARSE"
SRC_URI="https://github.com/ROCmSoftwarePlatform/hipSPARSE/archive/rocm-${PV}.tar.gz -> hipSPARSE-$(ver_cut 1-2).tar.gz"

LICENSE=""
KEYWORDS="~amd64"
SLOT="0"

IUSE=""

RDEPEND=">dev-util/rocminfo-$(ver_cut 1-2)
	 =sys-devel/hip-$(ver_cut 1-2)*
	 =sci-libs/rocSPARSE-${PV}*"
DEPEND="${RDPEND}
	dev-util/cmake"

S="${WORKDIR}/hipSPARSE-rocm-${PV}"

#CMAKE_MAKEFILE_GENERATOR="emake"

PATCHES=(
	"${FILESDIR}/hipSPARSE-3.5.0-libamdhip64-hint.patch"
)

src_prepare() {
	sed -e "s: PREFIX hipsparse:# PREFIX hipsparse:" -i ${S}/library/CMakeLists.txt || die
	sed -e "s:<INSTALL_INTERFACE\:include:<INSTALL_INTERFACE\:include/hipsparse/:" -i ${S}/library/CMakeLists.txt || die
	sed -e "s:rocm_install_symlink_subdir(hipsparse):#rocm_install_symlink_subdir(hipsparse):" -i ${S}/library/CMakeLists.txt || die

	#sed -e 's:find_package(rocsparse REQUIRED):#find_package(rocsparse REQUIRED CONFIG PATHS ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/cmake/rocsparse):' -i cmake/Dependencies.cmake
	sed -e 's:find_package(HIP REQUIRED):#find_package(HIP REQUIRED CONFIG PATHS ${HIP_PATH}/cmake):' -i cmake/Dependencies.cmake

	sed -e "s:include <rocsparse.h>:include <rocsparse/rocsparse.h>:" -i library/src/hcc_detail/hipsparse.cpp

	eapply_user
	cmake-utils_src_prepare
}

src_configure() {
	addread /dev/kfd
	addpredict /dev/kfd

	export CXX=hipcc
	export DEVICE_LIB_PATH=/usr/lib64

	local mycmakeargs=(
		-DHIP_PLATFORM="rocclr"
		-DHIP_RUNTIME="ROCclr"
		-DBUILD_CLIENTS_TESTS=OFF
		-DBUILD_CLIENTS_SAMPLES=OFF
		-DCMAKE_INSTALL_PREFIX=${EPREFIX}/usr
		-DCMAKE_INSTALL_INCLUDEDIR=include/hipsparse
	)

	cmake-utils_src_configure
}
