# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_OPTIONAL=1
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{11..14} )

inherit cmake distutils-r1

DESCRIPTION="A tiny version of the mamba package manager"
HOMEPAGE="https://github.com/mamba-org/mamba"
SRC_URI="https://github.com/mamba-org/mamba/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="python"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

DEPEND="
	app-arch/bzip2:=
	app-arch/libarchive:=
	app-arch/lz4:=
	app-arch/xz-utils
	app-arch/zstd:=
	app-crypt/mit-krb5
	dev-cpp/cli11
	dev-cpp/expected
	dev-cpp/nlohmann_json
	dev-cpp/reproc:=
	dev-cpp/yaml-cpp:=
	dev-libs/libfmt:=
	dev-libs/libsolv[conda]
	dev-libs/openssl:=
	dev-libs/simdjson:=
	dev-libs/spdlog:=
	net-misc/curl
	sys-libs/zlib:=
"

RDEPEND="
	$DEPEND
	!dev-util/mamba
	!dev-util/micromamba-bin
	python? (
		${PYTHON_DEPS}
	)
"

BDEPEND="
	python? (
		${PYTHON_DEPS}
		${DISTUTILS_DEPS}
		$(python_gen_cond_dep 'dev-python/pybind11[${PYTHON_USEDEP}]')
		$(python_gen_cond_dep 'dev-python/scikit-build[${PYTHON_USEDEP}]')
	)
"

S="${WORKDIR}/mamba-${PV}"

PATCHES=(
	"${FILESDIR}"/0001-Remove-the-requirement-of-static-libraries.patch
	"${FILESDIR}"/0002-Align-with-FHS-Gentoo-s-path-policy.patch
)

src_prepare() {
	cmake_src_prepare
	if use python; then
		cd libmambapy
		distutils-r1_src_prepare
	fi
}

src_configure() {
	cat >"${T}"/zstdConfig.cmake <<EOF || die
	add_library(zstd::libzstd_shared SHARED IMPORTED)
	set_target_properties(zstd::libzstd_shared PROPERTIES
		IMPORTED_LOCATION "${EPREFIX}/usr/$(get_libdir)/libzstd$(get_libname)")
EOF
	local mycmakeargs=(
		-DBUILD_LIBMAMBA=ON
		-DBUILD_LIBMAMBA_TESTS=NO
		-DBUILD_MAMBA_PACKAGE=OFF
		-DBUILD_MICROMAMBA=ON
		-DBUILD_SHARED=ON
		-DBUILD_STATIC=OFF
		-Dzstd_DIR="${T}"
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	if use python; then
		cd libmambapy
		export libmamba_DIR="${BUILD_DIR}/libmamba"
		distutils-r1_src_compile
	fi
}

src_install() {
	cmake_src_install
	if use python; then
		cd libmambapy
		distutils-r1_src_install
	fi
}

distutils_enable_tests pytest
