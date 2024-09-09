#!/bin/sh
VENDOR=Samsung

BASE_DIR=`dirname "$0"`
cd "$BASE_DIR"

VENDOR_PATH=/opt/$VENDOR
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
DEST_PATH=$VENDOR_PATH/$DEST_DIRNAME

APP_DIR=$DEST_PATH/bin
APP_PATH=$APP_DIR/$APP_FILENAME
APP_ICON=$DEST_PATH/share/icons/sp_default.png

UNINSTALL_DIR=/opt/$VENDOR/$UNINSTALL_DIRNAME
UNINSTALL_PATH=$UNINSTALL_DIR/uninstall.sh
UNINSTALL_ICON=$DEST_PATH/share/icons/uninstall.png

# Linux distribution detection
ISSUE=`cat /etc/issue 2>/dev/null`
LINUX_DIST=
if ( echo $ISSUE | grep -q "Mandriva Linux release 200[7-9]\|Mandriva Linux release 20[1-9]" ); then
	LINUX_DIST="MANDRIVA_2007_AND_ABOVE"
elif ( echo $ISSUE | grep -q "Ubuntu" ); then
	LINUX_DIST="UBUNTU"
fi

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

remove_KDE_startup()
{
	if test -f /etc/opt/kde*/share/autostart/SuSE/smartpanel.desktop ; then
		rm -fr /etc/opt/kde*/share/autostart/SuSE/smartpanel.desktop
	elif test -f /opt/kde*/share/autostart/smartpanel.desktop ; then
		rm -fr /opt/kde*/share/autostart/smartpanel.desktop
	elif test -f /usr/share/autostart/smartpanel.desktop ; then
		rm -fr /usr/share/autostart/smartpanel.desktop
	fi
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

			# Start new block processing
			block_no=`expr $block_no + 1`
			block_has_smartpanel_entry=0
		elif echo "$line" | grep -q "${APP_FILENAME}" ; then
			if [ $block_has_smartpanel_entry = "0" -a "$block_no" != "0" ] ; then
				blocks_to_modify_numbers="$blocks_to_modify_numbers $block_no"
			fi
			block_has_smartpanel_entry=1
		fi
	done < $1

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
				ncln="`expr $ncln - 1`"
				echo "num_clients=$ncln" >> $tmpfile
			else
				echo "$line" >> $tmpfile
			fi
		else
			if [ "$block_needs_modification" = "1" ] ; then
				clnn=`echo "$line" | awk -F, '{print $1}'`
				# Put line of "other" client only
				if [ "$clnn" != "$ncln" ]; then
					echo "$line" >> $tmpfile
				fi 
			fi
		fi
	done < $1

	cat $tmpfile > $1
	rm -f $tmpfile
}

process_folder()
{
	GNOME_DIR="$1"
#	if test -f "$GNOME_DIR"/session
#	then
#		process_session "$GNOME_DIR"/session
#	elif test -f "$GNOME_DIR"/session-manual
	if test -f "$GNOME_DIR"/session-manual
	then
		process_session "$GNOME_DIR"/session-manual
	fi
}

remove_user_startup()
{
	HOME_DIR="$1"
	if test -d "$HOME_DIR"/.gnome2; then
		process_folder "$HOME_DIR"/.gnome2
	elif test -d "$HOME_DIR"/.gnome; then
		process_folder "$HOME_DIR"/.gnome
	fi

	# New GNOME autostart method
	rm -f "$HOME_DIR/.config/autostart/Smartpanel${SUFFIX}.desktop"
}

remove_GNOME_startup()
{	
	GID_MIN=`grep 'GID_MIN.*[0-9]' /etc/login.defs | grep -v 'SYSTEM_GID_MIN' | awk '{print $2}'` || GID_MIN=0
	GID_MAX=`grep 'GID_MAX.*[0-9]' /etc/login.defs | grep -v 'SYSTEM_GID_MAX' | awk '{print $2}'` || GID_MAX=100000
		
	for user in `cat /etc/passwd | awk -F : '{ if ($3 == 0 || ($3 >= '$GID_MIN' && $3 <= '$GID_MAX')) print $6 }' | sort | uniq`
	do
		remove_user_startup $user
	done	
}


