#!/bin/bash
# syntax : HtmlMail.sh $DeviceInfo
Today=$(date +"%Y%m%d")
LogFolder=${Today}_logs/
LogXls=${LogFolder}${Today}_serial_test_Report.xls
LogTxt=${Today}_logs/${Today}_serial_test_Report.txt
BatteryStartFile=$(ls ${Today}_logs | grep start)
BatteryStart=${Today}_logs/$BatteryStartFile
BatteryEnd=${Today}_logs/${Today}_battery_end.txt
BatteryLevelFile=$(ls ${Today}_logs/${Today}_PowerLog | grep PowerCalculator)
BatteryLevel=${Today}_logs/${Today}_PowerLog/$BatteryFevelFile
DeviceInfo=$1

function CheckAbnormal(){
	AbnormalCount=$(ls -l ${Today}_logs/${Today}_PowerLog/ | grep abnormal | wc -l)
	if [ $AbnormalCount != 0 ] ; then
		AbnormalFile=$(ls ${Today}_logs/${Today}_PowerLog/ | grep abnormal)
		Abnormal=${Today}_logs/${Today}_PowerLog/$AbnormalFile
	fi
}

function GenerateTxtReport(){
	if [ $AbnormalCount != 0 ] ; then
		tools/./LogGenerator $Device $LogXls $LogTxt $BatteryStart $BatteryEnd $BatteryLevel $Abnormal
	else
		tools/./LogGenerator $Device $LogXls $LogTxt $BatteryStart $BatteryEnd $BatteryLevel
	fi
}

function GenerateHtmlReport(){
	LogFile=$(ls | grep DoU_AutoTest_report)
	echo $LogFile
	tools/./HtmlGenerator $LogFile $Today
}

function UploadWebServer(){
	# compose Power log and move to web server
	zip -r ${Today}_PowerLog ${Today}_logs/${Today}_PowerLog/*
	mv ${Today}_PowerLog.zip ~/Desktop/HostE/xampp/htdocs/PowerLogs/.

	# compose log folder and move to web server
	zip -r ${Today}_logs ${Today}_logs/*
	mv ${Today}_logs.zip ~/Desktop/HostE/xampp/htdocs/DoULogs/.
}

function SendMail(){
	MailType="set content_type='text/html'"
	#To="WayneWHYou@fih-foxconn.com,RexYang@fih-foxconn.com,JohnnyHHLee@fih-foxconn.com,EugeniaYYSu@fih-foxconn.com,HenryWSHsu@fih-foxconn.com,ShawnSLShih@fih-foxconn.com"
	To="WayneWHYou@fih-foxconn.com"
	Title="[$Today]DoU AutoTest Result"
	Attachment="${Today}_logs.zip"
	Body="${Today}_logs/DoU_AutoTest_report.html"
	mutt -e "$MailType" $To -s "$Title" < $Body
}

#############################################################################################################
# check if abnormal file exist
CheckAbnormal

# generate txt report file
GenerateTxtReport

# covert txt to html
GenerateHtmlReport

# move log files to log folder
mv DoU_AutoTest_report.html ${Today}_logs/.
mv DoU_AutoTest_report.txt ${Today}_logs/.

# Upload logs to web server
UploadWebServer

# send mail with attachment
SendMail
