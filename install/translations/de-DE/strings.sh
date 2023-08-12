# German (de_DE)

print_already_running() {
  echo "accd läuft bereits"
}

print_started() {
  echo "accd gestartet"
}

print_stopped() {
  echo "accd gestoppt"
}

print_not_running() {
  echo "accd läuft nicht"
}

print_restarted() {
  echo "accd neugestartet"
}

print_is_running() {
  echo "accd $1 läuft $2"
}

print_config_reset() {
  echo "Konfiguration zurückgesetzt"
}

print_switch_fails() {
  echo "[${chargingSwitch[@]-}] funktioniert nicht"
}

print_invalid_switch() {
  echo "Ungültiger Ladeschalter, [${chargingSwitch[@]-}]"
}

print_charging_disabled_until() {
  echo "Ladevorgang deaktiviert, bis die Batteriekapazität >= $1 entspricht"
}

print_charging_disabled_for() {
  echo "Laden deaktiviert für $1"
}

print_charging_disabled() {
  echo "Laden deaktiviert"
}

print_charging_enabled_until() {
  echo "Ladevorgang aktiviert, bis die Batteriekapazität >= $1 entspricht"
}

print_charging_enabled_for() {
  echo "Laden aktiviert für $1"
}

print_charging_enabled() {
  echo "Laden aktiviert"
}

print_unplugged() {
  echo "Das Ladegerät muss eingesteckt sein, um fortzufahren..."
}

print_switch_works() {
  echo "[$@] funktioniert"
}

print_switch_fails() {
  echo "[$@] funktioniert nicht"
}

print_no_ctrl_file() {
  echo "Keine Kontroll-Datei gefunden"
}

print_not_found() {
  echo "$1 nicht gefunden"
}


