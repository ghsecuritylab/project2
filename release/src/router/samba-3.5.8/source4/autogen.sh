#!/bin/sh

# Run this script to build samba from git.

while true; do
    case $1 in
	--version-file)
	    VERSION_FILE=$2
	    shift 2
	    ;;
	*)
	    break
	    ;;
    esac
done

## insert all possible names (only works with
## autoconf 2.x)
TESTAUTOHEADER="autoheader autoheader-2.53 autoheader2.50 autoheader259 autoheader253"
TESTAUTOCONF="autoconf autoconf-2.53 autoconf2.50 autoconf259 autoconf253"

AUTOHEADERFOUND="0"
AUTOCONFFOUND="0"

if which which > /dev/null 2>&1; then
        echo -n
else
	echo "$0: need 'which' to figure out if we have the right autoconf to build samba from git" >&2
	exit 1
fi
##
## Look for autoheader
##
for i in $TESTAUTOHEADER; do
	if which $i > /dev/null 2>&1; then
		if test `$i --version | head -n 1 | cut -d.  -f 2 | sed "s/[^0-9]//g"` -ge 53; then
			AUTOHEADER=$i
			AUTOHEADERFOUND="1"
			break
		fi
	fi
done

##
## Look for autoconf
##

for i in $TESTAUTOCONF; do
	if which $i > /dev/null 2>&1; then
		if test `$i --version | head -n 1 | cut -d.  -f 2 | sed "s/[^0-9]//g"` -ge 53; then
			AUTOCONF=$i
			AUTOCONFFOUND="1"
			break
		fi
	fi
done


##
## do we have it?
##
if test "$AUTOCONFFOUND" = "0" -o "$AUTOHEADERFOUND" = "0"; then
	echo "$0: need autoconf 2.53 or later to build samba from git" >&2
	exit 1
fi

echo "$0: running script/mkversion.sh"
./script/mkversion.sh $VERSION_FILE || exit 1

rm -rf autom4te*.cache
rm -f configure include/config_tmp.h*

IPATHS="-I. -I../lib/replace"

echo "$0: running $AUTOHEADER $IPATHS"
$AUTOHEADER $IPATHS || exit 1

echo "$0: running $AUTOCONF $IPATHS"
$AUTOCONF $IPATHS || exit 1

rm -rf autom4te*.cache

echo "Now run ./configure (or ./configure.developer) and then make."
exit 0
