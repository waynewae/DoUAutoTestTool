# 2014/11/18 Wayne
today=$(date +"%Y%m%d")
log_folder=${today}_logs/
log_xls=${log_folder}${today}_serial_test_Report.xls
log_txt=${today}_logs/${today}_serial_test_Report.txt
battery_start_file=$(ls ${today}_logs | grep start)
battery_start=${today}_logs/$battery_start_file
battery_end=${today}_logs/${today}_battery_end.txt
battery_level_file=$(ls ${today}_logs/${today}_PowerLog | grep PowerCalculator)
battery_level=${today}_logs/${today}_PowerLog/$battery_level_file
echo $battery_level

# check if abnormal file exist
abnormal_count=$(ls -l ${today}_logs/${today}_PowerLog/ | grep abnormal | wc -l)
if [ $abnormal_count != 0 ] ; then
	abnormal_file=$(ls ${today}_logs/${today}_PowerLog/ | grep abnormal)
	abnormal=${today}_logs/${today}_PowerLog/$abnormal_file
fi

device=$1

# generate txt report file
if [ $abnormal_count != 0 ] ; then
	tools/./LogGenerator $device $log_xls $log_txt $battery_start $battery_end $battery_level $abnormal
else
	tools/./LogGenerator $device $log_xls $log_txt $battery_start $battery_end $battery_level
fi

# covert txt to html
logfile=$(ls | grep DoU_AutoTest_report)
echo $logfile
tools/./HtmlGenerator $logfile $today

# move log files to log folder
mv DoU_AutoTest_report.html ${today}_logs/.
mv DoU_AutoTest_report.txt ${today}_logs/.

# compose Power log and move to web server
zip -r ${today}_PowerLog ${today}_logs/${today}_PowerLog/*
mv ${today}_PowerLog.zip ~/Desktop/HostE/xampp/htdocs/PowerLogs/.

# compose log folder and move to web server
zip -r ${today}_logs ${today}_logs/*
mv ${today}_logs.zip ~/Desktop/HostE/xampp/htdocs/DoULogs/.

# send mail with attachment
mailType="set content_type='text/html'"
#To="WayneWHYou@fih-foxconn.com,RexYang@fih-foxconn.com,JohnnyHHLee@fih-foxconn.com,EugeniaYYSu@fih-foxconn.com,HenryWSHsu@fih-foxconn.com,ShawnSLShih@fih-foxconn.com"
To="WayneWHYou@fih-foxconn.com"
title="[$today]DoU AutoTest Result"
attachment="${today}_logs.zip"
body="${today}_logs/DoU_AutoTest_report.html"

mutt -e "$mailType" $To -s "$title" < $body

