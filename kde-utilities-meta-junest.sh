#!/usr/bin/env bash

APP=kde-utilities-meta
BIN="$APP" #CHANGE THIS IF THE NAME OF THE BINARY IS DIFFERENT FROM "$APP" (for example, the binary of "obs-studio" is "obs")
qtv="6"
kde_meta="ark filelight francis isoimagewriter kalm kate kbackup kcalc kcharselect kclock \
kdebugsettings kdf kdialog keditbookmarks keysmith kfind kgpg kongress krecorder kteatime \
ktimer ktrip kweather skanpage sweeper telly-skout"
DEPENDENCES=$(echo "$kde_meta alsa-lib libpulse pipewire arj dbus lrzip lzop p7zip unarchiver unrar \
karchive kcoreaddons kcrash ki18n kiconthemes kirigami kirigami-addons kwidgetsaddons solid \
kcmutils kcompletion kconfig kconfigwidgets ki18n kio kjobwidgets kstatusnotifieritem kxmlgui \
kcodecs kcontacts kdbusaddons kservice ktextwidgets kvantum libakonadi kxmlgui qt6ct \
qt$qtv-multimedia gst-plugin-qml$qtv gstreamer gst-plugins-base-libs qt$qtv-declarative" | tr ' ' '\n' | sort -u | xargs)
#BASICSTUFF="binutils debugedit gzip"
#COMPILERS="base-devel"

# Set keywords to searchan include in names of directories and files in /usr/bin (BINSAVED), /usr/share (SHARESAVED) and /usr/lib (LIBSAVED)
BINSAVED="df"
SHARESAVED="qt$qtv snmp tessdata"
LIBSAVED="alsa jack pipewire pulse libogg.so libvorbisenc.so libFLAC.so libmpg123.so libmp3lame.so libgomp.so libQt libpxbackend \
libnghttp libidn libssh libpsl.so qt libxcb-cursor.so libxcb-util.so EGL GLX svg \
libimobiledevice libsensors.so libvorbisfile libtdb libltdl libuuid libLLVM libSPIRV \
libxshmfence libdrm libpciaccess libassuan libPlasma dbus-daemon-launch-helper libKF multimedia Multimedia qml publictransport PublicTransport libsane qt$qtv"

# Set the items you want to manually REMOVE. Complete the path in /etc/, /usr/bin/, /usr/lib/, /usr/lib/python*/ and /usr/share/ respectively.
# The "rm" command will take into account the listed object/path and add an asterisk at the end, completing the path to be removed.
# Some keywords and paths are already set. Remove them if you consider them necessary for the AppImage to function properly.
ETC_REMOVED="makepkg.conf pacman"
BIN_REMOVED="gcc"
LIB_REMOVED="gcc"
PYTHON_REMOVED="__pycache__/"
SHARE_REMOVED="gcc icons/AdwaitaLegacy icons/Adwaita/cursors/ terminfo"

# Set mountpoints, they are ment to be set into the AppRun.
# Default mounted files are /etc/resolv.conf, /etc/hosts, /etc/nsswitch.conf, /etc/passwd, /etc/group, /etc/machine-id, /etc/asound.conf and /etc/localtime
# Default mounted directories are /media, /mnt, /opt, /run/media, /usr/lib/locale, /usr/share/fonts, /usr/share/themes, /var, and Nvidia-related directories
# Do not touch this if you are not sure.
mountpoint_files=""
mountpoint_dirs="/usr/share/Kvantum"

