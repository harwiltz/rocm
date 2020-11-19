# Copyright
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Meta package for ROCm"
LICENSE="metapackage"

SLOT="0"
KEYWORDS="~amd64"

IUSE="debug-tools hip opencl profiling science"

RDEPEND="
	>=dev-util/rocminfo-3.8.0
	=dev-libs/rocm-smi-lib-9999
	=dev-util/rocm-smi-9999

	opencl? ( >=dev-libs/rocm-opencl-runtime-9999 )
	opencl? ( =dev-util/rocm-clang-ocl-9999 )

	hip? ( >=sys-devel/hip-3.9.0 )

	profiling? ( =dev-util/rocm-bandwidth-test-9999 )

	debug-tools? ( =dev-libs/rocm-debug-agent-9999 )
	debug-tools? ( =dev-util/rocprofiler-9999 )
	debug-tools? ( =dev-util/roctracer-9999 )

	hip? ( science? ( =sci-libs/hipBLAS-9999 ) )
	hip? ( science? ( =sci-libs/hipCUB-9999 ) )
	hip? ( science? ( =sci-libs/hipSPARSE-9999 ) )

	science? ( =sci-libs/rocPRIM-9999 )
	science? ( =sci-libs/rocRAND-9999 )
	science? ( =sci-libs/rocFFT-9999 )
	science? ( =sci-libs/rocSPARSE-9999 )
	science? ( =sci-libs/rocThrust-9999 )
	science? ( =sci-libs/hipCUB-9999 )
	science? ( =sci-libs/hipSPARSE-9999 )
	science? ( >=sci-libs/rocBLAS-3.8.0 )
	science? ( =sci-libs/rocSOLVER-9999 )
	science? ( =sci-libs/rocALUTION-9999 )
	science? ( =sci-libs/hipBLAS-9999 )
"






