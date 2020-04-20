**Playing With Termux:API - Notifications, Toasts, Text-to-speech and More**


1) Install Termux, Termux:Boot and Termux:API APKs.
If you're not willing to pay for Termux add-ons, go for the F-Droid* versions of these AND Termux itself.
Since package signatures mismatch, you can't** install the add-ons from F-Droid if Termux was obtained from Play Store and vice versa.

2) On Termux, paste and run, as a regular user: `mkfifo ~/acc-fifo; mkdir -p ~/.termux/boot; pkg install termux-api`

3) Write your termux-api script that gets its input from ~/acc-fifo. Place the file in ~/.termux/boot/.
Example (text-to-speech):
```#!/data/data/com.termux/files/usr/bin/sh
# This file is called sore-throat.
# It talks too much.
while true; do cat ~/acc-fifo; done | termux-tts-speak```

4) Open Termux:Boot to run the script and enable auto-start.


5) ACC has the following:

auto_shutdown_alert_cmd (asac)
charg_disabled_notif_cmd (cdnc)
charg_enabled_notif_cmd (cenc)
error_alert_cmd (eac)

As the names suggest, these properties dictate commands acc/d/s should run at each event.
The default command is "vibrate <number of vibrations> <interval (seconds)>"

Let's assume you want the phone to say "Warning! Battery is low. System will shutdown soon."
To set that up...

Write a script that communicates with that from step 3:

```# This file is called warning-script.
# It's cool af!
! pgrep -f termux-tts-speak || echo 'Warning! Battery is low. System will shutdown soon.' > /data/data/com.termux/files/home/acc-fifo```

Run `acc -s auto_shutdown_alert_cmd=". /path/to/warning-script."`


\* https://duckduckgo.com/lite/?q=termux%20F-Droid

\*\* There's a workaround, but that's a story for another day.

Recommend reading: https://wiki.termux.com/wiki/Termux:API

