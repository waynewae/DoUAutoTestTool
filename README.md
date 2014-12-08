This script is only for erasing user data

change:

All
1. specify device to every adb command

DoU_AutoTest.sh
1. remove wait 300 sec when no erasing data
2. read path of pre-config scripts and DoU scripts
	format : sudo ./DoU_AutoTest.sh $DeviceInfo $SWPath $Ip $PreConfigScriptPath $DoUScriptPath $EraseFlag

RunAutoTest.sh
1. replace wait 10 min to push movie and music
2. read path of DoU scripts
	format : sudo ./RunAutoTest.sh $DeviceInfo $Ip $DoUScriptPath


temp:

HtmlMail.sh
1. send to me only
