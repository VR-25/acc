# Advanced Charging Controller (ACC)


---
- [DESCRIPTION](#description)
- [LICENSE](#license)
- [CLAUSE DE NON-RESPONSABILITÉ](#clause-de-non-responsabilité)
- [AVERTISSEMENTS](#avertissements)
- [DONATIONS](#donations)
- [PRÉREQUIS](#prérequis)
- [GUIDE DE DÉMARAGE RAPIDE](#guide-de-démarage-rapide)
  - [Notes](#notes)
- [CONSTRUIRE ET/OU INSTALLER DEPUIS LA SOURCE](#construire-etou-installer-depuis-la-source)
  - [Dépendances (construction)](#dépendances-construction)
  - [Construire des Tarballs et des Zips Flashables](#construire-des-tarballs-et-des-zips-flashables)
    - [Notes](#notes-1)
  - [Installer depuis la Source Locale ou Github](#installer-depuis-la-source-locale-ou-github)
    - [Notes](#notes-2)
- [CONFIGURATION PAR DÉFAUT](#configuration-par-défaut)
- [SETUP/USAGE](#setupusage)
  - [Commandes du Terminal](#commandes-du-terminal)
- [PLUGINS](#plugins)
- [NOTES/TIPS FOR FRONT-END DEVELOPERS](#notestips-for-front-end-developers)
  - [Basics](#basics)
  - [Installing/Upgrading ACC](#installingupgrading-acc)
  - [Uninstalling ACC](#uninstalling-acc)
  - [Initializing ACC](#initializing-acc)
  - [Managing ACC](#managing-acc)
  - [The Output of --info](#the-output-of---info)
  - [Profiles](#profiles)
  - [More](#more)
- [TROUBLESHOOTING](#troubleshooting)
  - [`acc -t` Results Seem Inconsistent](#acc--t-results-seem-inconsistent)
  - [Battery Capacity (% Level) Doesn't Seem Right](#battery-capacity--level-doesnt-seem-right)
  - [Charging Switch](#charging-switch)
  - [Custom Max Charging Voltage And Current Limits](#custom-max-charging-voltage-and-current-limits)
  - [Diagnostics/Logs](#diagnosticslogs)
  - [Finding Additional/Potential Charging Switches Quickly](#finding-additionalpotential-charging-switches-quickly)
  - [Install, Upgrade, Stop and Restart Processes Seem to Take Too Long](#install-upgrade-stop-and-restart-processes-seem-to-take-too-long)
  - [Restore Default Config](#restore-default-config)
  - [Samsung, Charging _Always_ Stops at 70% Capacity](#samsung-charging-always-stops-at-70-capacity)
  - [Slow Charging](#slow-charging)
  - [Unable to Charge](#unable-to-charge)
  - [Unexpected Reboots](#unexpected-reboots)
  - [WARP, VOOC and Other Fast Charging Tech](#warp-vooc-and-other-fast-charging-tech)
  - [Why Did accd Stop?](#why-did-accd-stop)
- [POWER SUPPLY LOGS (HELP NEEDED)](#power-supply-logs-help-needed)
- [LOCALIZATION](#localization)
- [TIPS](#tips)
  - [_Always_ Limit the Charging Current If Your Battery is Old and/or Tends to Discharge Too Fast](#always-limit-the-charging-current-if-your-battery-is-old-andor-tends-to-discharge-too-fast)
  - [Current and Voltage Based Charging Control](#current-and-voltage-based-charging-control)
  - [Generic](#generic)
  - [Google Pixel Devices](#google-pixel-devices)
  - [Idle Mode and Alternatives](#idle-mode-and-alternatives)
- [FREQUENTLY ASKED QUESTIONS (FAQ)](#frequently-asked-questions-faq)
- [LINKS](#links)


---
## DESCRIPTION

ACC est un logiciel Android conçu principalement pour [étendre la durée de service le la batterie](https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries).
En un mot, ceci est réalisé en limitant le courant de charge, la température et le voltage.
Toutes les solutions de root sont supportés.
Sans prêter attention au fait que le système est rooté avec Magisk, l'installation est toujours "sans système".


---
## LICENSE

Copyright 2017-2023, VR25

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.


---
## CLAUSE DE NON-RESPONSABILITÉ

Toujours lire/relire cette référence avant d'installer/mettre à jource logiciel.

Alors qu'aucun chat n'a été blessé, l'auteur n'assume en aucun cas la responsabilté pour tout ce qui pourraît se casser due à l'utilisation/abus de ce logiciel.

Pour prévenir la fraude, ne JAMAIS partager de lien associé avec ce projet.
Ne JAMAIS partager les builds (tar/zip) ! Partagez le lien officiel à la place.


---
## AVERTISSEMENTS

ACC manipule des paramètres profonds d'Android ([kernel](https://duckduckgo.com/lite/?q=kernel+android)) qui contrôlent les circuits de charge.
L'auteur n'assume en aucun cas la responsabilté pour tout ce qui pourraît se casser due à l'utilisation/abus de ce logiciel.
Par le choix de l'utiliser/abuser, vous acceptez de l'utiliser à vos risques et périls !

Certains appareils, notamment les Xiaomi, ont un PMIC (Power Management Integrated Circuit (Circuit Intégré de Gestion de l'Alimentation)) défectueux qui peut être déclanché pas acc.
Le problème bloque la charge.
Assurez-vous que votre batterie ne se décharge pas trop bas.
Utiliser la fonction d'auto-extinction est fortement recomandée.

Se référer à [ce post XDA ](https://forum.xda-developers.com/t/rom-official-arrowos-11-0-android-11-0-vayu-bhima.4267263/post-85119331) pour plus de détails.

[lybxlpsv](https://github.com/lybxlpsv) suggère de démarrer dans le bootloader et de retourner ensuite dans le système pour réinitialiser le PMIC.


---
## DONATIONS

S'il vous plaît, supportez le projet avec des dons ([liens](#links) en bas).
Avec le projet qui grandit et qui devient plus populaire, le besoin de café augmente aussi


---
## PRÉREQUIS

- [Lire - comment prolonger la durée de vie des batteries lithium-ion (anglais)](https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries)
- Android ou un OS basé sur Android
- N'importe quelle solution de root (ex, [Magisk](https://github.com/topjohnwu/Magisk))
- [Busybox\*](https://github.com/Magisk-Modules-Repo/busybox-ndk) (seulement si non rooté avec Magisk)
- Les utilisateurs sans Magisk peuvent activer acc auto-start en lançant /data/adb/vr25/acc/service.sh, une copie de, ou un lien vers lui - avec init.d ou une app qui l'émule.
- Un émulateur de terminal
- Un éditeur de texte (optionnel)

\* un binaire busybox peut simplement être placé dans /data/adb/vr25/bin/.
Permissions (0755) sont mises automatiquement si besoin.
Priorité: /data/adb/vr25/bin/busybox > busybox Magisk > busybox système

D'autres exécutables ou binaires statiques peuvent aussi être placés dans /data/adb/vr25/bin/ (avec des autorisations appropriés) au lieu d'être installé à l'échelle du système.


---
## GUIDE DE DÉMARAGE RAPIDE


0. Toutes les commandes/actions on besoin d'un accès root.

1. Installer/mettre à jour: flasher\* le zip ou utiliser une app "front-end".
Il y a deux manières additionnelles  pour mettre à jour: `acc --upgrade` (en ligne) et `acc --flash` (flash zip).
Redémarrer après l'installation/désinstallation est généralement non-nécessaire.

2. [Optionnel] lancer `acc` (assistant). C'est la seule commande dont vous aurez besoin de vous souvenir.

3. [Optionnel] lancer `acc pause_capacity resume_capacity` (défaut `75 70`) pour définir les niveaux de charge auquels le chargement s'arrêtera et reprendra, respectivement.

4. Si vous avez quelquonque problème, référez-vous à [dépanage](#troubleshooting), [tips](#tips) et [FAQ](#frequently-asked-questions-faq)
Lisez le plus possible avant de reporter une issue et/ou de poser des questions.
Souvent, les solutions/réponses seront sous vos yeux.


### Notes

Les étapes `2` et `3` sont optionnelles car ce sont des paramètres par défaut.
Pour plus de détails, se référer à la [configuration par défaut](#default-configuration) plus bas.
Les utilisateurs sont encouragés à essayer l'étape `2` - pour se familiariser avec les options disponibles.

Les paramètres peuvent s'écraser. Commencez avec ce que vous comprenez.
La configuration par défaut vous couvre.
Ne croyez pas que vous avez besoin de tout configurer. Vous devriez l'éviter de toute façon - à moins que vous sachiez ce que vous faites.

Désinstallation: lancer `acc --uninstall` ou flasher\* `/data/adb/vr25/acc-data/acc-uninstaller.zip`.

ACC fonctionne également dans certains environements de récupération.
À moins que le zip ne soit à nouveau flashé, une initialisation manuelle est requise.
La commande d'initialisation est `/data/adb/vr25/acc/service.sh`.


---
## CONSTRUIRE ET/OU INSTALLER DEPUIS LA SOURCE


### Dépendances (construction)

- git, wget, ou curl
- zip


### Construire des Tarballs et des Zips Flashables

1. Télécharger et extraire le code source : `git clone https://github.com/VR-25/acc.git`
ou `wget  https://github.com/VR-25/acc/archive/master.tar.gz -O - | tar -xz`
ou `curl -L#  https://github.com/VR-25/acc/archive/master.tar.gz | tar -xz`

2. `cd acc*`

3. `sh build.sh` (ou double cliquer `build.bat` sur Windows 10, si vous avez WSL (Windows subsystem for Linux) (avec zip) d'installé)


#### Notes

- build.sh définit/change automatiquement `id=*` dans les fichiers `*.sh` et `update-binary`.
Se référer à framework-details.txt pour une liste entière des tâches qu'il exécute.
Pour passer la génération des archives, lancer le script de construction avec un argument aléatoire. (ex,`bash build.sh h`)
- Pour mettre à jour le code source local, exécuter `git pull --force` ou le retélécharger (avec wget/curl) comme expliqué au-dessus.


### Installer depuis la Source Locale ou Github

- `[export installDir=<répertoire d'installation parrent>] sh install.sh` installe acc depuis la source extraite.

- `sh install-online.sh [-c|--changelog] [-f|--force] [-k|--insecure] [-n|--non-interactive] [%répertoire d'installation parrent%] [commit]` télécharge et installe acc depuis github - ex, `sh install-online.sh dev`.
L'ordre des arguments n'a pas d'importance.
Pour les mises à jour, si `%répertoire d'installation parrent%` n'est pas donné, le répertoire actuel/original est utilisé.

- `sh install-tarball.sh [module id, défaut: acc] [répertoire d'installation parrent (ex, /data/data/mattecarra.accapp/files)]` installe le tarball (acc*gz) à partir de l'emplacement du script.
L'archive doit être dans le même répertoire que le script - et obtenue via Github : https://github.com/VR-25/acc/archive/$commit.tar.gz (exemples de commit: master, dev, v2020.5.20-rc).


#### Notes

- `install-online.sh` est l'équivalent de `acc --upgrade`.

- Les répertoires d'installation par défaut , dans l'ordre des priorités, sont : `/data/data/mattecarra.accapp/files/` (ACC App, mais seulement si Magisk n'est pas inatallé), `/data/adb/modules/` (Magisk) et `/data/adb/` (autres solutions de root).

- Aucun argument/option n'est obligatoire.
`--non-interactive` est une exeption pour les applications "front-end".

- L'option `--force` de `install-online.sh` est demandée pour une réinstallation et un rétrogradation.

- `sh install-online.sh --changelog --non-interactive` affiche le numéro de vertion (nombre entier) et l'URL du journal des modifications (chaîne de caractères), quand une mise à jour est disponible.
En mode interactif, il demande également à l'utilisateur s'il souhaite télécharger et installer la mise à jour.

- Vous pouvez aussi lire les [Commandes du Terminal](#commandes-du-terminal) > `Codes de sortie` plus bas.


---
## CONFIGURATION PAR DÉFAUT
```
#DC#

configVerCode=202206100

capacity=(-1 60 70 75 false false)

temperature=(40 60 90 65)

cooldownRatio=()
cooldownCurrent=
cooldownCustom=()

resetBattStats=(false false false)

chargingSwitch=()

applyOnBoot=()

applyOnPlug=()

maxChargingCurrent=()

maxChargingVoltage=()

language=

runCmdOnPause=''

ampFactor=
voltFactor=

prioritizeBattIdleMode=false
currentWorkaround=false
battStatusWorkaround=true

schedule=''

battStatusOverride=''

rebootResume=false

dischargePolarity=

: one-line script sample; echo nothing >/dev/null


# WARNINGS

# Do not edit this in Windows Notepad, ever!
# It replaces LF (Linux/Unix) with CRLF (Windows) line endings.

# As you may have guessed, what is null by default, can be null.
# "language=" is interpreted as "language=en".
# Nullifying values that should not be null causes unexpected behavior.
# However, doing so with "--set var=" restores the default value of "var".
# In other words, for regular users, "--set" is safer than modifying the config file directly.

# Do not feel like you must configure everything!
# Do not change what you don't understand.


# NOTES

# The daemon does not have to be restarted after making changes to this file - unless one of the changes is charging_switch.

# A change to current_workaround (cw) only takes effect after an acc [re]initialization (install, upgrade or "accd --init") or system reboot.

# If those 2 variables are updated with "acc --set" (not acca --set), accd is restarted automatically (--init is implied, as needed).

# The only nullable variables are those which are null by default (var=, var="" and var=()).


# BASICS

# capacity=(shutdown_capacity cooldown_capacity resume_capacity pause_capacity capacity_sync capacity_mask)

# temperature=(cooldown_temp max_temp max_temp_pause shutdown_temp)

# cooldownRatio=(cooldown_charge cooldown_pause)

# cooldownCustom=cooldown_custom=(file raw_value charge_seconds pause_seconds)

# cooldownCurrent=cooldown_current=[milliamps]

# resetBattStats=(reset_batt_stats_on_pause reset_batt_stats_on_unplug reset_batt_stats_on_plug)

# chargingSwitch=charging_switch=(ctrl_file1 on off ctrl_file2 on off --)

# chargingSwitch=charging_switch=(milliamps)

# chargingSwitch=charging_switch=(3700-4300 millivolts)

# applyOnBoot=apply_on_boot=(ctrl_file1::value[::default] ctrl_file2::value[::default] ... --exit)

# applyOnPlug=apply_on_plug=(ctrl_file1::value[::default] ctrl_file2::value[::default] ...)

# maxChargingCurrent=max_charging_current=([value] ctrl_file1::value::default ctrl_file2::value::default ...)

# maxChargingVoltage=max_charging_voltage=([value] ctrl_file1::value::default ctrl_file2::value::default ...) --exit)

# maxChargingCurrent=max_charging_current=([value] ctrl_file1::value::default1 ctrl_file2::value::default2 ...)

# maxChargingVoltage=max_charging_voltage=([value] ctrl_file1::value::default1 ctrl_file2::value::default2 ...) --exit)

# language=lang=language_code

# runCmdOnPause=run_cmd_on_pause='command...'

# ampFactor=amp_factor=[multiplier]

# voltFactor=volt_factor=[multiplier]

# prioritizeBattIdleMode=prioritize_batt_idle_mode=boolean

# currentWorkaround=current_workaround=boolean

# battStatusWorkaround=batt_status_workaround=boolean

# schedule=sched='HHMM command...
# HHMM command...
# ...'

# battStatusOverride=batt_status_override=Idle|Discharging|'code to PRINT value for _status'

# rebootResume=reboot_resume=boolean

# dischargePolarity=discharge_polarity=+|-


# ALIASES/SHORTCUTS

# cc cooldown_capacity
# rc resume_capacity
# pc pause_capacity
# cs capacity_sync
# cm capacity_mask

# sc shutdown_capacity
# ct cooldown_temp
# cch cooldown_charge
# cp cooldown_pause

# mt max_temp
# mtp max_temp_pause

# st shutdown_temp

# ccu cooldown_custom
# cdc cooldown_current

# rbsp reset_batt_stats_on_pause
# rbsu reset_batt_stats_on_unplug
# rbspl reset_batt_stats_on_plug

# s charging_switch

# ab apply_on_boot
# ap apply_on_plug

# mcc max_charging_current
# mcv max_charging_voltage

# l lang
# rcp run_cmd_on_pause

# af amp_factor
# vf volt_factor

# pbim prioritize_batt_idle_mode
# cw current_workaround
# bsw batt_status_workaround

# sd sched

# bso batt_status_override
# rr reboot_resume
# dp discharge_polarity


# FINE, BUT WHAT DOES EACH OF THESE VARIABLES ACTUALLY MEAN?

# configVerCode #
# This is checked during updates to determine whether config should be patched. Do NOT modify.

# shutdown_capacity (sc) #
# When the battery is discharging and its capacity/voltage_now_millivolts <= sc and phone has been running for 15 minutes or more, acc daemon turns the phone off to reduce the discharge rate and protect the battery from potential damage induced by voltage below the operating range.
# sc=-1 disables it.

# cooldown_capacity (cc) #
# Capacity/voltage_now_millivolts at which the cooldown cycle starts.
# Cooldown reduces battery stress induced by prolonged exposure to high temperature and high charging voltage.
# It does so through periodically pausing charging for a few seconds (more details below).

# resume_capacity (rc) #
# Capacity or voltage_now_millivolts at which charging should resume.

# pause_capacity (pc) #
# Capacity or voltage_now_millivolts at which charging should pause.

# capacity_sync (cs) #
# Some devices, notably from the Pixel lineup, have a capacity discrepancy issue between Android and the kernel.
# capacity_sync forces Android to report the actual battery capacity supplied by the kernel.
# The discrepancy is usually detected and corrected automatically by accd.
# This setting overrides the automatic behavior.
# Besides, it also prevents Android from getting capacity readings below 2%, since some systems shutdown before battery level actually drops to 0%.

# capacity_mask (cm) #
# Implies capacity_sync.
# This forces Android to report "capacity = capacity * (100 / pause_capacity)", effectively masking capacity limits (more like capacity_sync on steroids).
# It also prevents Android from getting capacity readings below 2%, since some systems shutdown before battery level actually drops to 0%.

# cooldown_temp (ct) #
# Temperature (°C) at which the cooldown cycle starts.
# Cooldown reduces the battery degradation rate by lowering the device's temperature.
# Refer back to cooldown_capacity for more details.

# max_temp (mt) #
# mtp or max_temp_pause #
# These two work together and are NOT tied to the cooldown cycle.
# On max_temp (°C), charging is paused for max_temp_pause (seconds).
# Unlike the cooldown cycle, which aims at reducing BOTH high temperature and high voltage induced stress - this is ONLY meant specifically for reducing high temperature induced stress.
# Even though both are separate features, this complements the cooldown cycle when environmental temperatures are off the charts.

# shutdown_temp (st) #
# Shutdown the system if battery temperature >= this value.

# cooldown_charge (cch) #
# cooldown_pause (cp) #
# These two dictate the cooldown cycle intervals (seconds).
# When not set, the cycle is disabled.
# Suggested values are cch=50 and cp=10.
# If charging gets a bit slower than desired, try cch=50 and cp=5.
# Note that cooldown_capacity and cooldown_temp can be disabled individually by assigning them values that would never be reached under normal circumstances.

# cooldown_custom (ccu) #
# When cooldown_capacity and/or cooldown_temp don't suit your needs, this comes to the rescue.
# It takes precedence over the regular cooldown settings.

# cooldown_current (cdc) #
# Instead of pausing charging periodically during the cooldown phase, limit the max charging current (e.g., to 500 mA)

# reset_batt_stats_on_pause (rbsp) #
# Reset battery stats after pausing charging.

# reset_batt_stats_on_unplug (rbsu) #
# Reset battery stats if the charger has been unplugged for a few seconds.

# reset_batt_stats_on_plug (rbspl) #
# Reset battery stats if the charger has been plugged for a few seconds.

# charging_switch (s) #
# If unset, acc cycles through its database and sets the first working switch/group that disables charging.
# If the set switch/group doesn't work, acc unsets chargingSwitch and repeats the above.
# If all switches fail to disable charging, chargingSwitch is unset and acc/d exit with error code 7.
# This automated process can be disabled by appending " --" to "charging_switch=...".
# e.g., acc -s s="battery/charge_enabled 1 0 --"
# acc -ss always appends " --".
# charging_switch=milliamps (e.g., 0-250) enables current-based charging control.
# If charging switch is set to 3700-4300 (millivolts), acc stops charging by limiting voltage.
# For details, refer to the readme's tips section.
# Unlike the original variant, this kind of switch is never unset automatically.
# Thus, in this case, appending " --" to it leads to invalid syntax.
# A daemon restart is required after changing this (automated by "acc --set").

# apply_on_boot (ab) #
# Settings to apply on boot or daemon start/restart.
# The --exit flag (refer back to applyOnBoot=...) tells the daemon to stop after applying settings.
# If the --exit flag is not included, default values are restored when the daemon stops.

# apply_on_plug (ap) #
# Settings to apply on plug
# This exists because some /sys files (e.g., current_max) are reset on charger re-plug.
# Default values are restored on unplug and when the daemon stops.

# max_charging_current (mcc) #
# max_charging_voltage (mcv) #
# Only the current/voltage value is to be supplied.
# Control files are automatically selected.

# lang (l) #
# acc language, managed with "acc --set --lang" (acc -sl).
# When null, English (en) is assumed.

# run_cmd_on_pause (rcp) #
# Run commands* after pausing charging.
# * Usually a script ("sh some_file" or ". some_file")

# amp_factor (af) #
# volt_factor (vf) #
# Unit multiplier for conversion (e.g., 1V = 1000000 Microvolts)
# ACC can automatically determine the units, but the mechanism is not 100% foolproof.
# e.g., if the input current is too low, the unit is miscalculated.
# This issue is rare, though.
# Leave these properties alone if everything is running fine.

# prioritize_batt_idle_mode (pbim) #
# If enabled charging switches that support battery idle mode take precedence.
# It is only used when charging_switch is not set.
# This is disabled by default due to issues on Samsung (store_mode) and other devices.

# current_workaround (cw) #
# Only use current control files whose paths match "batt" (default: false).
# This is necessary only if the current limit affects both input and charging current values.
# Try this if low current values don't work.
# "accd --init" is required after changing this (automated by "acc --set").

# batt_status_workaround (bsw) #
# With this enabled, in addition to just reading POWER_SUPPLY_STATUS, if the battery is "Charging" and current is within -11 and 95 mA (inclusive), battery status is considered "Idle". Status is considered "Discharging", if current drops significantly, after calling the disable_charging function.
# By not relying solely on the information provided by POWER_SUPPLY_STATUS, this approach boosts compatibility quite dramatically. So much so, that on certain devices (e.g., Nokia 2.2), acc only works when this is enabled.
# On the other hand, the user may observe charging control inconsistencies on devices that report wrong current values or major current fluctuations.
# Oftentimes, charging control issues are related to the power adapter.

# sched (sd) #
# Command/script schedules, in the following format:
#
# sched="HHMM command...
# HHMM command...
# ..."
#
# e.g., 3900 mV at 22:00, and 4100 mV at 6:00, daily:
# sched="2200 acc -s mcv=3900
# 0644 acc -s mcv=4100"
#
# 12 hour format is not supported.
# Each schedule must be on its own line.
# Each line is daemonized.
# This is not limited to acc commands. It can run anything.
#
# Commands:
#   -s|--set [sd|sched]="[+-]schedule to add or pattern to delete"
#     e.g.,
#       acc -s sd=-2050 (delete schedules that match 2050)
#       acc -s sd="+2200 acc -s mcv=3900 mcc=500; acc -n "Switched to \"sleep\" profile" (append schedule)
#     Note: "acc -s sd=" behaves just like similar commands (restores default value; for schedules, it's null)

# batt_status_override (bso) #
# Overrides the battery status determined by the not_charging function.
# It can be Idle, Discharging (both case sensitive), or logic to PRINT the desired value for the _status variable.
# When set to Idle or Discharging, _status will be set to that value if the enforced* charging switch state is off.
# It only works in conjunction with an enforced charging switch (set manually, has a trailing " --").
#
# Usage scenario: the switch "main/cool_mode 0 1" supports idle mode. However, sometimes it does not respond soon enough (e.g., due to fast charging). The user can then enforce it with acc -ss and set batt_status_override=Idle. This means, when main/cool_mode is on (0), _status will be determined by the not_charging function (as usual), but when it's off (1), _status will be Idle, bypassing the not_charging function.
#
# If the user were to write their own logic, it would've be something as follows:
# batt_status_override='[ $(cat main/cool_mode) -eq 1 ] && printf Idle'

# reboot_resume (rr) #
# Reboot (when capacity <= resume_capacity) to re-enable charging.
# A warning notification is posted 60 seconds prior, for the user to block the action, if they so please.

# discharge_polarity (dp) #
# This overrides the automatic current polarity detection.

# one-line scripts #
# Every line that begins with ": " is interpreted as a one-line script.
# This feature can be useful for many things, including setting up persistent config profiles (source a file that overrides the main config).
# All script lines are executed whenever the config is loaded/sourced.
# This happens regularly while the daemon is running, and at least once per command run.
# Warning: all files used in one-line scripts must reside somewhere in /data/adb/, just like acc's own data files.

#/DC#
```

---
## SETUP/USAGE


Ainsi que la  [configuration par défaut](#configuration-par-défaut) (au-dessus) suggère, ACC est conçu pour fonctionner dès l'installation, avec peu, voir aucune customisation/intervention demandé.

La seule commende dont vous devrez vous souvenir est `acc`.
C'est un menu que vous aimerez, ou que vous détesterez.

Si vous ne vous sentez pas dans l'utilisation de lignes de commandes, passez cette section et utilisez un application "front-end" (graphique) à la place.

Alternativement, vous pouvez utiliser un étideur de texte pour modifier `/data/adb/vr25/acc-data/config.txt`.
Le fichier de configuration comporte des instructions de modification.
Il est le même que dans la [configuration par défaut](#configuration-par-défaut) au-dessus.


### Commandes du Terminal
```
#TC#

Utilisation

  acc   Assistant

  accd   Démarrer/arrêter accd

  accd.   Arrêter acc/daemon

  accd,   Afficher le status acc/daemon (fonctionne ou pas)

  acc [pause_capacity/millivolts [resume_capacity/millivolts, défaut: pause_capacity/millivolts - 5%/50mV]]
    ex,
      acc 75 70
      acc 80 (resume_capacity par défaut 80% - 5)
      acc 3900 (pareil que acc 3900 3870, bonne alternative au mode inactif (idle)

  acc [options] [args]   Se référer à la liste des options en-dessous

  acca [options] [args]   acc optimisé pour le "front-end"

  acc[d] -x [options] [args]   Définit log=/sdcard/Download/acc[d]-\${appareil}.log; utile pour le débogage de redémarrages non-voulus

  Un chemin customisé peut-être spécifié en premier paramètre (second si -x est utilisé).
  Si le fichier n'existe pas, la configuration actuelle est clonée.
    ex,
      acc /data/acc-night-config.txt --set pause_capacity=45 resume_capacity=43
      acc /data/acc-night-config.txt --set --current 500
      accd /data/acc-night-config.txt --init

  Notes pour accd:
    - L'ordre "--init|-i" n'as pas d'importance.
    - La chaîne de caractères du chemin de configuration ne doit pas contenir "--init|-i".


Options

  -b|--rollback   Annuler la mise à jour

  -c|--config [éditeur] [éditeur_opts]   Éditer la configuration (éditeur par défaut: nano/vim/vi)
    ex,
      acc -c (edit w/ nano/vim/vi)
      acc -c less
      acc -c cat

  -d|--disable [#%, #s, #m or #h (optionnel)]   Désactive la charge
    ex,
      acc -d 70% (ne pas recharger tant ue la capacité <= 70%)
      acc -d 1h (ne pas recharger avant qu'une heure ne soit passée)

  -D|--daemon   Affiche le status du daemon, (et si il est en fonctionnement) version et PID
    ex, acc -D (alias: "accd,")

  -D|--daemon [start|stop|restart]   Gérer le daemon
    ex,
      acc -D start (alias: accd)
      acc -D restart (alias: accd)
      accd -D stop (alias: "accd.")

  -e|--enable [#%, #s, #m or #h (optionnel)]   Active la charge
    ex,
      acc -e 75% (recharger à 75%)
      acc -e 30m (recharge pendant 30 minutes)

  -f|--force|--full [capacité]   Charger une fois à la capacité donnée (defaut: 100%), sans restrictions
    ex,
      acc -f 95 (charger à 95%)
      acc -f (charger à 100%)
    Note: si la capacité désirée est moindre que pause_capacity, utiliser acc -e #%

  -F|--flash ["fichier_zip"]   Flasher tous les fichiers zip dont le binaire de mise à jour est un script shell
    ex,
      acc -F (lance un assistant de flashage zip)
      acc -F "file1" "file2" "fileN" ... (installer plusieurs zips)
      acc -F "/sdcard/Download/Magisk-v20.0(20000).zip"

  -i|--info [insensible à la casse egrep regex (defaut: ".")]   Affiche les infos de la batterie
    ex,
      acc -i
      acc -i volt
      acc -i 'volt\|curr'

  -l|--log [-a|--acc] [éditeur] [éditeur_opts]   Affiche/modifie accd log (defaut) ou acc log (-a|--acc)
    ex,
      acc -l (identique à acc -l less)
      acc -l rm
      acc -l -a cat
      acc -l grep ': ' (affiche les erreurs explicites seulement)

  -la   Identique à -l -a

  -l|--log -e|--export   Exporte tout les logs dans /sdcard/Download/acc-logs-\$deviceName.tgz
    ex, acc -l -e

  -le   Identique à -l -e

  -n|--notif [["STRING" (défaut: ":)")] [USER ID (défaut: 2000 (shell))]]   Affiche une notification Android; peut ne pas marcher sur tout les systèmes
    ex, acc -n "Hello, World!"

  -p|--parse [<fichier de base> <fichier à analyser>] | <fichier à analyser>]   Aide à trouver les potentiels commutateurs de charge rapidement, pour tout appareil
    ex,
      acc -p   Analyse $dataDir/logs/power_supply-\*.log et affiche les commutateurs de charge potentiels non présent dans $TMPDIR/ch-switches
      acc -p /sdcard/power_supply-harpia.log   Analyse le fichier donné et affiche les commutateurs de charge potentiels qui ne sont pas dans $TMPDIR/ch-switches
      acc -p /sdcard/charging-switches.txt /sdcard/power_supply-harpia.log   Analyse /sdcard/power_supply-harpia.log et affiche les commutateurs de charge potentiels absents depuis /sdcard/charging-switches.txt

  -r|--readme [éditeur] [éditeur_opts]   Affiche/édite README.md
    ex,
      acc -r (pareil que acc -r less)
      acc -r cat

  -R|--resetbs   Remise à zéro des statistiques de la batterie (paramètres > batterie > utilisation de la batterie)
    ex, acc -R

  -s|--set   Affiche la configuration actuelle
    ex, acc -s

  -s|--set prop1=valeur "prop2=valeur1 valeur2"   Définit [plusieurs] propriétées
    ex,
      acc -s charging_switch=
      acc -s pause_capacity=60 resume_capacity=55 (raccourcis: acc -s pc=60 rc=55, acc 60 55)
      acc -s "charging_switch=battery/charging_enabled 1 0" resume_capacity=55 pause_capacity=60
    Note: toutes les propriétées ont des alias pour une écriture plus rapide; faire "acc -c cat" pour les voir

  -s|--set [sd|sched]="[+-](programme à ajouter ou à supprimer)" (2050 correspond à 20H50)
    ex,
      acc -s sd=-2050 (supprime le programme qui corrrespond à 2050)
      acc -s sd="+2200 acc -s mcv=3900 mcc=500; acc -n "Changé sur le profile \"nuit\"" (ajoute un programme à 22H00, et affiche une notification lors du changement)
    Note: "acc -s sd=" se comporte comme les autres commandes (restaure les valeurs pas défaut; pour les programmes, c'est vide)

  -s|--set c|--current [milliamps|-]   Définit/affiche/restaure_défaut le courant de charge maximum (compris entre: 0-9999$(print_mA))
    ex,
      acc -s c (affiche la limite actuelle)
      acc -s c 500 (définit "500" comme valeur maximum)
      acc -s c - (restaure aux paramètres par défaut)

  -sc [milliamps|-]   Pareil qu'au dessus

  -s|--set l|--lang   Change le language
    ex, acc -s l

  -sl   Pareil qu'au dessus

  -s|--set d|--print-default [egrep regex (défaut: ".")]   Affiche la configuration par défaut sans lignes vides
    ex,
      acc -s d (affiche l'entièreté de la configuration par défaut)
      acc -s d cap (affiche seulement les entrées correspondantes à "cap")

  -sd [egrep regex (default: ".")]   Pareil qu'au dessus

  -s|--set p|--print [egrep regex (défaut: ".")]   Affiche la configuration par défaut sans lignes vides (se référer aux exemples précédents)

  -sp [egrep regex (défaut: ".")]  Pareil qu'au dessus

  -s|--set r|--reset [a]   Restaure la configuration pas défaut ("a" est pour "all": configure et contrôle les fichiers en liste noire, essentiellement un remise à zéro)
      e.x,
      acc -s r

  -sr [a]  Pareil qu'au dessus


  -s|--set s|charging_switch   Force l'utilisation d'un commutateur de charge spécifique
    ex, acc -s s

  -ss    Pareil qu'au desssus

  -s|--set s:|chargingSwitch:   Liste les commutateurs de charge connus
    ex, acc -s s:

  -ss:   Pareil qu'au dessus

  -s|--set v|--voltage [millivolts|-] [--exit]   Définit/affiche/restaure le voltage de charge maximum (compris entre: 3700-4300$(print_mV))
    ex,
      acc -s v (affiche)
      acc -s v 3900 (définit)
      acc -s v - (restaure défaut)
      acc -s v 3900 --exit (arrête le daemon après l'application des changements)

  -sv [millivolts|-] [--exit]   Pareil qu'au dessus

  -t|--test [fichier_ctrl1 on off [fichier_ctrl2 on off]]   Teste des commutateurs de charge custom
    ex,
      acc -t battery/charging_enabled 1 0
      acc -t /proc/mtk_battery_cmd/current_cmd 0::0 0::1 /proc/mtk_battery_cmd/en_power_path 1 0 ("::" est un remplacent pour " " - MTK seulement)

  -t|--test [fichier]   Teste des commutateurs de charge depuis un fichier (défaut: $TMPDIR/ch-switches)
    ex,
      acc -t (teste les commutateurs connus)
      acc -t /sdcard/experimental_switches.txt (teste des commutateurs custom/étrangers)

  -t|--test [p|parse]   Analyse les potentiels commutateurs de charge depuis le log d'alimentation (comme "acc -p"), les teste tous, et ajoute ceux qui fonctionne à la liste des commutateurs connus
    Implique -x, comme acc -x -t p
    ex, acc -t p

  -T|--logtail   Surveille le log accd (suivre -F)
    ex, acc -T

  -u|--upgrade [-c|--changelog] [-f|--force] [-k|--insecure] [-n|--non-interactive]   Mise à jour/rétrograde en ligne
    ex,
      acc -u dev (met à jour par rapport à la dernière version dev)
      acc -u (dernière version de la branche actuelle)
      acc -u master^1 -f (avant dernière sortie stable)
      acc -u -f dev^2 (deux versions dev avant la dernière version dev)
      acc -u v2020.4.8-beta --force (force la mise à jour/rétrograde à v2020.4.8-beta)
      acc -u -c -n (si une mise à jour est diponible, affiche le code de version (nombre entier) et le lien du journal des modifications)
      acc -u -c (pareil qu'au dessus, mais avec une invité d'installation)

  -U|--uninstall   Désinstalle comptètement acc et AccA
    ex, acc -U

  -v|--version   Affiche la version de acc et le code de version
    ex, acc -v

  -w#|--watch#   Surveiller les événements de la batterie
    ex,
      acc -w (rafraichît les infos toutes les 3 secondes)
      acc -w0.5 (rafraichît les infos toutes les 0.5 secondes)
      acc -w0 (aucun délais d'attente)


Codes de sortie

  0. Vrai/succès
  1. Faux/défaillance générale
  2. Syntaxe de commande incorrecte
  3. Il manque un binaire busybox
  4. N'est pas lancé en tant que superutilisateur
  5. Mise à jour disponible ("--upgrade")
  6. Pas de mise à jour disponible ("--upgrade")
  7. N'a pas pu arrêter le chargement
  8. Le daemon et déjà lancé ("--daemon start")
  9. Le daemon n'est pas lancé ("--daemon" and "--daemon stop")
  10. Tout les commutateurs de charge ont échoués (--test)
  11. Le courant (mA) n'est pas compris entre 0 et 9999
  12. L'initialisation à échouée
  13. Échec du vérrouillage de $TMPDIR/acc.lock
  14. ACC ne peut pas s'initialiser, car le module Magisk est désactivé
  15. Le mode de veille est supporté (--test)
  16. N'a pas pu activer le chargement (--test)

  Les logs sont exportés automatiquement ("--log --export") lors des codes de sortie 1, 2 et 7.


Astuces

  Les commandes peuvent être mise à la chaîne pour des fonctionalitées étendues.
    ex, charge pendant 30 minutes, arrête le chargement pendant 6 heures, charge jusqu'à 85% et redémarre le daemon
    acc -e 30m && acc -d 6h && acc -e 85 && accd

  Profile exemple
    acc -s pc=45 rc=43 mcc=500 mcv=3900
      Ceci garde le niveau de la batterie entre 43-45%, limite le courant de charge à 500 mA et le voltage à 3900 millivolts.
      C'est adapté pour le branchement nocturne et pour le "toujours branché".

  Se référer à acc -r (ou --readme) pour la documentation complète (recomendé)

#/TC#
```

---
## PLUGINS

Those are scripts that override functions and some global variables.
They should be placed in `/data/adb/vr25/acc-data/plugins/`.
Files are sorted and sourced.
Filenames shall not contain spaces.
Hidden files and those without the `.sh` extension are ignored.

There are also _volatile_ plugins (gone on reboot, useful for debugging): `/dev/.vr25/acc/plugins/`.
Those override the permanent.

A daemon restart is required to load new/modified plugins.


---
## NOTES/TIPS FOR FRONT-END DEVELOPERS


### Basics

ACC does not require Magisk.
Any root solution is fine.

Use `/dev/.vr25/acc/acca` instead of regular `acc`.
It's optimized for front-ends, guaranteed to be readily available after installation/upgrades and significantly faster than its `acc` counterpart.
`acca --set prop1=bla prop2="bla bla" ...` runs asynchronously (non-blocking mode) - meaning, multiple instances of it work in parallel.

It may be best to use long options over short equivalents - e.g., `--set charging_switch=` instead of `-s s=`.
This makes code more readable (less cryptic).

Include provided descriptions of ACC features/settings in your app(s).
Provide additional information (trusted) where appropriate.
Explain settings/concepts as clearly and with as few words as possible.

Take advantage of exit codes.
Refer back to `SETUP/USAGE > [Terminal Commands](#terminal-commands) > Exit Codes`.


### Installing/Upgrading ACC

This should be trivial.
The simplest way is flashing acc from Magisk manager.

Alternatively, `install.sh`, `install-online.sh` or `install-tarball.sh` can be used.
For details, refer back to [install from local source or GitHub](#install-from-local-source-or-github).

Developers can also use the _updateJSON_ API.
The front-end downloads and parses [this JSON file](https://raw.githubusercontent.com/VR-25/acc/master/module.json).
The format is as follows:

```
{
    "busybox": "https://github.com/Magisk-Modules-Repo/busybox-ndk",
    "changelog": "https://raw.githubusercontent.com/VR-25/acc/master/changelog.md",
    "curl": "https://github.com/Zackptg5/Cross-Compiled-Binaries-Android/tree/master/curl",
    "tgz": "https://github.com/VR-25/acc/releases/download/$version/acc_${version}_${versionCode}.tgz",
    "tgzInstaller": "https://github.com/VR-25/acc/releases/download/$version/install-tarball.sh",
    "version": "STRING",
    "versionCode": INT,
    "zipUrl": "https://github.com/VR-25/acc/releases/download/$version/acc_${version}_${versionCode}.zip"
}
```

### Uninstalling ACC

Either run `/dev/.vr25/acc/uninstall` (no reboot required; **charger must be plugged**) or uninstall from Magisk manager and reboot.


### Initializing ACC

On boot_completed receiver and main activity, run:

`[ -f /dev/.vr25/acc/acca ] || /data/adb/vr25/acc/service.sh`

Explanation:

ACC's working environment must be initialized - i.e., by updating the stock charging config (for restoring without a reboot) and pre-processing data for greater efficiency.
This is done exactly once after boot.
If it were done only after installation/upgrade, one would have to reinstall/upgrade acc after every kernel update.
That's because kernel updates often change the default power supply drivers settings.

Since acc's core executables are dynamic ([expected to] change regularly), those are linked to `/dev/.vr25/acc/` to preserve the API.
The links must be recreated once after boot (/dev/ is volatile).

`accd` is a symbolic link to `service.sh`.
If service.sh is executed every time the `main activity` is launched, accd will be repeatedly restarted for no reason.

Notes

- This "manual" initialization is only _strictly_ required if Magisk is not installed - and only once per boot session. In other words, Magisk already runs service.sh shortly after boot.
- ACC's installer always initializes it.


### Managing ACC

As already stated, front-ends should use the executable `/dev/.vr25/acc/acca`.
Refer to the [default configuration](#default-configuration) and [terminal commands](#terminal-commands) sections above.

The default config reference has a section entitled variable aliases/shortcuts.
Use ONLY those with `/dev/.vr25/acc/acca --set`!

To clarify, `/dev/.vr25/acc/acca --set chargingSwitch=...` is not supported!
Use either `s` or `charging_switch`.
`chargingSwitch` and all the other "camelcase" style variables are for internal use only (i.e., private API).

Do not parse the config file directly.
Use `--set --print` and `--set --print-default`.
Refer back to [terminal commands](#terminal-commands) for details.


### The Output of --info

It comes from the kernel, not acc itself.
Some kernels provide more information than others.

Most of the lines are either unnecessary (e.g., type: everyone knows that already) or unreliable (e.g., health, speed).

Here's what one should focus on:

STATUS=Charging # Charging, Discharging or Idle
CAPACITY=50 # Battery level, 0-100
TEMP=281 # Always in (ºC * 10)
CURRENT_NOW=0 # Charging current (Amps)
VOLTAGE_NOW=3.861 # Charging voltage (Volts)
POWER_NOW=0 # (CURRENT_NOW * VOLTAGE_NOW) (Watts)

Note that the power information refers to what is actually supplied to the battery, not what's coming from the adapter.
External power is always converted before it reaches the battery.


### Profiles

Those are simply different config files.
A config path can be supplied as first argument to `acca` and second to `accd` executables.

Examples:

_Copy the config:_

Current config: `/dev/.vr25/acc/acca --config cat > /path/to/new/file`

Default config: `/dev/.vr25/acc/acca /path/to/new/file --version` (`--version` can be replaced with any option + arguments, as seen below.)

_Edit the copy:_

`/dev/.vr25/acc/acca /path/to/new/file --set pause_capacity=75 resume_capacity=70` (if the file does not exist, it is created as a copy of the default config.)

_Use the copy:_

`/dev/.vr25/acc/accd --init /path/to/new/file` (the daemon is restarted with the new config.)

_Back to the main config:_

`/dev/.vr25/acc/accd --init`


### More

ACC daemon does not have to be restarted after making changes to the config.
It picks up new changes within seconds.

There are a few exceptions:

- `charging_switch` (`s`) requires a daemon restart (`/dev/.vr25/acc/accd`).
- `current_workaround` (`cw`) requires a full re-initialization (`/dev/.vr25/acc/accd --init`).

This information is in the [default configuration](#default-configuration) section as well.


---
## TROUBLESHOOTING


## acc -t Results Are Inconsistent

Refer to "default config > batt_status_workaround".


### Battery Capacity (% Level) Doesn't Seem Right

When Android's battery level differs from that of the kernel, ACC daemon automatically syncs it by stopping the battery service and feeding it the real value every few seconds.

Pixel devices are known for having battery level discrepancies for the longest time.

If your device shuts down before the battery is actually empty, capacity_sync or capacity_mask may help.
Refer to the [default configuration](#default-configuration) section above for details.


### Charging Switch

By default, ACC uses whichever [charging switch](https://github.com/VR-25/acc/blob/dev/acc/charging-switches.txt) works ("automatic" charging switch).
However, things don't always go well.

- Some switches are unreliable under certain conditions (e.g., while display is off).

- Others hold a [wakelock](https://duckduckgo.com/lite/?q=wakelock).
This causes fast battery drain when charging is paused and the device remains plugged.

- Charging keeps being re-enabled by the system, seconds after acc daemon disables it.
As a result, the battery eventually charges to 100% capacity, regardless of pause_capacity.

- High CPU load (drains battery) was also reported.

- In the worst case scenario, the battery status is reported as `discharging`, while it's actually `charging`.

In such situations, one has to enforce a switch that works as expected.
Here's how to do it:

1. Run `acc --test` (or `acc -t`) to see which switches work.
2. Run `acc --set charging_switch` (or `acc -ss`) to enforce a working switch.
3. Test the reliability of the set switch. If it doesn't work properly, try another.

Since not everyone is tech savvy, ACC daemon automatically applies settings for certain devices to minimize charging switch issues.
These are in `acc/oem-custom.sh`.


### Custom Max Charging Voltage And Current Limits

Unfortunately, not all kernels support these features.
While custom current limits are supported by most (at least to some degree), voltage tweaking support is _exceptionally_ rare.

That said, the existence of potential voltage/current control file doesn't necessarily mean these are writable* or the features, supported.

\* Root is not enough.
Kernel level permissions forbid write access to certain interfaces.

Sometimes, restoring the default current may not work without a system reboot.
A workaround is setting the default max current value or any arbitrary high number (e.g., 9000 mA).
Don't worry about frying things.
The phone will only draw the max it can take.

**WARNING**: limiting voltage causes battery state of charge (SoC) deviation on some devices.
The  battery management system self-calibrates constantly, though.
Thus, as soon as the default voltage limit is restored, it'll start "fixing" itself.

Limiting current, on the other hand, has been found to be universally safe.
Some devices do not support just any current value, though.
That's not to say out-of-range values cause issues.
These are simply ignored.

If low current values don't work, try setting `current_workaround=true` (takes effect after `accd --init`.
Refer to the [default configuration](#default-configuration) section for details.

One can override the default lists of max charging current/voltage control files by copying `acc/ctrl-files.sh` to `/data/adb/vr25/acc-data/plugins/` and modifying it accordingly.
Note that default limits must be restored prior to that to avoid the need for a system reboot.
Reminder: a daemon restart is required to load new/modified plugins.


### Diagnostics/Logs

Volatile logs (gone on reboot) are stored in `/dev/.vr25/acc/` (.log files only).
Persistent logs reside in `/data/adb/vr25/acc-data/logs/`.

`acc -le` exports all acc logs, plus Magisk's and extras to `/data/adb/acc-data/logs/acc-$device_codename.tgz`.
The logs do not contain any personal information and are never automatically sent to the developer.
Automatic exporting (local) happens under specific conditions (refer back to `SETUP/USAGE > Terminal Commands > Exit Codes`).


### Install, Upgrade, Stop and Restart Processes Seem to Take Too Long

The daemon stop process implies complete reversal of changes made to the charging management system.
Sometimes, **this requires the charger to be plugged**.
That's because some devices have kernel bugs and/or bad charging driver implementations.
That said, accd is always stopped _gracefully_ to ensure the restoration takes place.
One who knows what they're doing, can force-stop accd by running `pkill -9 -f accd`.


### Kernel Panic and Spontaneous Reboots

Control files that trigger these are automatically backlisted (commented out in `/data/adb/acc-data/logs/write.log`).


### Restore Default Config

This can potentially save a lot of time and grief.

`acc --set --reset`, `acc -sr` or `rm /data/adb/vr25/acc-data/config.txt` (failsafe)


### Samsung, Charging _Always_ Stops at 70% Capacity

This is a device-specific issue (by design?).
It's caused by the _store_mode_ charging control file.
Switch to _batt_slate_mode_ to prevent it.
Refer back to [charging switch](#charging-switch) above for details on that.


### Slow Charging

At least one of the following may be the cause:

- Charging current and/or voltage limits
- Cooldown cycle (non optimal charge/pause ratio, try 50/10 or 50/5)
- Troublesome charging switch (refer back to `TROUBLESHOOTING > Charging Switch`)
- Weak adapter and/or power cord


### Unable to Charge

Refer back to the [warnings](#warnings) section above.


### Unexpected Reboots

Wrong/troublesome charging control files may trigger unwanted reboots.
ACC blacklist some of these automatically (registered in `/data/adb/vr25/acc-data/logs/write.log`, with a leading hashtag).
Sometimes, there may be false positives in there - i.e., due to unexpected reboots caused by something else. Thus, if a control file that used to work, suddenly does not, see if it was blacklisted (`acc -t` also reveals blacklisted switches).
Send `write.log` to the developer once the reboots have stopped.


### WARP, VOOC and Other Fast Charging Tech

Charging switches may not work reliably with the original power adapter.
This has nothing to do with acc.
It's bad design by the OEMs themselves.
If you face issues, either try a different charging switch or a regular power brick (a.k.a., slow charger).
You may also want to try stopping charging by limiting current/voltage.


### Why Did accd Stop?

Run `acc -l tail` to find out.
This will print the last 10 lines of the daemon log file.

A relatively common exit code is `7` - meaning all charging switches failed to disable charging.
It happens due to kernel issues (refer to the previous subsection - [charging switch](#charging-switch)).
The daemon only stops due to this if acc is set to automatically determine the switches to use (default behavior).
Manually setting a working switch with `acc -ss` or `acc -s s="SWITCHES GO HERE --"` disables auto mode and prevents accd from stopping if the set the charging switches fail.


---
## POWER SUPPLY LOGS (HELP NEEDED)

Please run `acc -le` and upload `/data/adb/vr25/acc-data/logs/power_supply-*.log` to [my dropbox](https://www.dropbox.com/request/WYVDyCc0GkKQ8U5mLNlH) (no account/sign-up required).
This file contains invaluable power supply information, such as battery details and available charging control files.
A public database is being built for mutual benefit.
Your cooperation is greatly appreciated.

Privacy Notes

- Name: random/fake
- Email: random/fake

See current submissions [here](https://www.dropbox.com/sh/rolzxvqxtdkfvfa/AABceZM3BBUHUykBqOW-0DYIa?dl=0).


---
## LOCALIZATION


Currently Supported Languages and Translation Levels (full, good, fair, minimal)

- Chinese, simplified (zh-rCN): minimal
- Chinese, traditional (zh-rTW): minimal
- English (en): full
- German (de_DE): fair
- Indonesia (id): minimal
- Portuguese, Portugal (pt-PT): minimal


Translation Notes

1. Start with copies of [acc/strings.sh](https://github.com/VR-25/acc/blob/dev/acc/strings.sh) and, optionally, [README.md](https://github.com/VR-25/acc/blob/dev/README.md).

2. Modify the header of strings.sh to reflect the translation (e.g., # Español (es)).

3. Anyone is free and encouraged to open translation [pull requests](https://duckduckgo.com/lite/?q=pull+request).
Alternatively, a _compressed_ archive of translated `strings.sh` and `README.md` files can be sent to the developer via Telegram (link below).

4. Use `acc -sl` (--set --lang): language switching wizard or `acc -s l=<lang_string>` to set a language.


---
## TIPS


### _Always_ Limit the Charging Current If Your Battery is Old and/or Tends to Discharge Too Fast

This extends the battery's lifespan and may even _reduce_ its discharge rate.

750-1000mA is a good range for regular use.

500mA is a comfortable minimum - and also very compatible.

If your device does not support custom current limits, use a dedicated ("slow") power adapter.


### Current and Voltage Based Charging Control

Enabled by setting charging_switch=milliamps or charging_switch=3700-4300 (millivolts) (e.g., `acc -s s=0`, `acc -s s=250`, `acc -s s=3700`, `acc -ss` (wizard)).

Essentially, this turns current/voltage control files into _[pseudo] charging switches_.

A common and positive side effect of this is _[pseudo] idle mode_ - i.e., the battery may work just as a power buffer.

Note: depending on the kernel - at `pause_capacity`, the charging status may either change ("discharging" or "not charging") or remain still ("charging" - not an issue).
If it changes intermittently, the current is too low; increment it until the issue goes away.


### Generic

Emulate _battery idle mode_ with a voltage limit: `acc -s pc=101 rc=0 mcv=3900`.
The first two arguments disable the regular charging pause/resume functionality.
The last sets a voltage limit that will dictate how much the battery should charge.
The battery enters a _[pseudo] idle mode_ when its voltage peaks.
Essentially, it works as a power buffer.

A similar effect can be achieved with settings such as `acc 60 59` (percentages) and `acc 3900` (millivolts).

Yet another way is limiting charging current to 0-250 mA or so (e.g., `acc -sc 0`).
`acc -sc -` restores the default limit.
Alternatively, one can experiment with `acc -s s=0` and/or `acc -s s=3700`, which uses current/voltage control files as charging switches.

Force fast charge: `appy_on_boot="/sys/kernel/fast_charge/force_fast_charge::1::0 usb/boost_current::1::0 charger/boost_current::1::0"`


### Google Pixel Devices

Force fast wireless charging with third party wireless chargers that are supposed to charge the battery faster: `apply_on_plug=wireless/voltage_max::9000000`.

This may not work on all Pixel devices.
There are no negative consequences when it doesn't.


### Idle Mode and Alternatives

1 - Charging switch that supports idle mode (the obvious winner).
Note that self discharge is a thing.
This is as if the battery were physically disconnected.
Extremely slow discharge rate is expected.

2 - `charging_switch=0`: if current fluctuates, also set `current_workaround=true` (only takes affect after a reboot).
If this method works, the behavior is exactly the same as `#1`.

3 - `charging_switch=3900`: only works on devices that actually support voltage control.
Unlike regular idle mode, this maintains 3900 mV, indefinitely.
This is not good with higher voltages.
We're trying to minimize battery stress as much as possible.
Maintaining a voltage higher than 3900 for a long time is _not_ recommended.

4 - `acc 3900`: this is short for _acc 3900 3870_ (a 50 mV difference).
It tries to maintain 3900 mV without voltage control support.
Yes, it's definitely not a joke.
This works with regular charging switches and voltage readings.

5 - `acc 45 44`: this closely translates to 3900 mV under most circumstances.
Voltage and capacity (%) do not have a linear relationship.
Voltage varies with temperature, battery chemistry and age.


---
## FREQUENTLY ASKED QUESTIONS (FAQ)


> How do I report issues?

Open issues on GitHub or contact the developer on Facebook, Telegram (preferred) or XDA (links below).
Always provide as much information as possible.
Attach `/sdcard/Download/acc-logs-*.tgz` - generated by `acc -le` _right after_ the problem occurs.
Refer back to `TROUBLESHOOTING > Diagnostics/Logs` for additional details.


> Why won't you support my device? I've been waiting for ages!

Firstly, have some extra patience!
Secondly, several systems don't have intuitive charging control files; I have to dig deeper - and oftentimes, improvise; this takes time and effort.
Lastly, some systems don't support custom charging control at all;  in such cases, you have to keep trying different kernels and uploading the respective power supply logs.
Refer back to `POWER SUPPLY LOGS (HELP NEEDED)`.


> Why, when and how should I calibrate the battery manager?

With modern battery management systems, that's generally unnecessary.

However, if your battery is underperforming, you may want to try the procedure described at https://batteryuniversity.com/article/bu-603-how-to-calibrate-a-smart-battery .

ACC automatically optimizes system performance and battery utilization, by forcing `bg-dexopt-job` on daemon [re]start, once after boot, if charging and uptime >= 900 seconds.


> I set voltage to 4080 mV and that corresponds to just about 75% charge.
But is it typically safer to let charging keep running, or to have the circuits turn on and shut off between defined percentage levels repeatedly?

It's not much about which method is safer.
It's specifically about electron stability: optimizing the pressure (voltage) and current flow.

As long as you don't set a voltage limit higher than 4200 mV and don't leave the phone plugged in for extended periods of time, you're good with that limitation alone.
Otherwise, the other option is actually more beneficial - since it mitigates high pressure (voltage) exposure/time to a greater extent.
If you use both, simultaneously - you get the best of both worlds.
On top of that, if you enable the cooldown cycle, it'll give you even more benefits.

Ever wondered why lithium ion batteries aren't sold fully charged? They're usually ~40-60% charged. Why is that?
Keeping a battery fully drained, almost fully drained or 70%+ charged for a long times, leads to significant (permanent) capacity loss

Putting it all together in practice...

Night/heavy-duty profile: keep capacity within 40-60% and/or voltage around ~3900 mV

Day/regular profile: max capacity: 75-80% and/or voltage no higher than 4100 mV

Travel profile: capacity up to 95% and/or voltage no higher than 4200 mV

\* https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries/


> I don't really understand what the "-f|--force|--full [capacity]" is meant for.

Consider the following situation:

You're almost late for an important event.
You recall that I stole your power bank and sold it on Ebay.
You need your phone and a good battery backup.
The event will take the whole day and you won't have access to an external power supply in the middle of nowhere.
You need your battery charged fast and as much as possible.
However, you don't want to modify ACC config nor manually stop/restart the daemon.


> What's DJS?

It's a standalone program: Daily Job Scheduler.
As the name suggests, it's meant for scheduling "jobs" - in this context, acc profiles/settings.
Underneath, it runs commands/scripts at specified times - either once, daily and/or on boot.


> Do I have to install/upgrade both ACC and AccA?

To really get out of this dilemma, you have to understand what ACC and AccA essentially are.

ACC is a Android program that controls charging.
It can be installed as an app (e.g., AccA) module, Magisk module or standalone software. Its installer determines the installation path/variant. The user is given the power to override that.

A plain text file holds the program's configuration. It can be edited with any root text editor.
ACC has a command line interface (CLI) - which in essence is a set of Application Programing Interfaces (APIs). The main purpose of a CLI/API is making difficult tasks ordinary.

AccA is a graphical user interface (GUI) for the ACC command line. The main purpose of a GUI is making ordinary tasks simpler.
AccA ships with a version of ACC that is automatically installed when the app is first launched.

That said, it should be pretty obvious that ACC is like a fully autonomous car that also happens to have a steering wheel and other controls for a regular driver to hit a tree.
Think of AccA as a robotic driver that often prefers hitting people over trees.
Due to extenuating circumstances, that robot may not be upgraded as frequently as the car.
Upgrading the car regularly makes the driver happier - even though I doubt it has any emotion to speak of.
The back-end can be upgraded by flashing the latest ACC zip.
However, unless you have a good reason to do so, don't fix what's not broken.


> Does acc work also when Android is off?

No, but this possibility is being explored.
Currently, it does work in recovery mode, though.


> I have this wakelock as soon as charging is disabled. How do I deal with it?

The best solution is enforcing a charging switch that doesn't trigger a wakelock.
Refer back to `TROUBLESHOOTING > Charging Switch`.
A common workaround is having `resume_capacity = pause_capacity - 1`. e.g., resume_capacity=74, pause_capacity=75.


---
## LINKS

- [Daily Job Scheduler](https://github.com/VR-25/djs)

- [Donate - Airtm, username: ivandro863auzqg](https://app.airtm.com/send-or-request/send)
- [Donate - Credit/Debit Card](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=iprj25@gmail.com&lc=US&item_name=VR25+is+creating+free+and+open+source+software.+Donate+to+suppport+their+work.&no_note=0&cn=&currency_code=USD&bn=PP-DonationsBF:btn_donateCC_LG.gif:NonHosted)
- [Donate - Liberapay](https://liberapay.com/vr25)
- [Donate - Patreon](https://patreon.com/vr25)
- [Donate - PayPal Me](https://paypal.me/vr25xda)

- [Facebook Page](https://fb.me/vr25xda)

- [Frontend - ACC App](https://github.com/MatteCarra/AccA/releases)
- [Frontend - ACC Settings](https://github.com/CrazyBoyFeng/AccSettings)

- [Must Read - How to Prolong Lithium Ion Batteries Lifespan](https://batteryuniversity.com/article/bu-808-how-to-prolong-lithium-based-batteries)

- [Telegram Channel](https://t.me/vr25_xda)
- [Telegram Group](https://t.me/acc_group)
- [Telegram Profile](https://t.me/vr25xda)

- [Upstream Repository](https://github.com/VR-25/acc)

- [XDA Thread](https://forum.xda-developers.com/apps/magisk/module-magic-charging-switch-cs-v2017-9-t3668427)
