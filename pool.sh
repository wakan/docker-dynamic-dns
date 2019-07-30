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

checkip_and_update_ddns() {
	if [ -n "$DETECTIP" ]
	then
		IP=$(curl -s http://myexternalip.com/raw)
	fi


	if [ -n "$DETECTIP" ] && [ -z $IP ]
	then
		echo "Could not detect external IP."
	fi

	HOSTNAMES=($(echo $HOSTNAME | tr "," "\n"))
	for CUR_HOST in "${HOSTNAMES[@]}"
	do
		echo $CUR_HOST

		if test -f "/tmp/$CUR_HOST.ip"; then	
			LAST_IP=$(cat /tmp/$CUR_HOST.ip)
			#echo "Last ip : $LAST_IP"
			if [ "$IP" == "$LAST_IP" ]
			then
				#echo "same ip $IP"
				return
			else
				echo "Last ip $LAST_IP change to $IP"
			fi
		fi

		SERVICEURL="www.changeip.com/nic/update"

		BASE64AUTH=$(echo -n "$USER:$PASSWORD" | base64 | tr -d \\n)
		AUTHHEADER="Authorization: Basic $BASE64AUTH"
		NOIPURL="https://$SERVICEURL"

		if [ -n "$IP" ] || [ -n "$CUR_HOST" ]
		then
			NOIPURL="$NOIPURL?"
		fi

		if [ -n "$CUR_HOST" ]
		then
			NOIPURL="${NOIPURL}hostname=${CUR_HOST}"
		fi

		if [ -n "$IP" ]
		then
			if [ -n "$CUR_HOST" ]
			then
				NOIPURL="$NOIPURL&"
			fi
			NOIPURL="${NOIPURL}myip=$IP"
		fi

		#echo "$NOIPURL  -H "$AUTHHEADER"  -H 'Connection: keep-alive'"

		RESULT=$(curl -s -X GET   $NOIPURL  -H "$AUTHHEADER"  -H 'Connection: keep-alive')
		echo $RESULT

		echo $IP > /tmp/$CUR_HOST.ip

	done	
}

checkip_and_update_ddns

exit 0	
