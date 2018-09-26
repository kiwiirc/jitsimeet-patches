#!/bin/bash

MINVER=1.0.2942-1

echo "Kiwi patcher for Jitsi Meet Tokens"
echo ""

if [ ! -f "kiwiirc-jitsi-meet-tokens.patch" ] ; then
	echo "error: kiwiirc-jitsi-meet-tokens.patch not found!"
	exit 1
fi

if [ ! -d "/usr/share/jitsi-meet/prosody-plugins/" ] ; then
	echo "error: /usr/share/jitsi-meet/prosody-plugins/ not found!"
	exit 1
fi

if [ ! `dpkg -l jitsi-meet-tokens | grep ii | wc -l` = 1 ] ; then
	echo "error: requires jitsi-meet-tokens package version >= 1.0.2942 and < 1.1.0"
	exit 1
fi

TVER=`dpkg -s jitsi-meet-tokens | grep Version | cut -f 2 -d " "`

dpkg --compare-versions $MINVER le $TVER
if [ $? = 1 ] ; then
	echo "error: requires jitsi-meet-tokens package version >= 1.0.2942 and < 1.1.0"
	exit 1
fi

dpkg --compare-versions 1.1.0 gt $TVER
if [ $? = 1 ] ; then
	echo "error: requires jitsi-meet-tokens package version >= 1.0.2942 and < 1.1.0"
	exit 1
fi


echo "Applying kiwiirc-jitsi-meet-tokens.patch to /usr/share/jitsi-meet/prosody-plugins/"
echo "..."
PATCHDIR=`pwd`
cd /usr/share/jitsi-meet/prosody-plugins/
git apply $PATCHDIR/kiwiirc-jitsi-meet-tokens.patch
echo "Done!"
