# Copyright
#

EAPI=7

inherit cmake-utils

DESCRIPTION=""
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/hipCUB"
SRC_URI="https://github.com/ROCmSoftwarePlatform/hipCUB/archive/rocm-${PV}.tar.gz -> hipCUB-${PV}.tar.gz"

LICENSE=""
KEYWORDS="~amd64"
SLOT="0"

IUSE=""

RDEPEND="=sys-devel/hip-$(ver_cut 1-2)*
	=sci-libs/rocPRIM-$(ver_cut 1-2)*"
DEPEND="${RDEPEND}
	dev-util/cmake"

S="${WORKDIR}/hipCUB-rocm-${PV}"

src_prepare() {
	_HCC_PATH=/usr/lib/hcc/3.3
	_HIP_PATH=/usr/lib/hip/3.5
	eapply "${FILESDIR}/master-disable2ndfindhcc.patch"

	sed -e "s:include(cmake/VerifyCompiler.cmake:# include(cmake/VerifyCompiler.cmake:" -i CMakeLists.txt

	# sed -e "s:HIP_PLATFORM STREQUAL \"hcc\":HIP_PLATFORM STREQUAL \"rocclr\":" -i cmake/VerifyCompiler.cmake
	sed -e "s:find_package(HIP 1.5.18263 REQUIRED):find_package(hip 3.5.20476 REQUIRED):" -i cmake/VerifyCompiler.cmake
	sed -e "s:find_package(hcc QUIET CONFIG PATHS /opt/rocm:find_package(hcc QUIET CONFIG PATHS $_HCC_PATH/lib/cmake/hcc:" \
		-i cmake/VerifyCompiler.cmake
	sed -e "s:find_package(hip REQUIRED CONFIG PATHS /opt/rocm:find_package(hip REQUIRED CONFIG PATHS $_HIP_PATH/cmake/hip:"  \
		-i cmake/VerifyCompiler.cmake
	sed -e "s:find_packages(hcc:# find_packages(hcc:" -i cmake/VerifyCompiler.cmake
	sed -e "s:/opt/rocm:/usr:g" -i cmake/VerifyCompiler.cmake

	sed -e "s: PREFIX hipcub:# PREFIX hipcub:" -i ${S}/hipcub/CMakeLists.txt
	sed -e "s:  DESTINATION hipcub/include/:  DESTINATION include/:" -i ${S}/hipcub/CMakeLists.txt
	sed -e "s:rocm_install_symlink_subdir(hipcub):#rocm_install_symlink_subdir(hipcub):" -i ${S}/hipcub/CMakeLists.txt
	sed -e "s:<INSTALL_INTERFACE\:hipcub/include/:<INSTALL_INTERFACE\:include/hipcub/:" -i ${S}/hipcub/CMakeLists.txt

	sed -e "s:set(ROCM_INSTALL_LIBDIR lib:set(ROCM_INSTALL_LIBDIR \${CMAKE_INSTALL_LIBDIR}:" -i ${S}/cmake/ROCMExportTargetsHeaderOnly.cmake

	eapply_user
	cmake-utils_src_prepare
}

src_configure() {
	addread /dev/kfd
	addpredict /dev/kfd
	export CXX=hipcc
	export DEVICE_LIB_PATH="${EPREFIX}/usr/lib64"

	local mycmakeargs=(
		-DHIP_PLATFORM=hcc
		-DBUILD_TEST=OFF
		-DCMAKE_INSTALL_PREFIX=${EPREFIX}/usr/
	)

	cmake-utils_src_configure
}
