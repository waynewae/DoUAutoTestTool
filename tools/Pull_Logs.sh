#!/bin/bash
# syntax : Pull_Logs.sh $Ip
Ip=$1
Today=$(date +"%Y%m%d")
ChargeFull=/sys/class/power_supply/battery/charge_full
ChargeNow=/sys/class/power_supply/battery/charge_now
Capacity=/sys/class/power_supply/battery/capacity

function PullAutoTestLog(){
	adb -s $Ip:5566 pull sdcard/AutoTesting/.report/352546060013907.xls ${Today}_logs/${Today}_serial_test_Report.xls
	adb -s $Ip:5566 pull sdcard/AutoTesting/.report/serial_test_Report.txt ${Today}_logs/${Today}_serial_test_Report.txt
}

function PullPowerLog(){
	adb -s $Ip:5566 pull data/data/com.fihtdc.PowerMonitor/files/. ${Today}_logs/${Today}_PowerLog
	adb -s $Ip:5566 pull data/data/com.fihtdc.PowerMonitor/pmix/. ${Today}_logs/${Today}_PowerLog
}

function PullBatEnd(){
	echo $(date +"%Y/%m/%d %T") > ${Today}_logs/${Today}_battery_end.txt
	echo Capacity,$(adb -s $Ip:5566 shell cat $Capacity) >> ${Today}_logs/${Today}_battery_end.txt
	echo Charge full,$(adb -s $Ip:5566 shell cat $ChargeFull) >> ${Today}_logs/${Today}_battery_end.txt
	echo Charge now,$(adb -s $Ip:5566 shell cat $ChargeNow) >> ${Today}_logs/${Today}_battery_end.txt
}

function PullLogs(){
	adb connect $Ip:5566
	sleep 5

	# pull AutoTest logs of scripts
	PullAutoTestLog

	# pull and merge power logs
	PullPowerLog

	# pull battery status
	PullBatEnd
	
	# pull dumpsys batterystats
	adb -s $Ip:5566 shell dumpsys batterystats > ${Today}_logs/dumpsysinfo.txt
}

###############################################################################################################
# Create directory
mkdir ${Today}_logs

# Pull logs
PullLogs
PullLogs

# move starting battery status to log folder
mv *_start.txt ${Today}_logs/
