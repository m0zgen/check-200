#!/bin/bash
# Cretaed by Yevgeniy Gonvharov, https://sys-adm.in
# Simple uptime checker
# Cron task - * * * * * sleep 10; check-ssp.sh >/dev/null 2>&1

# Envs
# ---------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Telegram settings
TOKEN="<TOKEN>"
CHAT_ID="<ID>"

# Domain list
DOMAINs=`cat $SCRIPT_PATH/domains.txt`

# Checks
for d in ${DOMAINs}; do
   
   ips=$(dig +short $d)

   for ip in ${ips}; do
         
      stat=$(curl -s -k -I "https://${d}" --resolve "${d}:${ip}" | head -n 1 | cut -d' ' -f2)
      if [[ "$stat" != "200" || -z "$stat" ]]; then
         msg="$(date). Fail status on - ${ip} from ${d}. Response code: $stat"
         echo "$msg" >> $SCRIPT_PATH/down.log

         curl -s \
         -X POST \
         https://api.telegram.org/bot$TOKEN/sendMessage \
         -d text="$msg" \
         -d chat_id=$CHAT_ID

       else
         echo "Test for - ${ip} from $d - status - $stat"
      fi

   done

done