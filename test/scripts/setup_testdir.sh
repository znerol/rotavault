#!/bin/bash

# exit immediately if some command fails
set -e

function usage() {
    echo 'Usage: [-b block-count] [-s src-name.dmg] [-a] [-t target-name.dmg] [-m]'
    exit ${1-0}
}

while getopts  "abms:t:h" OPT; do
    case "$OPT"
    in
        a)
            ATTACH=true;;
        b)
            SECTORS="$OPTARG";;
        m)
            MOUNTTARGET=true;;
        s)
            SOURCENAME="$OPTARG";;
        t)
            TARGETNAME="$OPTARG";;
        h)
            usage;;
        ?)
            usage 2;;
    esac
done

# setup temporary directory
TEMPDIR=$(mktemp -d "/tmp/testdir.XXXXXXXX")
echo "$TEMPDIR"

# setup source image, print absolute path to image and plist if -a is given
SECTORS="${SECTORS-2000}"
if [ -n "$SOURCENAME" ]; then
    hdiutil create -sectors "$SECTORS" -fs HFS+ -layout NONE "$TEMPDIR/$SOURCENAME" > /dev/null
    echo "$TEMPDIR/$SOURCENAME"
    if [ -n "$ATTACH" ]; then
        DEVMNT=$(hdiutil attach "$TEMPDIR/$SOURCENAME")
        SOURCEDEV="${DEVMNT%% *}"
        SOURCEMOUNT="/Volumes/${DEVMNT#*/Volumes/}"
        echo $SOURCEDEV
        echo "$SOURCEMOUNT"
    fi
fi

# setup target image, print absolute path to image and plist if -a is given
if [ -n "$TARGETNAME" ]; then
    hdiutil create -sectors "$SECTORS" -fs HFS+ -layout NONE "$TEMPDIR/$TARGETNAME" > /dev/null
    echo "$TEMPDIR/$TARGETNAME"
    if [ -n "$ATTACH" ]; then
        TARGETDEV=$(hdiutil attach "$TEMPDIR/$TARGETNAME" -nomount)
        echo $TARGETDEV
        if [ -n "$MOUNTTARGET" ]; then
            read -p "Hit any key to mount target" -n 1 -s && echo >&2
            DEVMNT=$(hdiutil mount $TARGETDEV)
            TARGETDEV="${DEVMNT%% *}"
            TARGETMOUNT="/Volumes/${DEVMNT#*/Volumes/}"
            echo $TARGETMOUNT
        fi
    fi
fi

read -p "Hit any key to begin cleanup" -n 1 -s && echo >&2

# cleanup
if [ -n "$SOURCEDEV" ]; then
    diskutil eject $SOURCEDEV > /dev/null
fi
if [ -n "$TARGETDEV" ]; then
    diskutil eject $TARGETDEV > /dev/null
fi
rm -rf "$TEMPDIR"
exit 0
