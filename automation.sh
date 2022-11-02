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

