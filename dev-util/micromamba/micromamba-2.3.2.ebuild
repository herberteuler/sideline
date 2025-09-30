# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit cmake multilib

DESCRIPTION="A tiny version of the mamba package manager"
HOMEPAGE="https://github.com/mamba-org/mamba"
SRC_URI="https://github.com/mamba-org/mamba/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	app-arch/bzip2
	app-arch/libarchive
	app-arch/lz4
	app-arch/xz-utils
	app-arch/zstd
	app-crypt/mit-krb5
	dev-cpp/cli11
	dev-cpp/nlohmann_json
	dev-cpp/reproc
	dev-cpp/tl-expected
	dev-cpp/yaml-cpp
	dev-libs/libfmt
	dev-libs/libsolv[conda]
	dev-libs/openssl
	dev-libs/simdjson
	dev-libs/spdlog
	sys-libs/zlib
	net-misc/curl
"

RDEPEND="
	$DEPEND
	!dev-util/mamba
	!dev-util/micromamba-bin
"

S="${WORKDIR}/mamba-${PV}"

PATCHES=(
	"${FILESDIR}"/0001-Remove-the-requirement-of-static-libraries.patch
)

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