# Post-installation processes (add whatever you want)
_post_installation_processes() {
	printf "\n◆ User's processes: \n\n"
	echo " - Include only valid locale files"
	rm -Rf AppDir/.junest/usr/share/locale/*
	mkdir -p AppDir/.junest/usr/share/locale
	rsync -av dependencies/usr/share/locale/* AppDir/.junest/usr/share/locale/
}

extra_bins="$kde_meta"

echo "[Desktop Entry]
Name=kdeutils
Exec=$APP
Icon=ark
Type=Application
Categories=Utility;" > "$APP".desktop

##########################################################################################################################################################
#	SETUP THE ENVIRONMENT
##########################################################################################################################################################

# Download archimage-builder.sh
if [ ! -f ./archimage-builder.sh ]; then
	ARCHIMAGE_BUILDER="https://raw.githubusercontent.com/ivan-hc/ArchImage/refs/heads/main/core/archimage-builder.sh"
	wget --retry-connrefused --tries=30 "$ARCHIMAGE_BUILDER" -O ./archimage-builder.sh || exit 0
fi

# Create and enter the AppDir
mkdir -p AppDir archlinux && cd archlinux || exit 1

_JUNEST_CMD() {
	./.local/share/junest/bin/junest "$@"
}

# Set archlinux as a temporary $HOME directory
HOME="$(dirname "$(readlink -f "$0")")"

##########################################################################################################################################################
#	DOWNLOAD, INSTALL AND CONFIGURE JUNEST
##########################################################################################################################################################

_enable_archlinuxcn() {	ARCHLINUXCN_ON="1"; }
_enable_chaoticaur() { CHAOTICAUR_ON="1"; }
_enable_multilib() { MULTILIB_ON="1"; }

#_enable_archlinuxcn
#_enable_chaoticaur
#_enable_multilib

[ -f ../archimage-builder.sh ] && source ../archimage-builder.sh junest-setup "$@"

##########################################################################################################################################################
#	INSTALL PROGRAMS USING YAY
##########################################################################################################################################################

[ -f ../archimage-builder.sh ] && source ../archimage-builder.sh install "$@"

cd ..

##########################################################################################################################################################
#	APPDIR
##########################################################################################################################################################

[ -f ./archimage-builder.sh ] && source ./archimage-builder.sh appdir "$@"

##########################################################################################################################################################
#	APPRUN
##########################################################################################################################################################

rm -f AppDir/AppRun

# Set to "1" if you want to add Nvidia drivers manager in the AppRun
export NVIDIA_ON=1

[ -f ./archimage-builder.sh ] && source ./archimage-builder.sh apprun "$@"

# AppRun footer, here you can add options and change the way the AppImage interacts with its internal structure
cat <<-'HEREDOC' >> AppDir/AppRun

case $1 in
'')
echo "
 USAGE: 
    [PROGRAM]
    [PROGRAM] [OPTION]

 See -h to know the names of the available programs.
"; exit;;
-h|--help) echo "
 AVAILABLE KDE UTILITIES:

    ark
    filelight
    francis
    isoimagewriter
    kalm
    kate
    kbackup
    kcalc
    kcharselect
    kclock
    kdebugsettings
    kdf
    kdialog
    keditbookmarks
    keysmith
    kfind
    kgpg
    kongress
    krecorder
    kteatime
    ktimer
    ktrip
    kweather
    kwrite
    skanpage
    sweeper
    telly-skout
";;
ark|filelight|francis|isoimagewriter|kalm|kate|kbackup|kcalc|kcharselect|kclock|kdebugsettings|kdf|kdialog|keditbookmarks|keysmith|kfind|kgpg|kongress|krecorder|kteatime|ktimer|ktrip|kweather|kwrite|skanpage|sweeper|telly-skout)
_JUNEST_CMD -- /usr/bin/"$@"
;;
*)
echo " $1 does not exists, see -h";;
esac

HEREDOC
chmod a+x AppDir/AppRun

##########################################################################################################################################################
#	COMPILE
##########################################################################################################################################################

[ -f ./archimage-builder.sh ] && source ./archimage-builder.sh compile "$@"

##########################################################################################################################################################
#	CREATE THE APPIMAGE
##########################################################################################################################################################

if test -f ./*.AppImage; then rm -Rf ./*archimage*.AppImage; fi

APPNAME="KDE-utils"
REPO="$APPNAME-appimage"
TAG="latest"
UPINFO="gh-releases-zsync|$GITHUB_REPOSITORY_OWNER|$REPO|$TAG|*x86_64.AppImage.zsync"

echo "$VERSION" > ./version

_appimagetool() {
	if ! command -v appimagetool 1>/dev/null; then
		if [ ! -f ./appimagetool ]; then
			echo " Downloading appimagetool..." && curl -#Lo appimagetool https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-"$ARCH".AppImage && chmod a+x ./appimagetool || exit 1
		fi
		./appimagetool "$@"
	else
		appimagetool "$@"
	fi
}

ARCH=x86_64 _appimagetool -u "$UPINFO" AppDir "$APPNAME"_"$VERSION"-"$ARCHIMAGE_VERSION"-x86_64.AppImage
