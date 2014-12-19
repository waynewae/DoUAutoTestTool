#!/bin/bash
# Syntax : RunAutoTest.sh $DeviceInfo $Ip $ScriptPath 
DeviceInfo=$1
Ip=$2
ScriptPath=$3
ChargeFull=/sys/class/power_supply/battery/charge_full
ChargeNow=/sys/class/power_supply/battery/charge_now
Capacity=/sys/class/power_supply/battery/capacity
Today=$(date +"%Y%m%d")
SleepTime=1308m
#SleepTime=120m

function CheckBattery(){
	until [ "$(adb -s $DeviceInfo shell cat $Capacity)" -eq "100" ]; do
		echo $(date +"%T")
		echo Capacity: $(adb -s $DeviceInfo shell cat $Capacity) 
		echo " "
		sleep 60
	done
}

function CleanLogScript(){
	echo "Clean Power log"
	adb -s $DeviceInfo shell mv data/data/com.fihtdc.PowerMonitor/files/LoggingControl.xml data/data/com.fihtdc.PowerMonitor/.
	adb -s $DeviceInfo shell rm -r data/data/com.fihtdc.PowerMonitor/files
	adb -s $DeviceInfo shell rm -r data/data/com.fihtdc.PowerMonitor/pmix
	adb -s $DeviceInfo shell mkdir data/data/com.fihtdc.PowerMonitor/files
	adb -s $DeviceInfo shell mv data/data/com.fihtdc.PowerMonitor/LoggingControl.xml
	echo "Clean complete"
	echo "Clean Scripts and AtoTest log"
	adb -s $DeviceInfo shell rm -r sdcard/AutoTesting/*
	echo "Clean complete"
}

function PushDoUScript(){
	echo "Start pushing new DoU scripts"
	adb -s $DeviceInfo push ${ScriptPath}. /sdcard/AutoTesting
	echo "Push completely"
}

function ReadyToRun(){
	echo --------------------------------------------------------------------
	echo $(date +"%Y/%m/%d %T")
	echo Capacity: $(adb -s $DeviceInfo shell cat $Capacity)
	echo Charge full: $(adb -s $DeviceInfo shell cat $ChargeFull)
	echo Charge now: $(adb -s $DeviceInfo shell cat $ChargeNow)
	echo "Please press ENTER to launch AutoTest."
	echo --------------------------------------------------------------------
	read answer
}

function SaveBatStart(){
	echo $(date +"%Y/%m/%d %T")
	echo $(date +"%Y/%m/%d %T") > ${Today}_battery_start.txt
	echo Capacity: $(adb -s $DeviceInfo shell cat $Capacity)
	echo Capacity,$(adb -s $DeviceInfo shell cat $Capacity) >> ${Today}_battery_start.txt
	echo Charge full: $(adb -s $DeviceInfo shell cat $ChargeFull)
	echo Charge full,$(adb -s $DeviceInfo shell cat $ChargeFull) >> ${Today}_battery_start.txt
	echo Charge now: $(adb -s $DeviceInfo shell cat $ChargeNow)
	echo Charge now,$(adb -s $DeviceInfo shell cat $ChargeNow) >> ${Today}_battery_start.txt
}

function RunTest(){
	adb -s $DeviceInfo shell am start -a com.fihtdc.autotesting.autoaction -n com.fihtdc.autotesting/.AutoTestingMain -e path /sdcard/AutoTesting
	echo --------------------------------------------------------------------
	echo "NOTICE : Please plug out USB"
	echo --------------------------------------------------------------------
	echo "Pull_Logs.sh will be launched after $SleepTime"
	echo --------------------------------------------------------------------
}

function CheckArg(){
	echo "Arguments of RunAutoTest.sh"
	echo $DeviceInfo
	echo $Ip
	echo $ScriptPath
}

###############################################################################################################
# check argument of RunAutoTest.sh
CheckArg
# check charge if equal 100%
#CheckBattery
# clean old logs of AutoTest & Power Monitor & Script of WifiConfig
CleanLogScript
# push scripts
PushDoUScript
# battery status at preparation state
ReadyToRun
# Save starting battery status
SaveBatStart
# launch AutoTest
RunTest
# suspend
sleep $SleepTime
# pull logs
tools/Pull_Logs.sh $Ip
# send mail
tools/HtmlMail.sh $DeviceInfo
