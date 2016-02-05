#! /bin/sh
# Install startup script on Linux for okdocd daemon.

if [ ! $UID -eq 0 ]
then
	echo "Permission denied"
	exit 1
fi

USER=king
GROUP=king
NAME=okdoc
BIN=bin
NIMCACHE=src/nimcache
SOURCE=src/okdocd
DAEMON=bin/okdocd
STARTUPSCRIPT=startup.sh
INITSCRIPT=/etc/init.d/$NAME

if [ ! -e $BIN ]
then
	mkdir $BIN
fi
chown $USER:$GROUP $BIN
chmod 0775 $BIN

echo "OKDOC: nim c --define:release $SOURCE => $DAEMON"
nim c --define:release --hints:off --warnings:off $SOURCE > /dev/null
rm -R $NIMCACHE
mv $SOURCE $DAEMON
chown $USER:$GROUP $DAEMON
chmod 0755 $DAEMON

echo "OKDOC: cat startup.sh > /etc/init.d/$NAME"
touch $INITSCRIPT
chmod 755 $INITSCRIPT
cat $STARTUPSCRIPT > $INITSCRIPT

echo "OKDOC: update-rc.d $NAME start 98 2 3 4 5 . stop 98 0 1 6 ."
update-rc.d $NAME start 98 2 3 4 5 . stop 98 0 1 6 .

exit 0


