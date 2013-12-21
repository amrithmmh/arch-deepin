# Maintainer: Xu Fasheng <fasheng.xu@gmail.com>

pkgname=('deepin-desktop-environment'
         'deepin-desktop-environment-common'
         'deepin-desktop-environment-dock'
         'deepin-desktop-environment-launcher'
         'deepin-desktop-environment-lightdm-greeter'
         'deepin-desktop-environment-desktop'
         'deepin-desktop-environment-lock')
pkgbase="deepin-desktop-environment"
pkgver={% pkgver %}
_realver="1.0+${pkgver}"
pkgrel=1
arch=('i686' 'x86_64')
url="http://www.linuxdeepin.com/"
license=('GPL2')
depends=('gtk3' 'webkitgtk' 'deepin-webkit' 'gdk-pixbuf2' 'python2' 'dbus-glib' 'sqlite' 'glib2' 'lightdm' 'gstreamer0.10' 'opencv')
makedepends=('cmake' 'go' 'coffee-script')
install=deepin-desktop-environment.install

source=("{% fileurl %}")
md5sums=('{% md5 %}')

_install_copyright_and_changelog() {
    local pkgname=$1
    mkdir -p "${pkgdir}"/usr/share/doc/${pkgname}
    cp -f debian/copyright "${pkgdir}"/usr/share/doc/${pkgname}/
    gzip -c debian/changelog > "${pkgdir}"/usr/share/doc/${pkgname}/changelog.gz
}

build() {
    cd "${srcdir}/${pkgbase}-${_realver}"
    local _tmpdest="${srcdir}/${pkgbase}-${_realver}/build/_tmpdest"
    mkdir -p "${_tmpdest}"

    (
        mkdir -p build
        cd build
        cmake -DCMAKE_INSTALL_PREFIX="/usr" ..
        make
        make DESTDIR="${_tmpdest}" install
    )

    # fix python version
    find "${_tmpdest}" -iname "*.py" | xargs sed -i 's=\(^#! */usr/bin.*\)python=\1python2='

    gcc -o debian/default-terminal debian/default-terminal.c `pkg-config --libs --cflags glib-2.0 gio-unix-2.0`
}

package_deepin-desktop-environment() {
    pkgdesc='Meta package for Linux Deepin desktop environment'
    depends=('deepin-desktop-environment-dock' 'deepin-desktop-environment-launcher' 'deepin-artwork' 'deepin-desktop-environment-lightdm-greeter' 'deepin-desktop-environment-desktop' 'deepin-desktop-environment-lock')

    cd "${srcdir}/${pkgbase}-${_realver}"
    _install_copyright_and_changelog "${pkgname}"
}

