#!/bin/bash

cat /etc/hosts | while read -r line; do
	#Daca am linii goale le ignor
	if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
		continue
	fi

	ip=$(echo "$line" | awk '{print $1}')
	hostname=$(echo "$line" | awk '{print $2}')

	if [[ -z "$ip" || -z "$hostname" ]]; then
		continue
	fi

	real_ip=$(nslookup "$hostname" 2>/dev/null | grep -A1 "Name:" \
			 | grep "Address:" | awk '{print $2}' | head -n1)


	if [[ -n "$real_ip" && "$real_ip" != "$ip" ]]; then
		echo "Adresa IP gresita pentru $hostname in /etc/hosts !"
		echo " /etc/hosts : $ip "
		echo " DNS server : $real_ip "
	fi
done
