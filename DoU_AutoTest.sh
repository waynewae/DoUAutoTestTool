DeviceInfo=$1
ImgPath=$2
ip=$3
PreConfigScriptPath=$4
ScriptPath=$5
EraseUserData=$6

# kill adb server
adb kill-server

# find mlf file
mlf_file=$(ls $ImgPath | grep mlf)

# generate UpgrageSW.sh
echo "Generate UpgradeSW.sh"
tools/./UpgradeSWGenerator $ImgPath $mlf_file $EraseUserData
mv UpgradeSW.sh tools/
echo "Generate completely"

# make UpgrageSW.sh excutable
chmod 777 tools/UpgradeSW.sh

# launch UpgrageSW.sh
#tools/./UpgradeSW.sh $DeviceInfo

# launch ScsiCmdAgent
tools/./ScsiCmdAgent_Linux $DeviceInfo SC_SWITCH_PORT_1
adb -s $DeviceInfo wait-for-device
sleep 2
tools/./ScsiCmdAgent_Linux $DeviceInfo SC_SWITCH_ROOT
adb -s $DeviceInfo root
adb -s $DeviceInfo wait-for-device
adb -s $DeviceInfo remount
adb -s $DeviceInfo wait-for-device

# install AutoTest
echo "Start to install AutoTesting.apk"
adb -s $DeviceInfo push tools/AutoTesting.apk /system/app
sleep 5
echo "Install completely"

echo "Reboot"
adb -s $DeviceInfo reboot
adb -s $DeviceInfo wait-for-device
sleep 20
echo "Reboot completely"

# launch ScsiCmdAgent
tools/./ScsiCmdAgent_Linux $DeviceInfo SC_SWITCH_PORT_1
adb -s $DeviceInfo wait-for-device
sleep 3
tools/./ScsiCmdAgent_Linux $DeviceInfo SC_SWITCH_ROOT
adb -s $DeviceInfo root
adb -s $DeviceInfo wait-for-device
adb -s $DeviceInfo remount
adb -s $DeviceInfo wait-for-device


# set adb wifi port
echo start pre-config
adb -s $DeviceInfo shell setprop service.adb.tcp.port 5566

# pre-config
adb -s $DeviceInfo shell rm -r sdcard/AutoTesting/*
adb -s $DeviceInfo push ${PreConfigScriptPath}. /sdcard/AutoTesting
adb -s $DeviceInfo shell am start -a com.fihtdc.autotesting.autoaction -n com.fihtdc.autotesting/.AutoTestingMain -e path /sdcard/AutoTesting
sleep 18

# connect to device through wifi
adb -s $DeviceInfo connect $ip:5566
adb -s $ip:5566 wait-for-device
sleep 30

# start launching AutoTest
echo "Start RunAutoTest.sh"
tools/./RunAutoTest.sh $DeviceInfo $ip $ScriptPath
