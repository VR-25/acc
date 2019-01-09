#!/system/bin/sh
# Advanced Charging Controller Daemon (accd) Starter
# Copyright (C) 2017-2019, VR25 @ xda-developers
# License: GPL V3+

modId=acc
modPath=/system/etc/$modId
[ -e $modPath/module.prop ] || modPath=/sbin/.magisk/img/$modId
[ -e $modPath/module.prop ] || modPath=/sbin/.core/img/$modId
unset modId

(sh $modPath/accd &) &
