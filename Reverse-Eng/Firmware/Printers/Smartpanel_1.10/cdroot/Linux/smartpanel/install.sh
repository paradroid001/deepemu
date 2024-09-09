#!/bin/sh
VENDOR=Samsung

INSIDE_UD=$2

BASE_DIR=`dirname "$0"`
cd "$BASE_DIR"

HARDWARE_PLATFORM=`uname -m`
if [ "$HARDWARE_PLATFORM" = "i486" -o "$HARDWARE_PLATFORM" = "i586" -o "$HARDWARE_PLATFORM" = "i686" ]; then
	HARDWARE_PLATFORM=i386
fi

[ "$HARDWARE_PLATFORM" != "i386" -a "$HARDWARE_PLATFORM" != "x86_64" ] && { echo "Unsuppored hardware platform <$HARDWARE_PLATFORM>"; exit 1; }

if [ "$HARDWARE_PLATFORM" = "x86_64" ]; then
	PLSFX=64
else
	PLSFX=
fi

INSTALL_DIR_COMMON=/opt/smfp-common

# Linux distribution detection
ISSUE=`cat /etc/issue 2>/dev/null`
LINUX_DIST=
if ( echo $ISSUE | grep -q "Mandriva Linux release 200[7-9]\|Mandriva Linux release 20[1-9]" ); then
	LINUX_DIST="MANDRIVA_2007_AND_ABOVE"
elif ( echo $ISSUE | grep -q "Fedora release" ); then
	LINUX_DIST="FEDORA_7_AND_ABOVE"
elif ( echo $ISSUE | grep -q "Ubuntu" ); then
	LINUX_DIST="UBUNTU"
fi

# check_libqt procedure from Unified Linux Driver project. Modified.

