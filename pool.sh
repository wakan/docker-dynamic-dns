#!/bin/bash

if [ -z "$USER" ]
then
	echo "No user was set. Use USER var"
	exit 10
fi

if [ -z "$PASSWORD" ]
then
	echo "No password was set. Use PASSWORD var"
	exit 20
fi


if [ -z "$HOSTNAME" ]
then
	echo "No host name. Use HOSTNAME var"
	exit 30
fi


if [[ $INTERVAL != [0-9]* ]]
then
	echo "Interval is not an integer."
	exit 35
fi


checkip_and_update_ddns() {
	if [ -n "$DETECTIP" ]
	then
		IP=$(curl http://myexternalip.com/raw)
	fi


	if [ -n "$DETECTIP" ] && [ -z $IP ]
	then
		echo "Could not detect external IP."
		exit 42
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
	
}

if [ $INTERVAL -ne 0 ]
then
	while :
	do
		checkip_and_update_ddns
		sleep "${INTERVAL}m"
	done
fi
exit 0	
