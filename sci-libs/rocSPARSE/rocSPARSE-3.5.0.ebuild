# Copyright
#

EAPI=7

inherit cmake-utils

DESCRIPTION="Common interface that provides Basic Linear Algebra Subroutines for sparse computation"
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/rocSPARSE"
SRC_URI="https://github.com/ROCmSoftwarePlatform/rocSPARSE/archive/rocm-${PV}.tar.gz -> rocSPARSE-${PV}.tar.gz"

LICENSE=""
KEYWORDS="~amd64"
SLOT="0"

IUSE="debug +gfx803 gfx900 gfx906 gfx908"
REQUIRED_USE="|| ( gfx803 gfx900 gfx906 gfx908 )"

RDEPEND="=sys-devel/hip-$(ver_cut 1-2)*
	 =sci-libs/rocPRIM-$(ver_cut 1-2)*"
DEPEND="${RDEPEND}
	dev-util/cmake"

S="${WORKDIR}/rocSPARSE-rocm-${PV}"

rocSPARSE_V="0.1"

BUILD_DIR="${S}/build/release"

PATCHES=(
	"${FILESDIR}/${P}-skip-language-check.patch"
)

src_prepare() {
	cd ${S}

	sed -e "s: PREFIX rocsparse:# PREFIX rocsparse:" -i library/CMakeLists.txt
	sed -e "s:<INSTALL_INTERFACE\:include:<INSTALL_INTERFACE\:include/rocsparse/:" -i library/CMakeLists.txt
	sed -e "s:rocm_install_symlink_subdir(rocsparse):#rocm_install_symlink_subdir(rocsparse):" -i library/CMakeLists.txt

	sed -e 's:find_package(rocprim REQUIRED):find_package(rocprim REQUIRED CONFIG PATHS ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/cmake/rocprim):' -i cmake/Dependencies.cmake

	eapply_user
	cmake-utils_src_prepare
}

src_configure() {
	# hipcc needs rw access to /dev/kfd
	addread /dev/kfd
	addpredict /dev/kfd
	# if the ISA is not set previous to the autodetection,
	# /opt/rocm/bin/rocm_agent_enumerator is executed,
	# this leads to a sandbox violation
	CurrentISA=""
	if use gfx803; then
			CurrentISA+="gfx803;"
	fi
	if use gfx900; then
			CurrentISA+="gfx900;"
	fi
	if use gfx906; then
			CurrentISA+="gfx906;"
	fi
	if use gfx906; then
			CurrentISA+="gfx908;"
	fi

	export CXX=hipcc
	export CXXFLAGS+=" --hip-device-lib-path=/usr/lib64 "
	export LIBDIR_default="lib64"

	local mycmakeargs=(
		-DBUILD_CLIENTS_SAMPLES=OFF
		-DAMDGPU_TARGETS="${CurrentISA}"
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DCMAKE_INSTALL_INCLUDEDIR="include/rocsparse"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	chrpath --delete "${D}/usr/lib64/librocsparse.so.${rocSPARSE_V}"
}
