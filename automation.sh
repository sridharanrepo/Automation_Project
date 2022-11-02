#!/bin/bash

###To run this script user much be Root

myname=Sridharan
bucketID=upgradsridharan007

## Fristly ubuntu  package updating

echo " Ubuntu Packages Updating === STARTS "
	sudo apt update -y
echo " Successfully Ubuntu Packages Updated "

## Secondly to check apache2 installed or not. If not, this command will start apache2 instalation

echo " Checking Apache2 is Installed or Not "

if systemctl --all --type service | grep -q "apache2"
then
	echo " Apache2 Was Installed Already "
else
	echo " Apache2 Was Not Installed "
	echo " Apache2 Started Installing "
	sudo apt install apache2 -y
fi

## Thirdly to check Apache2 is Running or Not. If not, this command will start apache2 Running

echo " Ensuring Apache2 is Running or Not "

Check="$(systemctl is-active apache2)"
if [ "${Check}" = "active" ]
then
	echo " Apache2 Is Running "
else
	echo " Apache2 Starts Running Now "
	sudo systemctl start apache2
fi

## Next to ensure that apache2 is Enabled or not. If not, then it will be Enabled

echo " Checking Apache2 is Enabled Or Not "
Check="$(systemctl is-enabled apache2)"
if [ "${Check}" = "enabled" ]
then
	echo " Apache2 is Already Enabled "
else
	echo " Apache2 will Enable Now "
	sudo systemctl enable apache2
fi

## Next apache .log files will save as tar file in tmp directory

echo " Log Files Starts Archiving "
	timestamp=$(date'+%d%m%Y-%H%M%S')
	LOGS="$myname-httpd-logs-$timestamp.tar"
	tar -cvf $LOGS /var/log/apache2/*.log
	mv $LOGS /tmp/
echo " Log files Archived "

## Now  the tar file will be copied to AWS S3 Bucket

echo " Tar File is sending to AWS S3 Bucket "

	aws s3 cp /tmp/$LOGS s3://$bucketID/$LOGS;

## This process is for Bookkeeping

inventorybook=/var/www/html/inventory.html
logType="httpd-logs"
timestamp=$(stat --printf%y/tmp/$LOGS | cut-d.-f1)
fileType=${LOGS##*.}
fileSize=$(ls-lh/tmp/${LOGS} | cut -d " " -f5)

echo " FILE NAME : $LOGS "
echo " LOG TYPE : $logType "
echo " CREATED TIME : $timestamp "
echo " FILE TYPE : $fileType "
echo " FILE SIZE : $fileSize "

## Now to check whether inventory file is created already or not. if not, now it will be created

if sudo test -f "$inventorybook"
then
        echo "<br>${logType}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${timestamp}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${fileType}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${fileSize}">>"${inventorybook}"
        echo " File has been Updated in Inventory "
else
        echo " Creating Now '$inventorybook' "
        touch ${inventorybook}
        echo  " <b>LOG TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DATE CREATED&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TYPE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SIZE</b>">>"${inventorybook}"
        echo "<br>${logType}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${timestamp}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${fileType}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${fileSize}">>"${inventorybook}"
        echo " '$inventorybook' is Created with all Content "
fi


## Now cron job will execute the script every day as schedule

CRON=/etc/cron.d/automation

if test -f "$CRON"

then
	
	echo " CRON JOB IS ACTIVE "
else
	
	echo " NOW CRON JOB IS CREATING $CRON "
	touch $CRON
	echo "SHELL=/bin/bash"> $CRON
	echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/urs/games:/usr/local/games:/snap/bin" >> $CRON
	echo "1 1 * * * root /root/Automation_Project/automation.sh" >> $CRON
	echo " CRON JOB ASIGNED "
fi

