[ -z $DISPLAY ] && [ (tty) = /dev/tty1 ] && status --is-login && exec river &> /tmp/river.log
