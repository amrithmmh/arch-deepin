# Maintainer: Xu Fasheng <fasheng.xu[AT]gmail.com>
# Contributor: 4679kun <admin[AT]4679.us>
# Contributor: dongfengweixiao <dongfengweixiao[AT]gmail.com>

pkgname=deepin-music-player
pkgver={% pkgver %}
pkgrel=1
pkgdesc='Awesome music player with brilliant and tweakful UI Deepin-UI based, gstreamer front-end, with features likes search music by pinyin,quanpin, colorful lyrics supports, and more powerfull functions you will found.'
arch=('any')
url="http://www.linuxdeepin.com/"
license=('GPL3')
depends=('gstreamer0.10-python' 'gstreamer0.10-bad-plugins' 'gstreamer0.10-good-plugins' 'gstreamer0.10-ugly-plugins' 'mutagen' 'python2-chardet' 'python2-scipy' 'python2-pyquery' 'python2-cssselect' 'deepin-ui' 'python2-dbus' 'sonata' 'cddb-py' 'python2-pycurl' 'python-xlib' 'python2-keybinder2')

_fileurl={% fileurl %}
source=("${_fileurl}")
md5sums=('{% md5 %}')

_filename="$(basename "${_fileurl}")"
_filename="${_filename%.tar.gz}"
_innerdir="${_filename/_/-}"

_install_copyright_and_changelog() {
    mkdir -p "${pkgdir}/usr/share/doc/${pkgname}"
    cp -f debian/copyright "${pkgdir}/usr/share/doc/${pkgname}/"
    gzip -c debian/changelog > "${pkgdir}/usr/share/doc/${pkgname}/changelog.gz"
}

# Usage: _easycp dest files...
_easycp () {
    local dest=$1; shift
    mkdir -p "${dest}"
    cp -vR -t "${dest}" "$@"
}

package() {
    cd "${srcdir}/${_innerdir}"

    _easycp "${pkgdir}"/usr/share/icons/hicolor/128x128/apps/ debian/deepin-music-player.png
    _easycp "${pkgdir}"/usr/share/deepin-music-player/ app_theme
    _easycp "${pkgdir}"/usr/share/deepin-music-player/ image
    _easycp "${pkgdir}"/usr/share/deepin-music-player/ skin
    _easycp "${pkgdir}"/usr/share/deepin-music-player/ locale
    _easycp "${pkgdir}"/usr/share/deepin-music-player/ src
    _easycp "${pkgdir}"/usr/share/deepin-music-player/ wizard
    _easycp "${pkgdir}"/usr/share/deepin-music-player/ plugins
    _easycp "${pkgdir}"/usr/share/deepin-music-player/ tools
    _easycp "${pkgdir}"/usr/share/deepin-music-player/ AUTHORS
    _easycp "${pkgdir}"/usr/share/deepin-music-player/ COPYING

    mkdir -p "${pkgdir}"/usr/share/applications/
    install -m 0644 deepin-music-player.desktop "${pkgdir}"/usr/share/applications/

    _install_copyright_and_changelog

    # Post install
    mkdir -p "${pkgdir}"/usr/bin
    ln -s /usr/share/deepin-music-player/src/main.py "${pkgdir}"/usr/bin/deepin-music-player

    cd "${pkgdir}"/usr/share/deepin-music-player/tools
    python2 generate_mo.py

    # fix python version
    find "${pkgdir}" -iname "*.py" | xargs sed -i 's=\(^#! */usr/bin.*\)python=\1python2='
}
