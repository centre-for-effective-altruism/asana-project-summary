#!/bin/sh

# authorize b2
b2 authorize-account $B2_KEY_ID $B2_APPLICATION_KEY

# start cron
/usr/sbin/crond -f -l 8
