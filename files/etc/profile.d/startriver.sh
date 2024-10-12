#!/bin/sh

if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec river &> /tmp/river.log
fi
