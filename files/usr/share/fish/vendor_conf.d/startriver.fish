[ -z $DISPLAY ] && [ (tty) = /dev/tty ] && status --is-login && exec river &> /tmp/river.log
