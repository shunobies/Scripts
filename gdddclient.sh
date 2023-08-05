#!/bin/bash
# Get godaddy api key https://developer.godaddy.com/keys
# Make sure to chmod a+x this file before executing.

FILE='~/gdddclient.conf'

if test -f "$FILE"; then
  mapfile -t array <$FILE
  mydomain=${array[0]}
  myhostname=${array[1]}
  gdapikey=${array[2]}
  logdest="/var/log/gdddclient.log"

  myip=`curl -s "https://api.ipify.org"`
  #hostip= dig timcomp.com | grep -A 1 'ANSWER SECTION' | grep timcomp.com | awk '{print $5}'

  dnsdata=`curl -s -X GET -H "Authorization: sso-key ${gdapikey}" "https://api.godaddy.com/v1/domains/${mydomain}/records/A/${myhostname}"`
  gdip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`
  echo "`date '+%Y-%m-%d %H:%M:%S'` - Current External IP is $myip, GoDaddy DNS IP is $gdip"

  if [ "$gdip" != "$myip" -a "$myip" != "" ]; then
    echo "IP has changed!! Updating on GoDaddy"
    curl -s -X PUT "https://api.godaddy.com/v1/domains/${mydomain}/records/A/${myhostname}" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${myip}\"}]"
    logger -p $logdest "Changed IP on ${hostname}.${mydomain} from ${gdip} to ${myip}"
  fi

  is_in_cron='~/ddclient.sh'
  cron_entry=$(crontab -l 2>&1) || exit
  new_cron_entry='*/10 * * * *    ~/gdddclient.sh > /dev/null'

  if [[ "$cron_entry" != *"$is_in_cron"* ]]; then
    printf '%s\n' "$cron_entry" "$new_cron_entry" | crontab -
  fi
else
  touch $FILE
  read -p 'Domain Name: ' mydomain
  echo $mydomain >> $FILE
  read -p 'Host Name: (Ex. Parked, www) ' myhostname
  echo $myhostname >> $FILE
  read -p 'API Key: ' apikey
  read -p 'API Secret: ' apisecret
  echo "${apikey}:${apisecret}" >> $FILE
  echo "Log file located at /var/log/gdddclient.log"
fi
