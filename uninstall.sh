#!/system/bin/sh
# remove leftovers

(until [ -d /data/media/0/acc ]; do sleep 20; done
rm -rf /data/media/0/acc &) &
exit 0
