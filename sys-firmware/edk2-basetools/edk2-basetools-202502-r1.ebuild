# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

MY_PN="edk2"
DESCRIPTION="TianoCore EDK II BaseTools - C utilities for UEFI firmware development"
HOMEPAGE="https://github.com/tianocore/edk2"

BUNDLED_BROTLI_SUBMODULE_SHA="f4153a09f87cbb9c826d8fc12c74642bb2d879ea"

SRC_URI="
	https://github.com/tianocore/${MY_PN}/archive/${MY_PN}-stable${PV}.tar.gz
		-> ${MY_PN}-${PV}.tar.gz
	https://github.com/google/brotli/archive/${BUNDLED_BROTLI_SUBMODULE_SHA}.tar.gz
		-> brotli-${BUNDLED_BROTLI_SUBMODULE_SHA}.tar.gz
"

S="${WORKDIR}/${MY_PN}-${MY_PN}-stable${PV}"
LICENSE="BSD-2-with-patent MIT"
SLOT="0"
KEYWORDS="~amd64"

PATCHES=(
	"${FILESDIR}"/edk2-202411-werror.patch
)

link_mod() {
	rmdir "$2" && ln -sfT "$1" "$2" || die "linking ${2##*/} failed"
}

src_prepare() {
	link_mod "${WORKDIR}/brotli-${BUNDLED_BROTLI_SUBMODULE_SHA}" \
		BaseTools/Source/C/BrotliCompress/brotli
	default
}

src_compile() {
	tc-export_build_env
	emake -C BaseTools \
		CC="$(tc-getBUILD_CC)" \
		CXX="$(tc-getBUILD_CXX)" \
		EXTRA_OPTFLAGS="${BUILD_CFLAGS}" \
		EXTRA_LDFLAGS="${BUILD_LDFLAGS}"
}

src_install() {
	dobin BaseTools/Source/C/bin/*
}
