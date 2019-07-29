#!/bin/bash

if [ -z "$USER" ]
then
	echo "No user was set. Use -u=username"
	exit 10
fi

if [ -z "$PASSWORD" ]
then
	echo "No password was set. Use -p=password"
	exit 20
fi


if [ -z "$HOSTNAME" ]
then
	echo "No host name. Use -h=host.example.com"
	exit 30
fi


if [ -n "$DETECTIP" ]
then
	IP=$(wget -qO- "http://myexternalip.com/raw")
fi


if [ -n "$DETECTIP" ] && [ -z $IP ]
then
	RESULT="Could not detect external IP."
	exit 42
fi


if [[ $INTERVAL != [0-9]* ]]
then
	echo "Interval is not an integer."
	exit 35
fi
SERVICEURL="www.changeip.com/nic/update"

BASE64AUTH=$(echo -n "$USER:$PASSWORD" | base64 | tr -d \\n)
AUTHHEADER="Authorization: Basic $BASE64AUTH"
NOIPURL="https://$SERVICEURL"

if [ -n "$IP" ] || [ -n "$HOSTNAME" ]
then
	NOIPURL="$NOIPURL?"
fi

if [ -n "$HOSTNAME" ]
then
	NOIPURL="${NOIPURL}hostname=${HOSTNAME}"
fi

if [ -n "$IP" ]
then
	if [ -n "$HOSTNAME" ]
	then
		NOIPURL="$NOIPURL&"
	fi
	NOIPURL="${NOIPURL}myip=$IP"
fi

echo "$NOIPURL  -H "$AUTHHEADER"  -H 'Connection: keep-alive'"

RESULT=$(curl -X GET   $NOIPURL  -H "$AUTHHEADER"  -H 'Connection: keep-alive')
echo $RESULT

	if [ $INTERVAL -eq 0 ]
	then
		break
	else
		sleep "${INTERVAL}m"
	fi
exit 0	
