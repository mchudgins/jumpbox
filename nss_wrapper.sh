#! /bin/sh
#
# setup nss wrapper
export FUBAR=if
if [ "`id -u`" -ne 0 ]; then
	export FUBAR=notRoot
else
	export FUBAR=root
fi
