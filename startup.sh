#! /bin/sh
### BEGIN INIT INFO
# Provides:          okdocd
# Required-Start:    $syslog $remote_fs
# Required-Stop:     $syslog $remote_fs
# Should-Start:      $local_fs
# Should-Stop:       $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Markdown files server.    
# Description:       Markdown files server. 
### END INIT INFO

# Author: Wang Tong <iwangtongi@163.com>

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
NAME=okdoc
DAEMON=/home/king/Nutstore/okdoc/bin/okdocd
DAEMON_ARGS="--options args"
RUNDIR=/var/run/okdocd
PIDFILE=$RUNDIR/okdocd.pid
INITSCRIPT=/etc/init.d/$NAME

if [ ! -x "$DAEMON" ]
then
    echo "$DAEMON not exits"
    exit 1
fi

[ -r /etc/default/$NAME ] && . /etc/default/$NAME

. /lib/lsb/init-functions

set -e

case "$1" in
    start)
        echo -n "Starting $NAME: "
        mkdir -p $RUNDIR
        touch $PIDFILE
        chown king:king $RUNDIR $PIDFILE
        chmod 755 $RUNDIR

        if start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON -- $DAEMON_ARGS
        then
            echo "OK"
            log_end_msg 0 || true
        else
            echo "failed"
            log_end_msg 1 || true
        fi
        ;;
    stop)
        echo -n "Stopping $NAME: "
        if start-stop-daemon --stop --quiet --pidfile $PIDFILE --exec $DAEMON
        then
            echo "OK"
        else
            echo "failed"
        fi
        rm -f $PIDFILE
        sleep 1
        ;;
    restart|force-reload)
        ${0} stop
        ${0} start
        ;;
    status)
        echo -n "$NAME is "
        if start-stop-daemon --stop --quiet --signal 0 --exec $DAEMON --pidfile $PIDFILE
        then
            echo "running"
        else
            echo "not running"
            exit 1
        fi
    ;;
    *)
        echo "Usage: $INITSCRIPT {start|stop|restart|force-reload|status}" >&2
        exit 1
        ;;
esac

exit 0
