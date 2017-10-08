# 1. While charging (USB)
# 2. While charging (AC)
# 3. While unplugged (not charging)

# 3 Zip files will be generated in /data/_cs_debug (one on each run). Upload these to the official XDA thread (link -- README).


mkdir /data/_cs
mkdir /data/_cs_debug 2>/dev/null
cd /sys/class/power_supply/battery
for f in $(ls -1); do
	[ -f $f ] && cp "$f" /data/_cs
done
cp /system/build.prop /data/_cs
cd /data/_cs

if [ -f /data/cs_debug.zip ]; then
	zip -9 /data/cs_debug_2.zip *
	echo
	zip -T /data/cs_debug_2.zip
elif [ -f /data/cs_debug_2.zip ]; then
	zip -9 /data/cs_debug_3.zip *
	echo
	zip -T /data/cs_debug_3.zip
else
	zip -9 /data/cs_debug.zip *
	echo
	zip -T /data/cs_debug.zip
fi

rm -rf /data/_cs
echo
echo Done