package_deepin-desktop-environment-common() {
    pkgdesc="Desktop environment resources for Linux Deepin"

    cd "${srcdir}/${pkgbase}-${_realver}"
    local _tmpdest="${srcdir}/${pkgbase}-${_realver}/build/_tmpdest"

    mkdir -p "${pkgdir}"/usr/share/dde/resources/common
    mkdir -p "${pkgdir}"/usr/share/dde/data
    mkdir -p "${pkgdir}"/usr/share/glib-2.0/schemas
    mkdir -p "${pkgdir}"/usr/share/locale
    mkdir -p "${pkgdir}"/etc/sysctl.d
    mkdir -p "${pkgdir}"/usr/bin

    cp -vR "${_tmpdest}"/usr/share/dde/resources/common/* "${pkgdir}"/usr/share/dde/resources/common/
    cp -vR "${_tmpdest}"/usr/share/dde/data/* "${pkgdir}"/usr/share/dde/data/
    cp -vR "${_tmpdest}"/usr/share/glib-2.0/schemas/* "${pkgdir}"/usr/share/glib-2.0/schemas/
    cp -vR "${_tmpdest}"/usr/share/locale/*  "${pkgdir}"/usr/share/locale/
    cp -vR debian/30-deepin-inotify-limit.conf "${pkgdir}"/etc/sysctl.d/
    cp -vR debian/default-terminal "${pkgdir}"/usr/bin/

    _install_copyright_and_changelog "${pkgname}"
}

package_deepin-desktop-environment-dock() {
    pkgdesc="Dock module for  Linuxdeepin test desktop environment"
    depends=('deepin-desktop-environment-common' 'deepin-webkit' 'gvfs' 'xdg-user-dirs')

    cd "${srcdir}/${pkgbase}-${_realver}"
    local _tmpdest="${srcdir}/${pkgbase}-${_realver}/build/_tmpdest"

    mkdir -p "${pkgdir}"/usr/bin
    mkdir -p "${pkgdir}"/usr/share/applications
    mkdir -p "${pkgdir}"/usr/share/dde/resources/dock

    cp -vR "${_tmpdest}"/usr/bin/dock "${pkgdir}"/usr/bin/
    cp -vR "${_tmpdest}"/usr/share/dde/resources/dock/* "${pkgdir}"/usr/share/dde/resources/dock/
    install -m 0644 "${_tmpdest}"/usr/share/applications/deepin-dock.desktop "${pkgdir}"/usr/share/applications/deepin-dock.desktop

    _install_copyright_and_changelog "${pkgname}"
}

package_deepin-desktop-environment-launcher() {
    pkgdesc="Launcher module for Linux Deepin desktop environment"
    depends=('deepin-desktop-environment-common' 'deepin-webkit' 'gvfs' 'xdg-user-dirs')

    cd "${srcdir}/${pkgbase}-${_realver}"
    local _tmpdest="${srcdir}/${pkgbase}-${_realver}/build/_tmpdest"

    mkdir -p "${pkgdir}"/usr/bin
    mkdir -p "${pkgdir}"/usr/share/dde/resources/launcher
    mkdir -p "${pkgdir}"/etc/xdg/autostart

    cp -vR "${_tmpdest}"/usr/bin/launcher  "${pkgdir}"/usr/bin/
    cp -vR "${_tmpdest}"/usr/share/dde/resources/launcher/*  "${pkgdir}"/usr/share/dde/resources/launcher/
    install -m 0644 "${_tmpdest}"/etc/xdg/autostart/deepin-launcher.desktop  "${pkgdir}"/etc/xdg/autostart/

    _install_copyright_and_changelog "${pkgname}"
}

package_deepin-desktop-environment-desktop() {
    pkgdesc="Desktop module for Linux Deepin desktop environment"
    depends=('deepin-desktop-environment-common' 'deepin-webkit' 'gvfs' 'xdg-user-dirs')

    cd "${srcdir}/${pkgbase}-${_realver}"
    local _tmpdest="${srcdir}/${pkgbase}-${_realver}/build/_tmpdest"

    mkdir -p "${pkgdir}"/usr/bin
    mkdir -p "${pkgdir}"/usr/share/applications
    mkdir -p "${pkgdir}"/usr/share/dde/resources/desktop

    cp -vR "${_tmpdest}"/usr/bin/desktop "${pkgdir}"/usr/bin/
    cp -vR "${_tmpdest}"/usr/share/dde/resources/desktop/* "${pkgdir}"/usr/share/dde/resources/desktop/
    install -m 0644 "${_tmpdest}"/usr/share/applications/deepin-desktop.desktop "${pkgdir}"/usr/share/applications/

    _install_copyright_and_changelog "${pkgname}"
}

package_deepin-desktop-environment-lightdm-greeter() {
    pkgdesc="Lightdm greeter for Linux Deepin test desktop environment"
    depends=('deepin-desktop-environment-common' 'deepin-webkit' 'lightdm' 'opencv')

    cd "${srcdir}/${pkgbase}-${_realver}"
    local _tmpdest="${srcdir}/${pkgbase}-${_realver}/build/_tmpdest"

    mkdir -p "${pkgdir}"/usr/bin
    mkdir -p "${pkgdir}"/usr/share/dde/resources/greeter
    mkdir -p "${pkgdir}"/usr/share/xgreeters
    mkdir -p "${pkgdir}"/var/lib/polkit-1/localauthority/50-local.d

    cp -vR "${_tmpdest}"/usr/bin/greeter "${pkgdir}"/usr/bin/
    cp -vR "${_tmpdest}"/usr/share/dde/resources/greeter/* "${pkgdir}"/usr/share/dde/resources/greeter/
    cp -vR debian/lightdm.pkla "${pkgdir}"/var/lib/polkit-1/localauthority/50-local.d/
    install -m 0644 debian/deepin-greeter.desktop "${pkgdir}"/usr/share/xgreeters/

    _install_copyright_and_changelog "${pkgname}"
}

package_deepin-desktop-environment-lock() {
    pkgdesc="Lock screen module for Linux Deepin desktop environment"
    depends=('deepin-desktop-environment-common' 'deepin-webkit' 'lightdm' 'opencv')

    cd "${srcdir}/${pkgbase}-${_realver}"
    local _tmpdest="${srcdir}/${pkgbase}-${_realver}/build/_tmpdest"

    mkdir -p "${pkgdir}"/usr/bin
    mkdir -p "${pkgdir}"/usr/share/dbus-1/system-services
    mkdir -p "${pkgdir}"/etc/dbus-1/system.d

    cp -vR "${_tmpdest}"/usr/bin/dlock "${pkgdir}"/usr/bin
    cp -vR "${_tmpdest}"/usr/bin/lockservice "${pkgdir}"/usr/bin
    cp -vR "${_tmpdest}"/usr/bin/switchtogreeter "${pkgdir}"/usr/bin
    cp -vR "${_tmpdest}"/usr/share/dbus-1/system-services/* "${pkgdir}"/usr/share/dbus-1/system-services/
    cp -vR "${_tmpdest}"/etc/dbus-1/system.d/* "${pkgdir}"/etc/dbus-1/system.d/

    _install_copyright_and_changelog "${pkgname}"
}
