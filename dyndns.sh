#! /usr/bin/bash
#
# Script to refresh the dynamic dns ip address held at easyDNS.com
#
# Purpose: We used dynsite.exe on a Windows machine for many years to expose the house IP address.
#    I always found it a bit flaky and it recently stopped working. The weather raspberry pi
#    runs full time and it is the perfect place to run the dyndns beacon, and I have just
#    found the protocol to update the easydns servers with our IP address - simpler than
#    I thought it would be.
#
# Run:
#   * run manually
#   * run via cron (preferred)
#     crontab entry:
#          0,15,30,45 * * * * /home/ron/dyndns/dyndns.sh
#
# References:
#   * curl ifconfig.me (to get my IP address)
#     https://opensource.com/article/18/5/how-find-ip-address-linux
#
#   * easyDNS refresh string info:
#     https://kb.easydns.com/knowledge/dynamic-dns/
#     Note: The dyndns token may need replacing from time to time. 
#
# Job jar:
#   * handle long network downtime without filling up disk with error msgs [testing]
#
# Updates completed (from job jar):
#   * move variables (username, token, hostname) to shell variables for ease of updating
#   * publish to github
#   * add note to say this script replaces dynsite
#   * evaluate consequences of ip_file.txt not present
#   * trap & abandon if router or internet is not running
#   * change lasttouch file with a "touch" cmd
#   * place msgs in strings to update editing & and allow comparisons with log file.
#
# Ron G
# May, June 2024

ip_file=~/dyndns/ipfile.txt              # holds last ip address found
logfile=~/dyndns/dyndns-log.txt          # log of updates
lasttouch=~/dyndns/dyndns-lasttouch.txt  # last update - shows a heartbeat of the program
credentials=~/dyndns/credentials.cfg     # my username, token, hostname to get IP assigned
date_format='%F %R'

msg_nochange="No change"
msg_timeout="Timeout to get IP"

source $credentials                   # Initialize the folllowing fields
#username=myusername                  # Credentials are stored externally
#token=6D.............                #     to facilitate publishing the code to github
#hostname=home.myhost.ca

dyn_update="https://$username:$token@api.cp.easydns.com/dyn/generic.php?hostname=$hostname&myip=1.1.1.1"
#echo $dyn_update

if [ -e $ip_file ]
then
	stored_ip=`cat $ip_file`
else
	stored_ip=1.2.3.4                # enable to force a change for testing purposes
fi

if [ -e $lasttouch ]
then
	status=`cat $lasttouch`
else
	status="nothing"
fi

current_ip=`curl --connect-timeout 2 ifconfig.me/ip 2> /dev/null`   # flush off stuff in stderr
result=$?
#echo curl = $result

if [ $result = 28 ]   # Operation timeout. The specified time-out period was reached
then	              # according to the curl conditions.
	if [ "$status" = "$msg_timeout" ]
	then
		touch $lasttouch
		exit 1
	else
		echo $msg_timeout > $lasttouch
	fi
	echo `date +"$date_format"`: Timeout to get IP address \(network down?\) | tee -a $logfile
	echo
	exit 1
elif [ $result != 0 ]
then
	echo `date +"$date_format"`: Unknown error to get IP address \(curl = $result\) | tee -a $logfile
	echo
	exit 1
#elif [ ${result:0:8} = "upstream" ]
elif [ ${current_ip:0:8} = "upstream" ]     # upstream request timeout
then	
	echo `date +"$date_format"`: $result $current_ip | tee -a $logfile
	echo
	exit 1
fi

if [ "$stored_ip" = "$current_ip" ]
then
	# Leave an "I was here" note & exit
	if [ -e $lasttouch ] && [ "$status" = "$msg_nochange" ]
	then
		touch $lasttouch
	else
		echo $msg_nochange | tee $lasttouch
	fi
	exit 0
fi

# log "$stored_ip", "$current_ip" since they're sometimes giving spurious results
echo \"$stored_ip\", \"$current_ip\" | tee -a $logfile

# save the new ip
echo $current_ip > $ip_file

# update our IP address at easydns & log the results
curl=`curl "$dyn_update" 2> /dev/null`
update=`echo $curl | sed -e "s/<[^>]*>//g"`    # clean off the html tags
echo `date +"$date_format"`: $update | tee -a $logfile
