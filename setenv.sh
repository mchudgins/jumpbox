#! /bin/sh

export TERM=xterm

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group
envsubst < /usr/local/etc/passwd.template > /tmp/passwd
