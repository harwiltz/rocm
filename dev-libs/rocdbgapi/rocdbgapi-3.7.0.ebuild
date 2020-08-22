# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils

DESCRIPTION="AMD Debugger API"
HOMEPAGE="https://github.com/ROCm-Developer-Tools/ROCdbgapi"
SRC_URI="https://github.com/ROCm-Developer-Tools/ROCdbgapi/archive/rocm-${PV}.tar.gz -> ${P}.tar.gz"

KEYWORDS="~amd64"
LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"

RDEPEND=">=dev-libs/rocm-comgr-${PV}"
DEPEND="${RDEPEND}"

S="${WORKDIR}/ROCdbgapi-roc-${PV}/"

