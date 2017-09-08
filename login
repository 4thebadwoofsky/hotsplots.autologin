#!/bin/bash
clear
bash ./logout

CURL_DEFAULT= -H \'Accept-Encoding: gzip, deflate, br\' -H \'Accept-Language: de-DE,de;q=0.8,en-US;q=0.6,en;q=0.4,ru;q=0.2\' -H \'Upgrade-Insecure-Requests: 1\' -H \'User-Agent: Mozilla/5.0 AppleWebKit/537.36  Chrome/60.0.3112.113 Safari/537.36\' -H \'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8\' -H \'Cache-Control: max-age=0\' -H \'Connection: keep-alive\''

CHALLENGE="17DF540" # ;-)

strindex() {
	x="${1%%$2*}"
	[[ "$x" = "$1" ]] && echo -1 || echo "${#x}"
}

echo "getting Gateway Data"
WisprGateWay=$(curl 'http://192.168.44.1/' $CURL_DEFAULT)

echo "getting Session ID"
SessionGateWay=$(curl 'http://192.168.44.1/' -L $CURL_DEFAULT)

#<li>
#<a href="?ll=de&res=notyet&uamip=192.168.44.1&uamport=80&challenge=c0d770740d80fedcf9e7fa2f217159e1&called=00-01-2E-70-3F-45&mac=08-00-27-E2-3D-37&ip=192.168.47.43&nasid=HotelGadheim-BBW&sessionid=59b16cf700000016&userurl=http%3A%2F%2F192.168.44.1%2F">
#<img src="./images/flags/flags_iso/32/de.png" alt="flag de" />
#<span class="lang_name">Deutsch</span>
#</a>
#</li>
SessionOffset=$(strindex "$SessionGateWay" "sessionid=")
SessionID=${SessionGateWay:SessionOffset}
SessionOffset=$(strindex "$SessionID" "&")
SessionID=${SessionID:SessionID}
echo $SessionID
exit;


WisprGateWay=$(echo $WisprGateWay | awk 'BEGIN{ RS="</LoginURL>"}{gsub(/.*<LoginURL>/,"");print $1}');
WisprGateWay="${WisprGateWay//&amp;/&}"
#https://www.hotsplots.de/auth/login.php?res=wispr&uamip=192.168.44.1&uamport=80&challenge=ChallengeID

WisprChallengeOffset=$(strindex "$WisprGateWay" "challenge=") #challenge parameter offset finden
WisprChallengeOffset=$((WisprChallengeOffset+10)) # 10 offset draufrechnen
WisprChallenge=${WisprGateWay:WisprChallengeOffset} #challengeid abschneiden

echo $WisprChallenge
CHALLENGE=$WisprChallenge
interfaceList=`ip -o link show | awk -F': ' '{print $2}'`

for interface in /sys/class/net/*;
do
	interfaceName=${interface:15}
	if [[ $interfaceName == "lo" ]]; then # Loopback ausschließen
		continue
	fi
	echo "Netzwerkinterface:[$interfaceName]"
	interfaceConfigIP=$(ifconfig $interfaceName | egrep -o -a -m 1 "([0-9]+\.){3}[0-9]+" | head -1)

	echo $interfaceConfigIP
	interfaceLogin=$(curl 'https://www.hotsplots.de/auth/login.php' -H 'Origin: https://www.hotsplots.de' $CURL_DEFAULT -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: https://www.hotsplots.de/auth/login.php?res=notyet&uamip=192.168.44.1&uamport=80&challenge='$CHALLENGE'&called=00-01-2E-70-3F-45&mac=40-8D-5C-B4-34-AA&ip='$interfaceConfigIP'&nasid=HotelGadheim-BBW&sessionid=&userurl=http%3a%2f%2fexample.com%2f' --data 'termsOK=on&haveTerms=1&button=kostenlos+einloggen&challenge='$CHALLENGE'&uamip=192.168.44.1&uamport=80&userurl=http%3A%2F%2Fexample.com%2F&myLogin=agb&ll=de&nasid=HotelGadheim-BBW&custom=0' --compressed -s)
	interfaceMeta=$(strindex "$interfaceLogin" '<meta http-equiv="refresh"') # offset rausfinden
	interfaceMeta=$((interfaceMeta+42)) #42 draufrechnen(<meta http-equiv) ist 42 zeichen lang bis zur url
	interfaceMeta=${interfaceLogin:interfaceMeta} #abschneiden
	interfaceMetaEnd=$(strindex "$interfaceMeta" '<center') #ende rausfinden
	interfaceMetaEnd=$((interfaceMetaEnd-4)) # 4 zeichen rückwärts gehen
	interfaceMeta=$(echo "$interfaceMeta" | cut -c -$interfaceMetaEnd) #abschneiden
	interfaceMeta="${interfaceMeta//&amp;/&}" # html entities &amp; in & umwandeln
	echo $interfaceMeta
	curl "$interfaceMeta"
	if [[ $? -eq 0 ]]; then
		echo "Das hat geklappt ;-)"
	fi
done
#curl $WispGateWay
