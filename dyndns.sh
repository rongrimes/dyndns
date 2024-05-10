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
#   * publish to github
#   * add note to say this script replaces dynsite
#   * evaluate consequences if router or internet is not running
#
# Updates completed (from job jar):
#   * move variables (username, token, hostname) to shell variables for ease of updating
#
# Ron G
# May 2024

ip_file=~/dyndns/ipfile.txt              # holds last ip address found
logfile=~/dyndns/dyndns-log.txt          # log of updates
lasttouch=~/dyndns/dyndns-lasttouch.txt  # last update - shows a heartbeat of the program
date_format='%F %R'

source credentials.cfg                # initialize the folllowing fields
#username=myusername                  # credentials used externally here to facilitate publishing to github
#token=6D.............
#hostname=home.myhost.ca

dyn_update="https://$username:$token@api.cp.easydns.com/dyn/generic.php?hostname=$hostname&myip=1.1.1.1"
#echo $dyn_update

stored_ip=`cat $ip_file`
#stored_ip=1.2.3.4                # enable to force a change for testing purposes

current_ip=`curl ifconfig.me/ip 2> /dev/null`   # flush off stuff in stderr
#echo NAT: $current_ip

if [ "$stored_ip" = "$current_ip" ]
then
	# Leave an "I was here" note & exit
	echo `date +"$date_format"`: No change | tee $lasttouch
	exit 0
fi

# save the new ip
echo $current_ip > $ip_file

# update our IP address at easydns & log the results
curl=`curl "$dyn_update" 2> /dev/null`
result=`echo $curl | sed -e "s/<[^>]*>//g"`    # clean off the html tags
echo `date +"$date_format"`: $result | tee -a $logfile
