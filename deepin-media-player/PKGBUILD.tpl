# Maintainer: Xu Fasheng <fasheng.xu[AT]gmail.com>
# Maintainer: dongfengweixiao <dongfengweixiao[AT]gmail.com>

pkgname=deepin-media-player
pkgver={% pkgver %}
pkgrel=1
pkgdesc='New multimedia player with brilliant and tweakful UI. PyGtk and Deepin-ui Mplayer2 front-end, with features likes smplayer, but has a brilliant and tweakful UI.'
arch=('any')
url="http://www.linuxdeepin.com/"
license=('GPL3')
depends=('python2-scipy' 'python2-pyquery' 'deepin-ui' 'mplayer2' 'gstreamer0.10-ugly' 'gstreamer0.10-ugly-plugins' 'python2-formencode' 'gstreamer0.10-python' 'python2-chardet' 'python2-beautifulsoup3' 'python2-notify' 'python2-dbus' 'python2-xlib' )

source=("{% fileurl %}")
md5sums=('{% md5 %}')

_innerdir="${pkgname}-1+${pkgver}"

_install_copyright_and_changelog() {
    local pkgname=$1
    mkdir -p "${pkgdir}"/usr/share/doc/${pkgname}
    cp -f debian/copyright "${pkgdir}"/usr/share/doc/${pkgname}/
    gzip -c debian/changelog > "${pkgdir}"/usr/share/doc/${pkgname}/changelog.gz
}

# Usage: _easycp dest files...
_easycp () {
    local dest=$1; shift
    mkdir -p "${dest}"
    cp -vR -t "${dest}" "$@"
}

package() {
    cd "${srcdir}/${_innerdir}"

    _easycp "${pkgdir}"/usr/share/icons/hicolor/128x128/apps/ debian/deepin-media-player.png
    _easycp "${pkgdir}"/usr/share/deepin-media-player/ locale
    _easycp "${pkgdir}"/usr/share/deepin-media-player/ app_theme
    _easycp "${pkgdir}"/usr/share/deepin-media-player/ image
    _easycp "${pkgdir}"/usr/share/deepin-media-player/ skin
    _easycp "${pkgdir}"/usr/share/deepin-media-player/ src
    _easycp "${pkgdir}"/usr/share/deepin-media-player/ tools
    _easycp "${pkgdir}"/usr/share/deepin-media-player/ AUTHORS
    _easycp "${pkgdir}"/usr/share/deepin-media-player/ README
    _easycp "${pkgdir}"/usr/share/deepin-media-player/ COPYING

    mkdir -p "${pkgdir}"/usr/share/applications
    install -m 0644 debian/deepin-media-player.desktop "${pkgdir}"/usr/share/applications/

    _install_copyright_and_changelog "${pkgname}"

    mkdir -p "${pkgdir}"/usr/bin
    ln -s /usr/share/deepin-media-player/src/deepin-media-player.py "${pkgdir}"/usr/bin/deepin-media-player

    # fix python version
    find "${pkgdir}" -iname "*.py" | xargs sed -i 's=\(^#! */usr/bin.*\)python=\1python2='

    cd "${pkgdir}"/usr/share/deepin-media-player/tools
    python2 generate_mo.py
}