check_libqt() {
	COMMON_LIB_DIR=$INSTALL_DIR_COMMON/lib$PLSFX
	if ! [ -f "$COMMON_LIB_DIR/libqt-mt.so.3.0.5" -a -f "$COMMON_LIB_DIR/libqt-mt.so.3" ]; then
		mkdir -p "$COMMON_LIB_DIR" && \
		cp -a "share/lib$PLSFX/libqt-mt.so.3.0.5" "$COMMON_LIB_DIR" && \
		cp -a "share/lib$PLSFX/libqui.so.1.0.0" "$COMMON_LIB_DIR" && \
		chmod 755 "$COMMON_LIB_DIR"/* && \
		( cd "$COMMON_LIB_DIR" && \
			ln -s -f libqt-mt.so.3.0.5 libqt-mt.so.3.0 ; \
			ln -s -f libqt-mt.so.3.0.5 libqt-mt.so.3   ; \
			ln -s -f libqt-mt.so.3.0.5 libqt-mt.so     ; \
			ln -s -f libqui.so.1.0.0 libqui.so.1.0     ; \
			ln -s -f libqui.so.1.0.0 libqui.so.1       ; \
			ln -s -f libqui.so.1.0.0 libqui.so         ; \
		)
	fi
}

# check_libstdcxx procedure from Unified Linux Driver project. Modified.

check_libstdcxx() {

	LIBSTDCXX_FILES=`ls /usr/lib${PLSFX}/libstdc++.so.5* 2> /dev/null`
	LIBSTDCXX_ARC="share/libstdc++-5-${HARDWARE_PLATFORM}.tar.gz"
	if test -z "$LIBSTDCXX_FILES" -a -f $LIBSTDCXX_ARC ; then
		echo -n "libstdc++.so.5 (gcc 3.0.x .. 3.3.x) not found, intstall ... "
		zcat $LIBSTDCXX_ARC | tar -xf - -C /
		ldconfig
		echo "done"
	fi
}

check_libnetsnmp() {

	COMMON_LIB_DIR=$INSTALL_DIR_COMMON/lib$PLSFX
	if ! [ -f "${COMMON_LIB_DIR}/libnetsnmp.so.10.0.2" -a -f "${COMMON_LIB_DIR}/libnetsnmp.so.10" ]; then
		mkdir -p "$COMMON_LIB_DIR" && \
		cp -a "share/lib$PLSFX/libnetsnmp.so.10.0.2" "$COMMON_LIB_DIR" && \
		chmod 755 "$COMMON_LIB_DIR"/* && \
		( cd "$COMMON_LIB_DIR" && \
			ln -s -f libnetsnmp.so.10.0.2 libnetsnmp.so.10; \
		)
	fi
}

normalize_model() {
# $1 - model
	echo "$1" | tr [A-Z] [a-z] | sed 's: :_:g'
}

USE_WRAPPERS=0
if test -z "`ls -d /usr/lib*/*/lib/libqt-mt* /usr/lib*/libqt-mt* /opt/*/lib/libqt-mt* /usr/local/*/lib/libqt-mt* 2> /dev/null`" ; then
	USE_WRAPPERS=1
fi

check_libstdcxx

DEST_DIRNAME=SmartPanel
APP_FILENAME=smartpanel
DESKTOP_DIRNAME="Smart Panel"
DESKTOP_APPNAME="Smart Panel"
UNINSTALL_DIRNAME=SmartPanel
APP_NAME=`basename "$BASE_DIR" | tr A-Z a-z`
if [ "$APP_NAME" = "psulauncher" ]; then
	DEST_DIRNAME=PSULauncher
	APP_FILENAME=psulauncher
	DESKTOP_DIRNAME="Printer Settings Utility"
	DESKTOP_APPNAME=PSU
	UNINSTALL_DIRNAME=PSU
fi
PACKAGE_NAME="$VENDOR $DESKTOP_DIRNAME"
DEST_PATH=/opt/$VENDOR/$DEST_DIRNAME

APP_DIR=$DEST_PATH/bin
APP_PATH=$APP_DIR/$APP_FILENAME
APP_ICON=$DEST_PATH/share/icons/sp_default.png

UNINSTALL_DIR=/opt/$VENDOR/$UNINSTALL_DIRNAME
UNINSTALL_PATH=$UNINSTALL_DIR/uninstall.sh
UNINSTALL_ICON=$DEST_PATH/share/icons/uninstall.png

#recreate destination
rm -fr "$DEST_PATH"
mkdir -p "$DEST_PATH"
mkdir -p "${DEST_PATH}/share"

if [ $? -ne 0 ]
then
	echo "ERROR: Cannot copy binaries! Check your permissions."
	return
fi

if [ "$USE_WRAPPERS" = "1" ]; then
	check_libqt
fi

check_libnetsnmp

( tar -cf - . | tar -xf - -C $DEST_PATH 2> /dev/null )

if [ "$PLSFX" = "64" ]; then
	rm -rf "$DEST_PATH/bin"
	mv "$DEST_PATH/bin64" "$DEST_PATH/bin"
fi

# Old style help
mkdir -p $DEST_PATH/share/translation
rm -rf $DEST_PATH/install.sh $DEST_PATH/vendormenu* $DEST_PATH/bin64 $DEST_PATH/share/libstdc*
ls -d $DEST_PATH/share/?? >/dev/null 2>&1 &&
mv $DEST_PATH/share/?? $DEST_PATH/share/translation/ &&
for d in $DEST_PATH/share/translation/?? ; do
	( cd "$d" && mkdir help ; mv * help/ 2> /dev/null ; mv help/*.xml ./ 2> /dev/null
		# Normalize models (rename model help directories)
		cd help &&
		for MODEL_DIRNAME in *; do
			MODEL_DIRNAME_NORM=`normalize_model "$MODEL_DIRNAME"`
			[ "$MODEL_DIRNAME" != "$MODEL_DIRNAME_NORM" ] && [ -d "$MODEL_DIRNAME" ] && mv "$MODEL_DIRNAME" "$MODEL_DIRNAME_NORM"
		done
	)
done

# New style help (from /cdroot/Manual)
MANUAL_PATH=`ls -d ../../manual ../../MANUAL ../../Manual 2> /dev/null`
TEST_ENG_PATH=`ls -d $MANUAL_PATH/En* $MANUAL_PATH/en* 2> /dev/null`
## ManualPath + direct English path means old style manual structure
if [ -n "$MANUAL_PATH" -a -z "$TEST_ENG_PATH" ] && ls -d $MANUAL_PATH/* > /dev/null 2>&1 ; then
	for SRC_MODEL_HELP_PATH in $MANUAL_PATH/* ; do
		SRC_MODEL_HELP_DIRNAME=`basename "$SRC_MODEL_HELP_PATH"`
		DST_MODEL_HELP_DIRNAME=`normalize_model "$SRC_MODEL_HELP_DIRNAME"`
		DST_MODEL_HELP_PATH=$DEST_PATH/share/help/$DST_MODEL_HELP_DIRNAME

		mkdir -p "$DST_MODEL_HELP_PATH" && tar -cf - -C "$SRC_MODEL_HELP_PATH" . | tar -xf - -C "$DST_MODEL_HELP_PATH"
		
		#########################################################
		# Find and copy help.xml from old help to new if exists

		# If there is 'en' language in old style help then help.xml is used as language independent help file in new style help
		if ls $DEST_PATH/share/translation/en/help/$DST_MODEL_HELP_DIRNAME*/help.xml > /dev/null 2>&1 ; then
			for DST_MODEL_HELPXML_PATH_ORIG in $DEST_PATH/share/translation/en/help/$DST_MODEL_HELP_DIRNAME*/help.xml ; do
				cp "$DST_MODEL_HELPXML_PATH_ORIG" "$DST_MODEL_HELP_PATH"
				break;
			done

		# If there is no 'en' language then help.xml from any language is used
		elif ls $DEST_PATH/share/translation/??/help/$DST_MODEL_HELP_DIRNAME*/help.xml > /dev/null 2>&1 ; then
			for DST_MODEL_HELPXML_PATH_ORIG in $DEST_PATH/share/translation/??/help/$DST_MODEL_HELP_DIRNAME*/help.xml ; do
				cp "$DST_MODEL_HELPXML_PATH_ORIG" "$DST_MODEL_HELP_PATH"
				break;
			done

		# Failed to find help.xml in old style help directories
		else
			echo "Can't find help.xml for model \'$SRC_MODEL_HELP_DIRNAME\'"
		fi
	done
fi

[ -d "$DEST_PATH/share/i18n" ] && mv "$DEST_PATH/share/i18n" "$DEST_PATH/share/tr"

#copy uninstall script
cp -f ./uninstall.sh "$DEST_PATH"

#change ownerships
find "$DEST_PATH" -exec chown -h root:root \{\} \;

application_shutdown()
{
	echo "INFO: Shutting down $APP_FILENAME: "
		
	
	if ps -C "$APP_FILENAME" l > /dev/null || ps -C "${APP_FILENAME}.bin" l > /dev/null
	then 
		#PIDS=`ps -C 'smartpanel' l | grep ${DEST_PATH} | awk '{print $3}'`  --- don't work on Redhat 8.0
		PIDS=`ps -C "$APP_FILENAME" h | grep "$DEST_PATH" | awk '{print $1}'`
		if test -z "$PIDS" ; then
			PIDS=`ps -C "${APP_FILENAME}.bin" h | grep "$DEST_PATH" | awk '{print $1}'`
		fi
		if test -n "$PIDS" ; then
			kill -s TERM $PIDS
		fi
	fi
	
	if ps -C 'snmpdemon' l > /dev/null || ps -C 'snmpdemon.bin' l > /dev/null
	then 
		#PIDS=`ps -C 'snmpdemon' l | grep ${DEST_PATH} | awk '{print $3}'`  --- don't work on Redhat 8.0
		PIDS=`ps -C 'snmpdemon' h | grep "$DEST_PATH" | awk '{print $1}'`
		if test -z "$PIDS" ; then
			PIDS=`ps -C 'snmpdemon.bin' h | grep "$DEST_PATH" | awk '{print $1}'`
		fi
		if test -n "$PIDS" ; then
			kill -s TERM $PIDS
		fi
	fi
		
	return 0
}

create_desktop_directory() 
{
	DIRFILE="$1"
	cat > "$DIRFILE" <<EOF	
[Desktop Entry]
Name=$PACKAGE_NAME
Comment=$PACKAGE_NAME
Icon=${DEST_PATH}/share/icons/sp_default.png
Type=Directory
EOF
}

create_app_desktop() 
{
	STARTUPFILE="$1"
	cat > "$STARTUPFILE" <<EOF	
[Desktop Entry]
Encoding=UTF-8
Name=${VENDOR} ${DESKTOP_APPNAME}
Exec=${APP_PATH}
Type=Application
Icon=${DEST_PATH}/share/icons/sp_default.png
X-KDE-autostart-after=panel
X-KDE-StartupNotify=false
EOF
}

create_uninstall_desktop() 
{
	STARTUPFILE="$1"
	if [ -f "$STARTUPFILE" ]; then
		rm -f "$STARTUPFILE"
	fi
	cat > "$STARTUPFILE" <<EOF		
[Desktop Entry]
Encoding=UTF-8
Name=Uninstall ${VENDOR} ${DESKTOP_APPNAME}
Exec=$UNINSTALL_PATH
Type=Application
Icon=${DEST_PATH}/share/icons/uninstall.png
Terminal=0
X-KDE-SubstituteUID=false
X-KDE-Username=
EOF
}

create_KDE_startup()
{
	if test -d /etc/opt/kde*/share/autostart/SuSE ; then
		AUTO_PATH="`dirname /etc/opt/kde*/share/autostart/SuSE/`/`basename /etc/opt/kde*/share/autostart/SuSE/`"
		create_app_desktop ${AUTO_PATH}/${APP_FILENAME}.desktop		
	elif test -d /opt/kde*/share/autostart ; then
		AUTO_PATH="`dirname /opt/kde*/share/autostart/`/`basename /opt/kde*/share/autostart/`"
		create_app_desktop ${AUTO_PATH}/${APP_FILENAME}.desktop
	elif test -d /usr/share/autostart ; then
		create_app_desktop /usr/share/autostart/${APP_FILENAME}.desktop
	fi
}

get_home_dir()
{
	#must be calculated ...
	if [ "$1" = "root" ]
	then
		echo /root/
	else
		echo /home/"$1"/
	fi
}

prepare_record()
{		
	echo "$1"",RestartStyleHint=3" >> $2
	echo "$1"",Priority=90" >> $2
	echo "$1"",RestartCommand=$APP_PATH" >> $2
}

process_session()
{	
	# Pass 1. Find blocks which are to be modified.

	block_no=0
	block_has_smartpanel_entry=0
	blocks_to_modify_numbers=""
	while read line
	do
		if echo "$line" | grep -q '\[.*\]' ; then

			# New block starts here
			
			# Finish previous block processing
			if [ $block_has_smartpanel_entry = "0" -a "$block_no" != "0" ] ; then
				blocks_to_modify_numbers="$blocks_to_modify_numbers $block_no"
			fi

			# Start new block processing
			block_no=`expr $block_no + 1`
			block_has_smartpanel_entry=0
		elif echo "$line" | grep -q "${APP_FILENAME}" ; then
			block_has_smartpanel_entry=1
		fi
	done < $1

	# Finish the last block processing
	if [ $block_has_smartpanel_entry = "0" ] ; then
		blocks_to_modify_numbers="$blocks_to_modify_numbers $block_no"
	fi

	# Pass 2. Modify blocks found on pass 1.

	tmpfile=/tmp/session-manual.tmp
	echo -n "" > $tmpfile

	block_no=0
	block_needs_modification=0
	while read line
	do
		if echo "$line" | grep -q '\[.*\]' ; then

			# New block starts here
			
			# Start new block processing
			block_no=`expr $block_no + 1`
			if echo "$blocks_to_modify_numbers" | grep -qw "$block_no" ; then
				block_needs_modification=1
			else
				block_needs_modification=0
			fi
			echo "$line" >> $tmpfile
		elif echo "$line" | grep -q 'num_clients=' ; then
			if [ "$block_needs_modification" = "1" ] ; then
				ncln=`echo "$line" | awk -F= '{print $2}'`
				echo "num_clients=`expr $ncln + 1`" >> $tmpfile
				prepare_record "$ncln" "$tmpfile"
			else
				echo "$line" >> $tmpfile
			fi
		else
			echo "$line" >> $tmpfile
		fi
	done < $1

	cat $tmpfile > $1
	rm -f $tmpfile
}

process_folder()
{
	GNOME_DIR="$1"
	if test -f "$GNOME_DIR"/session-manual
	then
		process_session "$GNOME_DIR"/session-manual
	else
		#create new file...
		echo "[Default]" 		>  "$GNOME_DIR"/session-manual
		echo "num_clients=0" 	>>"$GNOME_DIR"/session-manual
		#...and work with it
		process_session "$GNOME_DIR"/session-manual
	fi
}

create_user_startup()
{
	HOME_DIR="$1"
	#echo "$HOME_DIR"	
	if test -d "$HOME_DIR"/.gnome2; then
		process_folder "$HOME_DIR"/.gnome2
	elif test -d "$HOME_DIR"/.gnome; then
		process_folder "$HOME_DIR"/.gnome
	fi

	# New GNOME autostart method
	test -d "$HOME_DIR/.config/autostart" || mkdir -p "$HOME_DIR/.config/autostart"
	create_app_desktop "$HOME_DIR/.config/autostart/Smartpanel${SUFFIX}.desktop"
}

create_GNOME_startup()
{	
	GID_MIN=`grep 'GID_MIN.*[0-9]' /etc/login.defs | grep -w GID_MIN | awk '{print $2}'` || GID_MIN=0
	GID_MAX=`grep 'GID_MAX.*[0-9]' /etc/login.defs | grep -w GID_MAX | awk '{print $2}'` || GID_MAX=100000

	for user in `cat /etc/passwd | awk -F : '{ if ($3 == 0 || ($3 >= '$GID_MIN' && $3 <= '$GID_MAX')) print $6 }' | sort | uniq`
	do
		create_user_startup $user
	done
}

process_autostart() 
{
	# GNOME Autostarts
	create_GNOME_startup

	# KDE Autostarts
	create_KDE_startup
}

append_categories() 
{
	if test -n "$1" ; then
		if echo "$LINUX_DIST" | grep -q "FEDORA_7_AND_ABOVE" ; then
			echo "Categories=Application;SystemSetup;X-${VENDOR}-Smartpanel;KDE;Core;" >> $1
		else
			echo "Categories=Application;SystemSetup;X-${VENDOR}-Smartpanel;" >> $1
		fi
	fi
}

write_directory_for_update_menus() {
	echo "?package(menu): charset=\"utf8\" section=\"/\" needs=\"x11\" title=\"${VENDOR} ${DESKTOP_APPNAME}\" icon=\"${DEST_PATH}/share/icons/sp_default.png\"" >> $1
}

write_entry_for_update_menus() {
	echo "?package(menu): charset=\"utf8\" command=\"$1\" section=\"${VENDOR} ${DESKTOP_APPNAME}/\" needs=\"x11\" title=\"$2\" icon=\"$3\"" >> $4
}

xdg_desktop_menu_submenu() {
# $1 - name
# $2 - comment
# $3 - path to icon
cat << EOF
[Desktop Entry]
Name=$1
Name[C]=$1
Comment=$2
Comment[C]=$2
Icon=$3
Type=Directory
EOF
}

xdg_desktop_menu_item() {
# $1 - name
# $2 - comment
# $3 - path to icon
# $4 - exec path
# $5 - path
cat << EOF
[Desktop Entry]
Name=$1
Name[C]=$1
Comment=$2
Comment[C]=$2
Type=Application
Icon=$3
Exec=$4
Path=$5
Terminal=0
TerminalOptions=
X-KDE-SubstituteUID=false
X-KDE-Username=
EOF
}

handle_menu_with_xdg_desktop_menu() {
	if [ -n "$INSIDE_UD" ] ; then 
		SUFFIX="UD"
	else
		SUFFIX="SM"
	fi

	ITEM_FILE_SUBMENU=/tmp/${VENDOR}-Smartpanel${SUFFIX}.directory
	ITEM_FILE_APP=/tmp/${VENDOR}-Smartpanel${SUFFIX}.desktop
	ITEM_FILE_UNINSTALL=/tmp/${VENDOR}-Smartpanel_un${SUFFIX}.desktop

	xdg_desktop_menu_submenu \
		"$PACKAGE_NAME" \
		"$PACKAGE_NAME" \
		"$APP_ICON" \
	> "$ITEM_FILE_SUBMENU"

	xdg_desktop_menu_item \
		"$PACKAGE_NAME" \
		"Manage your printers here" \
		"$APP_ICON" \
		"$APP_PATH" \
		"$APP_DIR" \
	> "$ITEM_FILE_APP"

	xdg_desktop_menu_item \
		"Uninstall $PACKAGE_NAME" \
		"$PACKAGE_NAME uninstallation script" \
		"$UNINSTALL_ICON" \
		"$UNINSTALL_PATH" \
		"$UNINSTALL_DIR" \
	> "$ITEM_FILE_UNINSTALL"

	DESKTOP_MENU_MODE=install
	xdg-desktop-menu $DESKTOP_MENU_MODE \
		"$ITEM_FILE_SUBMENU" \
		"$ITEM_FILE_APP" \
		"$ITEM_FILE_UNINSTALL" \
	|| echo "xdg-desktop-menu $DESKTOP_MENU_MODE <$ITEM_FILE_SUBMENU> <$ITEM_FILE_APP> <$ITEM_FILE_UNINSTALL> failed with code $?"

	rm -f \
		"$ITEM_FILE_SUBMENU" \
		"$ITEM_FILE_APP" \
		"$ITEM_FILE_UNINSTALL"

	# Workaround for xdg-desktop-menu on Fedora 7 and 8.
	# If xdg-desktop-menu is running from KDE desktop,
	# it does not create menu file for GNOME !

	if \
	  test -f /etc/kde/xdg/menus/applications-merged/${VENDOR}-${SUFFIX}.menu && \
	  test -d /etc/xdg/menus/applications-merged && \
	! test -f /etc/xdg/menus/applications-merged/${VENDOR}-${SUFFIX}.menu ; then
		cp -aL /etc/kde/xdg/menus/applications-merged/${VENDOR}-${SUFFIX}.menu \
			/etc/xdg/menus/applications-merged/
	fi
}

create_menu_with_update_menus() {

	ENTRY_DIR=/usr/lib/menu

	if [ -n "$INSIDE_UD" ] ; then 
		SUFFIX="UD"
	else
		SUFFIX="SM"
		rm -f $ENTRY_DIR/${VENDOR}_${SUFFIX}
		write_directory_for_update_menus $ENTRY_DIR/${VENDOR}_${SUFFIX}
	fi
	
	write_entry_for_update_menus \
		"$APP_PATH" \
		"$PACKAGE_NAME" \
		"$APP_ICON" \
		$ENTRY_DIR/${VENDOR}_${SUFFIX}

	write_entry_for_update_menus \
		"$UNINSTALL_PATH" \
		"Uninstall $PACKAGE_NAME" \
		"$UNINSTALL_ICON" \
		$ENTRY_DIR/${VENDOR}_${SUFFIX}
			
	#./vendormenu${PLSFX} $VENDOR -f1 /var/lib/menu-xdg/menus/applications-mdk.menu
	#add_directory_entry_mdk
	#add_desktop_entry_mdk /opt/$VENDOR/SmartPanel/bin/smartpanel "$PACKAGE_NAME"    /opt/$VENDOR/SmartPanel/share/icons/sp_default.png
	#add_desktop_entry_mdk /opt/$VENDOR/SmartPanel/uninstall.sh "Uninstall $PACKAGE_NAME" /opt/$VENDOR/SmartPanel/share/icons/uninstall.png
}

create_menu_entries_local() {
	mkdir -p $DEST_PATH/share/desktop-directories
	mkdir -p $DEST_PATH/share/applications

	SUFFIX="SM"
	create_desktop_directory         	$DEST_PATH/share/desktop-directories/${VENDOR}_${SUFFIX}.directory
	create_app_desktop 		$DEST_PATH/share/applications/Smartpanel${SUFFIX}.desktop
	append_categories               		$DEST_PATH/share/applications/Smartpanel${SUFFIX}.desktop
	create_uninstall_desktop             	$DEST_PATH/share/applications/Smartpanel_un${SUFFIX}.desktop
	append_categories               		$DEST_PATH/share/applications/Smartpanel_un${SUFFIX}.desktop
}

create_menu() 
{
	SUFFIX="SM"
	if [ -n "$INSIDE_UD" ] ; then SUFFIX="UD" ; fi
		
	if [ -d "$1" ] && mkdir -p "$1/${VENDOR}_${SUFFIX}" ; then
		
		if [ "$SUFFIX" = "SM" ] ; then create_desktop_directory $1/${VENDOR}_${SUFFIX}/.directory ; fi
		create_app_desktop $1/${VENDOR}_${SUFFIX}/Smartpanel${SUFFIX}.desktop
		create_uninstall_desktop    $1/${VENDOR}_${SUFFIX}/Smartpanel_un${SUFFIX}.desktop
	fi
}

create_menu_redhat89() 
{
	SUFFIX="SM"
	if [ -n "$INSIDE_UD" ] ; then		
		if  ! grep -q "$VENDOR Unified Driver" /etc/X11/desktop-menus/applications.menu ; then		
			echo "Can't find $VENDOR Unified Driver entry"
			return
		fi
		SUFFIX="UD"
	else		
		if ! grep -q "$VENDOR Smart Panel" /etc/X11/desktop-menus/applications.menu ; then
			./vendormenu${PLSFX} $VENDOR /etc/X11/desktop-menus/applications.menu
		fi
		create_desktop_directory $2/${VENDOR}_${SUFFIX}.directory
	fi
	
	create_app_desktop 	$1/${VENDOR}Smartpanel${SUFFIX}.desktop
	append_categories               	$1/${VENDOR}Smartpanel${SUFFIX}.desktop
	create_uninstall_desktop    	$1/${VENDOR}Smartpanel_un${SUFFIX}.desktop
	append_categories               	$1/${VENDOR}Smartpanel_un${SUFFIX}.desktop
}

create_menu_freedesktop() {
	SUFFIX="SM"
	if [ -n "$INSIDE_UD" ] ; then		
		if  ! grep -q "$VENDOR Unified Driver" /etc/xdg/menus/applications.menu ; then		
			echo "Can't find $VENDOR Unified Driver entry"
			return
		fi
		SUFFIX="UD"
	else
		if ! grep -q "$VENDOR Smart Panel" /etc/xdg/menus/applications.menu ; then
			./vendormenu${PLSFX} $VENDOR -f /etc/xdg/menus/applications.menu
		fi
		create_desktop_directory $2/${VENDOR}_${SUFFIX}.directory
	fi
	
	create_app_desktop   $1/${VENDOR}Smartpanel${SUFFIX}.desktop
	append_categories           $1/${VENDOR}Smartpanel${SUFFIX}.desktop
	create_uninstall_desktop    $1/${VENDOR}Smartpanel_un${SUFFIX}.desktop	
	append_categories           $1/${VENDOR}Smartpanel_un${SUFFIX}.desktop
}

create_menus()
{
	if test -n "`which xdg-desktop-menu 2> /dev/null`" ; then
		handle_menu_with_xdg_desktop_menu
		return
	fi

	if test -n "`which update-menus 2> /dev/null`" && ! echo "$LINUX_DIST" | grep -q "MANDRIVA_2007_AND_ABOVE" ; then
		create_menu_with_update_menus
		update-menus
		return
	fi

	if echo "$LINUX_DIST" | grep -q "UBUNTU\|MANDRIVA_2007_AND_ABOVE\|FEDORA_7_AND_ABOVE" ; then
		# Freedesktop.org Menu ( Both GNOME and KDE )
		if test -f /etc/xdg/menus/applications.menu ; then
			DIR_FILES_LOCATION=/usr/share/desktop-menu-files
			if test -d /usr/share/desktop-directories ; then
				DIR_FILES_LOCATION=/usr/share/desktop-directories
			fi
			create_menu_freedesktop /usr/share/applications $DIR_FILES_LOCATION
			return
		fi
	fi
	
	# GNOME Menu
	if test -d /usr/share/gnome/apps ; then
		create_menu /usr/share/gnome/apps
	elif test -d /etc/X11/applnk ; then
		create_menu /etc/X11/applnk
	fi

	# KDE Menu
	if test -f /etc/X11/desktop-menus/applications.menu ; then
		create_menu_redhat89 /usr/share/applications /usr/share/desktop-menu-files
	elif test -d /etc/opt/kde*/share/applnk/SuSE ; then
		create_menu /etc/opt/kde*/share/applnk/SuSE
	elif test -d /opt/kde*/share/applnk ; then
		create_menu /opt/kde*/share/applnk
	elif test -d /usr/share/applnk ; then
		if test -d /usr/share/applnk-mdk ; then
			create_menu /usr/share/applnk-mdk
			if test -d /var/lib/gnome/Mandrake ; then
				create_menu /var/lib/gnome/Mandrake
			fi
		else
			#create_menu /usr/share/applnk
			if ! test -d /etc/X11/applnk ; then
				# if no entries installed in /etc/X11/applnk only
				# This condition resolves duplicated menu
				# entries in Fedora 3,4
				create_menu /usr/share/applnk
			elif `cat /etc/issue | grep -q 'Fedora Core release [5-9]' 2> /dev/null` ; then
				# ... but in Fedora 5 (and above ?) we need these entries again
				create_menu /usr/share/applnk
			fi
		fi
	fi
}

if ! application_shutdown ; then
	echo "ERROR: Can't shutdown $APP_FILENAME! Installation is not possible!"
	exit
fi


process_autostart
create_menu_entries_local
create_menus

#change attributes
chown root $APP_PATH
chmod 4755 $APP_PATH

VERSION=`cat "$DEST_PATH/bin/.version"`
echo "INFO: $APP_FILENAME (ver.$VERSION) has been installed successfully in $DEST_PATH"
#x echo "--------------------------------------------------------------------------------"
echo "INFO: Starting $APP_FILENAME ..."

#DESKTOP_OWNER=`w -hsf | grep ':0' | awk '{print $1}'`
DESKTOP_OWNER=`w -hsf | awk '{if ($2==":0") { print $1; exit } }'`
if [ "$DESKTOP_OWNER" != "" ]; then
	su "$DESKTOP_OWNER" -c $APP_PATH &
else
	$APP_PATH &
fi
