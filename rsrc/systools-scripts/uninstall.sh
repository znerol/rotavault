#!/bin/sh

echo "Unloading launchd job for privelegd helper tool ch.znerol.rotavault" >&2
/bin/launchctl unload /Library/LaunchDaemons/ch.znerol.rotavault.plist

echo "Removing rights introduced by rotavault system tools installer from authorization database" >&2
/usr/bin/security authorizationdb remove ch.znerol.rotavault.monitor >/dev/null 2>&1
/usr/bin/security authorizationdb remove ch.znerol.rotavault.manage >/dev/null 2>&1

echo "Removing files referenced by rotavault system tools package" >&2
/usr/sbin/pkgutil --force --unlink ch.znerol.rotavault.systools
/usr/sbin/pkgutil --force --forget ch.znerol.rotavault.systools
