#!/bin/bash

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

echo "Applying kiwiirc-jitsi-meet-tokens.patch to /usr/share/jitsi-meet/prosody-plugins/"
echo "..."
PATCHDIR=`pwd`
cd /usr/share/jitsi-meet/prosody-plugins/
git apply $PATCHDIR/kiwiirc-jitsi-meet-tokens.patch
echo "Done!"
