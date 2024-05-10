# dyndns

Script to refresh the home location dynamic dns ip address held at easyDNS.com

### Purpose:

We used dynsite.exe on a Windows machine for many years to expose the house IP address.
I always found it a bit flaky and it recently stopped working. The house weather raspberry pi
runs full time and it is the perfect place to run the dyndns beacon. I recently
found the protocol to update the easydns servers with our IP address - simpler than
I thought it would be.

### Run:
  * run manually
  * run via cron (preferred)
    crontab entry:
    ```
    0,15,30,45 * * * * /home/ron/dyndns/dyndns.sh > /dev/null 
    #Note: stdout is not needed/wanted. stderr will still go to mail for analysis.
    ```

### References:
  * curl ifconfig.me (to get my IP address)  
    https://opensource.com/article/18/5/how-find-ip-address-linux

  * easyDNS refresh string info:  
    https://kb.easydns.com/knowledge/dynamic-dns/  
    Note: The dyndns token may need replacing from time to time. 

### Job jar:
  * (none)

### Updates completed (from job jar):
  * move variables (username, token, hostname) to shell variables for ease of updating
  * publish to github
  * add note to say this script replaces dynsite
  * evaluate consequences of ip_file.txt not present
  * trap & abandon if router or internet is not running

Ron G  
May 2024