remove_autostart() 
{
	# GNOME Autostarts
	remove_GNOME_startup

	# KDE Autostarts
	remove_KDE_startup
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

remove_menu_with_xdg_desktop_menu() {
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

	DESKTOP_MENU_MODE=uninstall
	xdg-desktop-menu $DESKTOP_MENU_MODE \
		"$ITEM_FILE_SUBMENU" \
		"$ITEM_FILE_APP" \
		"$ITEM_FILE_UNINSTALL" \
	|| echo "xdg-desktop-menu $DESKTOP_MENU_MODE failed with code $?"

	rm -f \
		"$ITEM_FILE_SUBMENU" \
		"$ITEM_FILE_APP" \
		"$ITEM_FILE_UNINSTALL"

	rm -f	/etc/kde/xdg/menus/applications-merged/${VENDOR}-Smartpanel${SUFFIX}.menu \
		/etc/xdg/menus/applications-merged/${VENDOR}-Smartpanel${SUFFIX}.menu
}

remove_menu() 
{
	SUFFIX="SM"
	if [ -n "$INSIDE_UD" ] ; then SUFFIX="UD" ; fi

	if [ "$SUFFIX" = "SM" ] ; then 
		rm -rf $1/${VENDOR}_${SUFFIX}
	else
		rm -rf $1/${VENDOR}_${SUFFIX}/Smartpanel${SUFFIX}.desktop
		rm -rf $1/${VENDOR}_${SUFFIX}/Smartpanel_un${SUFFIX}.desktop
	fi
}

remove_menu_redhat89() 
{
	SUFFIX="SM"
	if [ -n "$INSIDE_UD" ] ; then		
# 		if  ! grep -q "$VENDOR Unified Driver" /etc/X11/desktop-menus/applications.menu ; then		
# 			echo "Can't find $VENDOR Unified Driver entry"
# 			return
# 		fi
		SUFFIX="UD"
	else		
#		if  grep -q "$VENDOR Smart Panel" /etc/X11/desktop-menus/applications.menu ; then
			rm -rf $2/${VENDOR}_${SUFFIX}.directory
#		fi
	fi
	
	rm -rf $1/${VENDOR}Smartpanel${SUFFIX}.desktop
	rm -rf $1/${VENDOR}Smartpanel_un${SUFFIX}.desktop		
}

remove_menu_freedesktop()
{
	SUFFIX="SM"
	if [ -n "$INSIDE_UD" ] ; then
		SUFFIX="UD"
	else
		rm -rf $2/${VENDOR}_${SUFFIX}.directory
	fi
	
	rm -rf $1/${VENDOR}Smartpanel${SUFFIX}.desktop
	rm -rf $1/${VENDOR}Smartpanel_un${SUFFIX}.desktop			
}

remove_strings_containig_pattern() {

	GPAT=""
	for w in $2 ; do
		GPAT="${GPAT}${w}"
		if [ "$w" != "$3" ]; then
			GPAT="${GPAT}\ "
		fi
	done

	test -n "$1" || return
	test -n "$2" || return
	TMP_FILE_RSP=/tmp/`basename $1`-rsp.tmp
	cat $1 | grep -v "$GPAT" > $TMP_FILE_RSP
	cat $TMP_FILE_RSP > $1
	rm -f $TMP_FILE_RSP
}

remove_menu_mandriva() {

	MENUDRAKE_FILE="/etc/menu/menudrakeentry"
	remove_strings_containig_pattern "$MENUDRAKE_FILE" "$PACKAGE_NAME"
}

write_directory_for_update_menus() {
	echo "?package(menu): charset=\"utf8\" section=\"/\" needs=\"x11\" title=\"$VENDOR $DESKTOP_DIRNAME\" icon=\"$DEST_PATH/share/icons/sp_default.png\"" >> $1
}

write_entry_for_update_menus() {
	echo "?package(menu): charset=\"utf8\" command=\"$1\" section=\"$VENDOR $DESKTOP_DIRNAME/\" needs=\"x11\" title=\"$2\" icon=\"$3\"" >> $4
}

handle_menu_with_update_menus() {

	ENTRY_DIR=/usr/lib/menu

	SUFFIX="SM"
	if [ -n "$INSIDE_UD" ] ; 
	then 
		SUFFIX="UD"
		## # BIG WARNING : CURRENT CONDITION IS NOT USED NOW, BUT IT IS NOT WORKING PROPERLY. 
		## # TODO: REMOVE LINES, WHICH WAS ADDED BY write_entry_for_update_menus FROM INSTALL.SH
		remove_strings_containig_pattern $ENTRY_DIR/${VENDOR}_${SUFFIX} "$PACKAGE_NAME"
	else
		SUFFIX="SM"
		rm -f $ENTRY_DIR/${VENDOR}_${SUFFIX}
	fi
}

remove_menus()
{	
	if test -n "`which xdg-desktop-menu 2> /dev/null`" ; then
		remove_menu_with_xdg_desktop_menu
		return
	fi

	if test -n "`which update-menus 2> /dev/null`" && ! echo "$LINUX_DIST" | grep -q "MANDRIVA_2007_AND_ABOVE" ; then
		handle_menu_with_update_menus
		update-menus
		return
	fi
	
	if echo "$LINUX_DIST" | grep -q "UBUNTU\|MANDRIVA_2007_AND_ABOVE" ; then
		# Freedesktop.org Menu ( Both GNOME and KDE )
		if test -f /etc/xdg/menus/applications.menu ; then
			DIR_FILES_LOCATION=/usr/share/desktop-menu-files
			if test -d /usr/share/desktop-directories ; then
				DIR_FILES_LOCATION=/usr/share/desktop-directories
			fi
		remove_menu_freedesktop /usr/share/applications $DIR_FILES_LOCATION
		return
		fi
	fi
	
	# GNOME Menu
	if test -d /usr/share/gnome/apps ; then
		remove_menu /usr/share/gnome/apps
	elif test -d /etc/X11/applnk ; then
		remove_menu /etc/X11/applnk
	fi

	# KDE Menu
	if test -f /etc/X11/desktop-menus/applications.menu ; then
		remove_menu_redhat89 /usr/share/applications /usr/share/desktop-menu-files
	elif test -d /etc/opt/kde*/share/applnk/SuSE ; then
		remove_menu /etc/opt/kde*/share/applnk/SuSE
	elif test -d /opt/kde*/share/applnk ; then
		remove_menu /opt/kde*/share/applnk
	elif test -d /usr/share/applnk ; then
		if test -d /usr/share/applnk-mdk ; then
			remove_menu /usr/share/applnk-mdk
			if test -d /var/lib/gnome/Mandrake ; then
				remove_menu /var/lib/gnome/Mandrake
			fi
		else
			remove_menu /usr/share/applnk
		fi
	fi
}

if ! application_shutdown ; then
	echo "ERROR: Can't shutdown $APP_FILENAME! Uninstallation is not possible!"
	exit
fi

remove_autostart
remove_menus

VERSION=`cat "$DEST_PATH/bin/.version"`
if rm -fr "$DEST_PATH"
then
	echo "INFO: $APP_FILENAME (ver.$VERSION) has been uninstalled successfully"	
else
	echo "ERROR: Cannot uninstall $APP_FILENAME! Check your permissions."
fi

# remove vendor folder if it is empty
rmdir "$VENDOR_PATH" 2>/dev/null
