# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake flag-o-matic

if [[ ${PV} == *9999 ]] ; then
	KEYWORDS="~amd64"
	EGIT_REPO_URI="https://github.com/RadeonOpenCompute/ROCm-OpenCL-Runtime -> ${P}"
	inherit git-r3
else
	SRC_URI="https://github.com/RadeonOpenCompute/ROCm-OpenCL-Runtime/archive/roc-${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/ROCm-OpenCL-Runtime-roc-${PV}"
fi

DESCRIPTION="Radeon Open Compute OpenCL Compatible Runtime"
HOMEPAGE="https://github.com/RadeonOpenCompute/ROCm-OpenCL-Runtime"

LICENSE="Apache-2.0 MIT"
SLOT="0/$(ver_cut 1-2)"

RDEPEND="=dev-libs/rocr-runtime-$(ver_cut 1-2)*
	=dev-libs/rocm-comgr-$(ver_cut 1-2)*
	=dev-libs/rocm-device-libs-$(ver_cut 1-2)*
	>=virtual/opencl-3
	=dev-libs/rocclr-$(ver_cut 1-2)*
	media-libs/mesa"
DEPEND="${RDEPEND}
	dev-lang/ocaml
	dev-ml/findlib"
BDEPEND=">=dev-util/rocm-cmake-${PV}"

#"${FILESDIR}/${PN}-3.7.0-amdocl64icd.patch"
#"${FILESDIR}/${PN}-3.9.0-add-rocclr-include-directories.patch"
PATCHES=(
	"${FILESDIR}/${PN}-3.5.0-do-not-install-libopencl.patch"
	"${FILESDIR}/${PN}-3.7.0-change-install-location.patch"
)

src_prepare() {
	# Remove "clinfo" - use "dev-util/clinfo" instead
	[ -d tools/clinfo ] && rm -rf tools/clinfo || die

	# Wrong position of a '"' results in a list of strings instead of a single string and the build fails...
	sed -e "s:set(CMAKE_SHARED_LINKER_FLAGS \${CMAKE_SHARED_LINKER_FLAGS} \":set(CMAKE_SHARED_LINKER_FLAGS \"\${CMAKE_SHARED_LINKER_FLAGS} :" -i "${S}/amdocl/CMakeLists.txt"

	cmake_src_prepare
}

src_configure() {
	# Reported upstream: https://github.com/RadeonOpenCompute/ROCm-OpenCL-Runtime/issues/120
	append-cflags -fcommon

	export ROCclr_DIR="${EPREFIX}/usr/include/rocclr"

	local mycmakeargs=(
		-DUSE_COMGR_LIBRARY=yes
		-DROCclr_DIR="$ROCclr_DIR"
		-DLIBROCclr_STATIC_DIR="${EPREFIX}/usr/lib64"
	)
	cmake_src_configure
}

src_install() {
	cd "${WORK_DIR}" || die
	insinto /etc/OpenCL/vendors
	doins config/amdocl64.icd
	cd "${BUILD_DIR}" || die
	insinto /usr/lib64
	doins lib/libamdocl64.so
}
