# 2014/11/17 Wayne
ip=$1
today=$(date +"%Y%m%d")
charge_full=/sys/class/power_supply/battery/charge_full
charge_now=/sys/class/power_supply/battery/charge_now
capacity=/sys/class/power_supply/battery/capacity

mkdir ${today}_logs

adb connect $ip:5566
sleep 5

# pull AutoTest logs of scripts
adb -s $ip:5566 pull sdcard/AutoTesting/.report/352546060013907.xls ${today}_logs/${today}_serial_test_Report.xls
adb -s $ip:5566 pull sdcard/AutoTesting/.report/serial_test_Report.txt ${today}_logs/${today}_serial_test_Report.txt

# pull and merge power logs
adb -s $ip:5566 pull data/data/com.fihtdc.PowerMonitor/files/. ${today}_logs/${today}_PowerLog
adb -s $ip:5566 pull data/data/com.fihtdc.PowerMonitor/pmix/. ${today}_logs/${today}_PowerLog

# pull battery status
echo $(date +"%Y/%m/%d %T") > ${today}_logs/${today}_battery_end.txt
echo Capacity,$(adb shell cat $capacity) >> ${today}_logs/${today}_battery_end.txt
echo Charge full,$(adb shell cat $charge_full) >> ${today}_logs/${today}_battery_end.txt
echo Charge now,$(adb shell cat $charge_now) >> ${today}_logs/${today}_battery_end.txt

adb connect $ip:5566
# adb wait-for-device
sleep 5

# pull AutoTest logs of scripts
adb -s $ip:5566 pull sdcard/AutoTesting/.report/352546060013907.xls ${today}_logs/${today}_serial_test_Report.xls
adb -s $ip:5566 pull sdcard/AutoTesting/.report/serial_test_Report.txt ${today}_logs/${today}_serial_test_Report.txt

# pull and merge power logs
adb -s $ip:5566 pull data/data/com.fihtdc.PowerMonitor/files/. ${today}_logs/${today}_PowerLog
adb -s $ip:5566 pull data/data/com.fihtdc.PowerMonitor/pmix/. ${today}_logs/${today}_PowerLog

# pull battery status
echo $(date +"%Y/%m/%d %T") > ${today}_logs/${today}_battery_end.txt
echo Capacity,$(adb shell cat $capacity) >> ${today}_logs/${today}_battery_end.txt
echo Charge full,$(adb shell cat $charge_full) >> ${today}_logs/${today}_battery_end.txt
echo Charge now,$(adb shell cat $charge_now) >> ${today}_logs/${today}_battery_end.txt

# move starting battery status to log folder
mv *_start.txt ${today}_logs/
