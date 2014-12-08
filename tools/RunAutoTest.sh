# 2014/11/10 Wayne
DeviceInfo=$1
ip=$2
ScriptPath=$3
charge_full=/sys/class/power_supply/battery/charge_full
charge_now=/sys/class/power_supply/battery/charge_now
capacity=/sys/class/power_supply/battery/capacity
today=$(date +"%Y%m%d")
#SleepTime=1308m
SleepTime=6m

# check charge if equal 100%
#until [ "$(adb -s $DeviceInfo shell cat $capacity)" -eq "100" ]; do
#	echo $(date +"%T")
#       echo Capacity: $(adb -s $DeviceInfo shell cat $capacity) 
#        echo " "
#	sleep 60
#done

# push movie and music
echo "Push music"
adb -s $DeviceInfo push tools/files/XJ0402.mp3 sdcard/Music/
echo "Push movie"
adb -s $DeviceInfo push tools/files/How.to.Train.Your.Dragon.2.2014.1080p.WEB-DL.AAC2.0.H264-RARBG.mkv sdcard/Movies/
echo "Push Complete"

# clean old logs of AutoTest & Power Monitor
echo "Clean logs"
adb -s $DeviceInfo shell rm -r data/data/com.fihtdc.PowerMonitor/files
adb -s $DeviceInfo shell rm -r data/data/com.fihtdc.PowerMonitor/pmix
adb -s $DeviceInfo shell rm -r sdcard/AutoTesting/*
echo "Clean completely"

# push scripts
echo "Start pushing new AutoTest scripts"
adb -s $DeviceInfo push ${ScriptPath}. /sdcard/AutoTesting
echo "Push completely"

# battery status at preparation state
echo --------------------------------------------------------------------
echo $(date +"%Y/%m/%d %T")
echo Capacity: $(adb -s $DeviceInfo shell cat $capacity)
echo Charge full: $(adb -s $DeviceInfo shell cat $charge_full)
echo Charge now: $(adb -s $DeviceInfo shell cat $charge_now)
echo "Please UNLOCK SCREEN and press ENTER to launch AutoTest."
echo --------------------------------------------------------------------
read answer

# Save starting battery status
echo $(date +"%Y/%m/%d %T")
echo $(date +"%Y/%m/%d %T") > ${today}_battery_start.txt
echo Capacity: $(adb -s $DeviceInfo shell cat $capacity)
echo Capacity,$(adb -s $DeviceInfo shell cat $capacity) >> ${today}_battery_start.txt
echo Charge full: $(adb -s $DeviceInfo shell cat $charge_full)
echo Charge full,$(adb -s $DeviceInfo shell cat $charge_full) >> ${today}_battery_start.txt
echo Charge now: $(adb -s $DeviceInfo shell cat $charge_now)
echo Charge now,$(adb -s $DeviceInfo shell cat $charge_now) >> ${today}_battery_start.txt

# launch AutoTest
adb -s $DeviceInfo shell am start -a com.fihtdc.autotesting.autoaction -n com.fihtdc.autotesting/.AutoTestingMain -e path /sdcard/AutoTesting
echo --------------------------------------------------------------------
echo "NOTICE : Please plug out USB"
echo --------------------------------------------------------------------
echo "Pull_Logs.sh will be launched after $SleepTime"
echo --------------------------------------------------------------------

# suspend
sleep $SleepTime

# pull logs
tools/Pull_Logs.sh $ip 

# send mail
tools/HtmlMail.sh $DeviceInfo
