#!/system/bin/sh
# Advanced Charging Controller Daemon (accd) Starter
# Copyright (C) 2017-2019, VR25 @ xda-developers
# License: GPL V3+

modId=acc

# don't run more than once per boot session
[ -d /dev/$modId ] && exit 0 || mkdir -p /dev/modId

modPath=/system/etc/$modId
[ -f $modPath/module.prop ] || modPath=/sbin/.magisk/img/$modId
[ -f $modPath/module.prop ] || modPath=/sbin/.core/img/$modId
unset modId

(sh $modPath/accd &) &
