#!/bin/bash
# syntax : DoU_AutoTest.sh $DeviceInfo $ImgPath $Ip $ScriptPath $EraseFlag
DeviceInfo=$1
ImgPath=$2
Ip=$3
ScriptPath=$4
EraseFlag=$5

function Scsi(){
	tools/./ScsiCmdAgent_Linux $DeviceInfo SC_SWITCH_PORT_1
	adb -s $DeviceInfo wait-for-device
	sleep 2
	tools/./ScsiCmdAgent_Linux $DeviceInfo SC_SWITCH_ROOT
	adb -s $DeviceInfo root
	adb -s $DeviceInfo wait-for-device
	adb -s $DeviceInfo remount
	adb -s $DeviceInfo wait-for-device
}

function GenerateUpgradeSW(){
	echo "Generate UpgradeSW.sh"
	tools/./UpgradeSWGenerator $ImgPath $mlf_file $EraseFlag
	mv UpgradeSW.sh tools/
	echo "Generate complete"

	# make UpgrageSW.sh excutable
	chmod 777 tools/UpgradeSW.sh
}

function InstallAutoTest(){
	echo "Start to install AutoTesting.apk"
	adb -s $DeviceInfo push tools/AutoTesting.apk /system/app
	sleep 5
	echo "Install completely"
	echo "Reboot"
	adb -s $DeviceInfo reboot
	adb -s $DeviceInfo wait-for-device
	sleep 20
	echo "Reboot completely"
}

function SetPort(){
	echo "set wifi port on device"
	adb -s $DeviceInfo shell setprop service.adb.tcp.port 5566
}

function WifiConfig(){
	echo "Clean Scripts"
	adb -s $DeviceInfo shell rm -r sdcard/AutoTesting/*
	echo "Clean Complete"
	echo "Push Wifi config scripts"
	adb -s $DeviceInfo push tools/WifiConfig/. /sdcard/AutoTesting
	adb -s $DeviceInfo shell am start -a com.fihtdc.autotesting.autoaction -n com.fihtdc.autotesting/.AutoTestingMain -e path /sdcard/AutoTesting
	sleep 18
}

function WifiConnect(){
	echo "Connect to device through wifi"
	adb -s $DeviceInfo connect $Ip:5566
	adb -s $Ip:5566 wait-for-device
	sleep 30
}

###############################################################################################################
# kill adb server
adb kill-server

# find mlf file
mlf_file=$(ls $ImgPath | grep mlf)

# generate UpgrageSW.sh
GenerateUpgradeSW

# launch UpgrageSW.sh
tools/./UpgradeSW.sh $DeviceInfo

# launch ScsiCmdAgent
Scsi

# install AutoTest
InstallAutoTest

# launch ScsiCmdAgent
Scsi

# set adb wifi port
SetPort

# config adb wifi
WifiConfig

# connect to device through wifi
WifiConnect

# start launching AutoTest
echo "Start RunAutoTest.sh"
tools/./RunAutoTest.sh $DeviceInfo $Ip $ScriptPath
