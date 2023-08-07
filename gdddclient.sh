#!/bin/bash
# Get godaddy api key https://developer.godaddy.com/keys
# Make sure to chmod a+x this file before executing.

logdate=$(date -u)
rootDir="gdddclient/"
currentPath=$(pwd)
if [[ $currentPath =~ "Scripts" ]]; then
	echo "Path is fine"
else
	currentPath=${pwd}"/Scripts/"
fi

# Check if directory exists
if [ -d ${rootDir} ]; then
	FILE="${rootDir}gdddclient.conf"
	logdest="${rootDir}gdddclient.log"
else
	mkdir ${rootDir}
	FILE="${rootDir}gdddclient.conf"
	logdest="${rootDir}gdddclient.log"
fi

function actions () {
	mapfile -t array <$FILE
	domain=${array[0]}
	name=${array[1]}
	key=${array[2]}
	secret=${array[3]}
	port=1
	type=A
	ttl=600
	weight=1

	currentIp=$(curl -s "https://api.ipify.org")

	headers="Authorization: sso-key $key:$secret"

	result=$(curl -s -X GET -H "${headers}" \
	"https://api.godaddy.com/v1/domains/${domain}/records/${type}/${name}")

	dnsIp=$(echo $result | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
	echo "dnsIp:" $dnsIp

	# Get public ip address there are several websites that can do this.
	echo "currentIp:" $currentIp

	if [ "$dnsIp" != "$currentIp" ]; then
		echo "${logdate}: Updating Record from Previous IP ${dnsIp} to Current IP ${currentIp}" >> $logdest
		curl -X PUT "https://api.godaddy.com/v1/domains/${domain}/records/${type}/${name}" \
                -H "accept: application/json" \
                -H "Content-Type: application/json" \
                -H "$headers" \
				-d "[ { \"data\": \"${currentIp}\", \"port\": ${port}, \"priority\": 0, \"protocol\": \"string\", \"service\": \"string\", \"ttl\": ${ttl}, \"weight\": ${weight} } ]"
	fi
	if [ "$dnsIp" = "$currentIp" ]; then
		echo "${logdate}: IP's are equal, no update required" >> $logdest
	fi

	is_in_cron='gdddclient.sh'
	cron_entry=$(crontab -l 2>&1) || exit
	new_cron_entry='*/10 * * * *    '${currentPath}'gdddclient.sh > /dev/null'

	if [[ "$cron_entry" != *"$is_in_cron"* ]]; then
		printf '%s\n' "$cron_entry" "$new_cron_entry" | crontab -
	fi
	2>&1 >> ${logdest}
}

if [ -f ${FILE} ]; then
	actions
else
	touch ${FILE}
	read -p 'Domain Name: ' mydomain
	echo ${mydomain} >> ${FILE}
	read -p 'Host Name: (Ex. @, CNAME, PTR) ' myhostname
	echo ${myhostname} >> ${FILE}
	read -p 'API Key: ' apikey
	read -p 'API Secret: ' apisecret
	echo ${apikey} >> ${FILE}
	echo ${apisecret} >> ${FILE}
	echo "Log file located at ${logdest}"
	actions
fi