print_help() {
    cat << EOF
Verwendung:
    acc Assistent
    accd Start/Neustart accd
    accd.   Stoppe acc/daemon
    accd, Zeige acc/daemon Status an (laufend oder nicht)
    acc [pause_capacity [resume_capacity, Standartmäßig: pause_capacity - 5]]
        z.B.,
            acc 75 70
            acc 80 (resume_capacity fällt auf 80 - 5 zurück)
    acc [options] [args] Siehe die Liste der Optionen unten
    acca [options] [args] acc optimiert für Frontends
    Als erster Parameter kann ein benutzerdefinierter Konfigurationspfad angegeben werden.
        Wenn die Datei nicht existiert, wird die aktuelle Konfiguration geklont.
        z.B.,
            acc /data/acc-night-config.txt --set pause_capacity=45 resume_capacity=43
            acc /data/acc-night-config.txt --set --current 500
            accd /data/acc-nacht-konfig.txt
Optionen:
    -c|--config [Editor] [editor_opts] Bearbeite die Konfiguration (Standartmäßige Editoren: nano/vim/vi)
        z.B.,
            acc -c (bearbeitet mit nano/vim/vi)
            acc -c weniger
            acc -c cat
    -d|--disable [#%, #s, #m oder #h (optional)] Deaktiviert den Ladevorgang
        z.B.,
            acc -d 70% (nicht aufladen bis Kapazität <= 70%)
            acc -d 1h (nicht aufladen, bis 1 Stunde vergangen ist)
    -D|--daemon Druckt den Status des Daemons, (und wenn er läuft) Version und PID
        z.B. acc -D (alias: "accd,")
    -D|--daemon [start|stop|restart] Daemon verwalten
        z.B.,
            acc -D start (alias: "accd")
            acc -D restart (alias: accd)
            accd -D stop (alias: "accd.")
    -e|--enable [#%, #s, #m oder #h (optional)] Aktivieren der Aufladung
        z.B.,
            acc -e 75% (Wiederaufladen auf 75%)
            acc -e 30m (Aufladen für 30 Minuten)
    -f|--force|--full [Kapazität] Einmaliges Aufladen bis zu einer bestimmten Kapazität (Standard: 100%), ohne Einschränkungen
        z.B.,
            acc -f 95 (auf 95% aufladen)
            acc -f (Aufladen auf 100%)
        Hinweis: Wenn der gewünschte Prozentsatz kleiner als pause_capacity ist, verwenden Sie acc -e #%
    -F|--flash ["zip_file"] Flash alle Zip-Dateien, deren Update-Binärdatei ein Shell-Skript ist
        z.B.,
            acc -F (startet einen Assistenten zum Flashen von Zip-Dateien)
            acc -F "Datei1" "Datei2" "DateiN" ... (mehrere Zips installieren)
            acc -F "/sdcard/Documents/vr25/Magisk-v20.0(20000).zip"
    -i|--info [schreibungsunabhängig egrep regex (Standard: ".")] Batterie-Info anzeigen
z.B.,
            acc -i
            acc -i volt
            acc -i 'volt\|curr'
    -l|--log [-a|--acc] [editor] [editor_opts] Ausgeben/Bearbeiten von accd log (Standard) oder acc log (-a|--acc)
        z.B.,
            acc -l (dasselbe wie acc -l less)
            acc -l rm
            acc -l -a cat
            acc -l grep ': ' (zeigt nur explizite Fehler an)
    -la Dasselbe wie -l -a
    -l|--log -e|--export Alle Protokolle nach /sdcard/Download/acc-logs-\$deviceName.tgz exportieren
        z.B., acc -l -e
    -le Dasselbe wie -l -e
    -r|--readme [editor] [editor_opts] README.md anzeigen/bearbeiten
        z.B.,
            acc -r (dasselbe wie acc -r less)
            acc -r cat
    -R|--resetbs Batteriestatistiken zurücksetzen
        z.B., acc -R
    -s|--set Aktuelle Konfiguration ausgeben
        z.B., acc -s
    -s|--set prop1=Wert "prop2=Wert1 Wert2" Setzen von [mehreren] Eigenschaften
        z.B.,
            acc -s lade_schalter=
            acc -s pause_capacity=60 resume_capacity=55 (Abkürzungen: acc -s pc=60 rc=55, acc 60 55)
            acc -s "charging_switch=battery/charging_enabled 1 0" resume_capacity=55 pause_capacity=60
        Hinweis: Alle Eigenschaften haben kurze Aliasnamen, um die Eingabe zu beschleunigen; führen Sie "acc -c cat" aus, um diese zu sehen
    -s|--set c|--current [milliamps|-] Maximalen Ladestrom setzen/anzeigen/wiederherstellen (Bereich: 0-9999$(print_mA))
        z.B.,
            acc -s c (Stromgrenze anzeigen)
            acc -s c 500 (setzen)
            acc -s c - (Voreinstellung wiederherstellen)
    -sc [Milliampere|-] Wie oben
    -s|--set l|--lang Sprache wechseln
        z.B.: acc -s l
    -sl Wie oben
    -s|--set d|--print-default [egrep regex (Standard: ".")] Standardkonfiguration ohne Leerzeilen ausgeben
        z.B.,
            acc -s d (gibt die gesamte Standardkonfiguration aus)
            acc -s d cap (druckt nur Einträge, die auf "cap" passen)
    -sd [egrep regex (Standard: ".")] Wie oben
    -s|--set p|--print [egrep regex (Standard: ".")] Aktuelle Konfiguration ohne Leerzeilen drucken (siehe vorherige Beispiele)
    -sp [egrep regex (Voreinstellung: ".")] Wie oben
    -s|--set r|--reset Standardkonfiguration wiederherstellen
        z.B.,
            acc -s r
            rm /sdcard/Documents/vr25/acc/config.txt (ausfallsicher)
    -sr Wie oben
    -s|--set s|charging_switch Erzwingt einen bestimmten Ladeschalter
        z.B., acc -s s
    -ss Wie oben
    -s|--set s:|ladeschalter:   Bekannte Ladeschalter auflisten
        z.B., acc -s s:
    -ss:   Dasselbe wie oben
    -s|--set v|--voltage [millivolts|-] [--exit] Maximale Ladespannung setzen/drucken/wiederherstellen (Bereich: 3700-4200$(print_mV))
        z.B.,
            acc -s v (ausgeben)
            acc -s v 3900 (setzen)
            acc -s v - (Voreinstellung wiederherstellen)
            acc -s v 3900 --exit (stoppt den Daemon nach Übernahme der Einstellungen)
    -sv [millivolts|-] [--exit] Wie oben
    -t|--test [ctrl_file1 an aus [ctrl_file2 an aus]]   Benutzerdefinierte Ladeschalter testen
        z.B.,
            acc -t Batterie/Laden_aktiviert 1 0
            acc -t /proc/mtk_battery_cmd/current_cmd 0::0 0::1 /proc/mtk_battery_cmd/en_power_path 1 0 ("::" ist ein Platzhalter für " ")
    -t|--test [file] Testet die Ladeschalter aus einer Datei (Standard: /dev/.vr25/acc/ch-switches)
        Dies meldet auch, ob der "Batterie-Leerlauf"-Modus unterstützt wird
        z.B.,
            acc -t (bekannte Schalter testen)
            acc -t /sdcard/experimental_switches.txt (testet eigene/fremde Schalter)
    -T|--logtail Überwachung des accd-Protokolls (tail -F)
        z.B., acc -T
    -u|--upgrade [-c|--changelog] [-f|--force] [-k|--insecure] [-n|--non-interactive] Online-Upgrade/Downgrade
        z.B.,
            acc -u dev (Upgrade auf die neueste Entwicklungsversion)
            acc -u (letzte Version aus dem aktuellen Zweig)
            acc -u master^1 -f (vorherige stabile Version)
            acc -u -f dev^2 (zwei dev-Versionen unter der neuesten dev)
            acc -u v2020.4.8-beta --force (erzwingt Upgrade/Downgrade auf v2020.4.8-beta)
            acc -u -c -n (wenn ein Update verfügbar ist, wird der Versionscode (Integer) und der Link zum Änderungsprotokoll ausgegeben)
            acc -u -c (wie oben, aber mit Installationsaufforderung)
    -U|--uninstall Vollständiges Entfernen von acc und AccA
        z.B.: acc -U
    -v|--version Acc-Version und Versionscode ausgeben
        z.B., acc -v
    -w#|--watch# Batterie überwachen uevent
        z.B.,
            acc -w (Aktualisierung der Informationen alle 3 Sekunden)
            acc -w0.5 (Aktualisierung der Informationen alle halbe Sekunde)
            acc -w0 (keine zusätzliche Verzögerung)
Exit-Codes:
    0. Wahr/Erfolg
    1. Falsch oder allgemeiner Fehler
    2. Falsche Befehlssyntax
    3. Fehlende Busybox-Binärdatei
    4. Nicht als root ausgeführt
    5. Update verfügbar ("--upgrade")
    6. Keine Aktualisierung verfügbar ("--upgrade")
    7. Deaktivierung des Ladevorgangs fehlgeschlagen
    8. Daemon läuft bereits ("--daemon start")
    9. Daemon läuft nicht ("--daemon" und "--daemon stop")
    10. "--test" fehlgeschlagen
    11. Strom (mA) außerhalb des Bereichs
    12. Initialisierung fehlgeschlagen
    13. Sperren von /dev/.vr25/acc/acc.lock fehlgeschlagen
    Die Protokolle werden automatisch exportiert ("--log --export") bei den Exit-Codes 1, 2, 7 und 10.
Tipps:
    Befehle können für eine erweiterte Funktionalität verkettet werden.
        z.B. 30 Minuten laden, Ladepause für 6 Stunden, auf 85% laden und den Daemon neu starten
        acc -e 30m && acc -d 6h && acc -e 85 && accd
    Beispielprofil
        acc -s pc=60 rc=55 mcc=500 mcv=3900
            Dies hält die Batteriekapazität zwischen 55-60%, begrenzt den Ladestrom auf 500 mA und die Spannung auf 3900 Millivolt.
            Das ist ideal für die Nacht und für "ewig-angeschlossen".
    Siehe acc -r (oder --readme) für die vollständige Dokumentation (empfohlen)
EOF
}



print_exit() {
  echo "Beendet"
}

print_choice_prompt() {
  echo "(?) Auswahl, [Enter]: "
}

print_auto() {
  echo "Automatisch"
}

print_default() {
 echo "Standart"
}

print_curr_restored() {
    echo "Voreingestellter maximaler Ladestrom wiederhergestellt"
}

print_volt_restored() {
    echo "Voreingestellte maximale Ladespannung wiederhergestellt"
}

print_read_curr() {
    echo "Der Standardwert für den maximalen Ladestrom muss zuerst gelesen werden"
}

print_curr_set() {
    echo "Maximaler Ladestrom auf $1$(print_mA) gesetzt"
}

print_volt_set() {
    echo "Maximale Ladespannung eingestellt auf $1$(print_mV)"
}

print_wip() {
    echo "Ungültige Option"
    echo "- Für Hilfe acc -h oder -r ausführen"
}

print_press_key() {
    printf "Drücken Sie eine beliebige Taste, um fortzufahren..."
}

print_lang() {
    echo "Sprache"
}

print_doc() {
    echo "Dokumentation"
}

print_cmds() {
    echo "Alle Befehle"
}

print_re_start_daemon() {
    echo "Daemon starten/neustarten"
}

print_stop_daemon() {
    echo "Daemon anhalten"
}

print_export_logs() {
    echo "Protokolle exportieren"
}

print_1shot() {
    echo "Einmalig auf eine bestimmte Kapazität (Standard: 100%) aufladen, ohne Einschränkungen"
}

print_charge_once() {
    echo "Einmaliges Aufladen auf #%"
}

print_mA() {
    echo " Milliampere"
}

print_mV() {
    echo " Millivolt"
}

print_uninstall() {
    echo "Deinstallieren"
}

print_edit() {
    echo "$1 bearbeiten"
}

print_flash_zips() {
    echo "Flash-Zips"
}

print_reset_bs() {
    echo "Batteriestatistiken zurücksetzen"
}

print_test_cs() {
    echo "Ladeschalter testen"
}

print_update() {
    echo "Auf Aktualisierung prüfen"
}

print_W() {
    echo " Watts"
}

print_V() {
    echo " Spannungen"
}

print_available() {
    echo "$@ ist verfügbar"
}

print_install_prompt() {
    printf "- Soll ich es herunterladen und installieren ([Enter]: ja, CTRL-C: nein)? "
}

print_no_update() {
    echo "Kein Update verfügbar"
}

print_A() {
    echo " Ampere"
}

print_only() {
    echo "nur"
}

print_m_mode() {
    echo "Manueller Modus"
}

print_wait() {
    echo "Gut, das kann eine Minute oder so dauern..."
}
