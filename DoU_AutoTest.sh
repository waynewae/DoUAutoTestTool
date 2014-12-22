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

function InstallApk(){
	adb -s $DeviceInfo install ../Files/BoomBeach.apk
	adb -s $DeviceInfo install ../Files/CookieRun.apk
	adb -s $DeviceInfo install ../Files/Jorte.apk
	adb -s $DeviceInfo install ../Files/LINE.apk
	adb -s $DeviceInfo install ../Files/NewsWeather.apk
	adb -s $DeviceInfo install ../Files/Skype.apk
	adb -s $DeviceInfo install ../Files/VLC.apk
	adb -s $DeviceInfo install ../Files/Twitter.apk
}

function PushFiles(){
	adb -s $DeviceInfo push ../Files/XJ0402.mp3 sdcard/Music/.
	adb -s $DeviceInfo push ../Files/How.to.Train.Your.Dragon.2.2014.1080p.WEB-DL.AAC2.0.H264-RARBG.mkv sdcard/Movies/.
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

function CheckArg(){
	echo arguments of DoU_AutoTest.sh
	echo $DeviceInfo
	echo $Ip
	echo $ScriptPath
}

###############################################################################################################
# kill adb server
adb kill-server
adb devices
# find mlf file
mlf_file=$(ls $ImgPath | grep mlf)
# generate UpgrageSW.sh
GenerateUpgradeSW
# launch UpgrageSW.sh
tools/./UpgradeSW.sh $DeviceInfo
# install apk
InstallApk
# launch ScsiCmdAgent
Scsi
# push files
PushFiles
# pre-config
echo "Press ENTER if you finish the pre-config"
read answer
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
# check arguments passed to RunAutoTest.sh
CheckArg
# start launching AutoTest
echo "Start RunAutoTest.sh"
tools/./RunAutoTest.sh $DeviceInfo $Ip $ScriptPath
