#! /bin/bash

export msgnr=1
while IFS= read line; do

echo $line

logger --journald <<__end__
MESSAGE_ID=$(journalctl --new-id | sed -n 2p)
SYSLOG_IDENTIFIER=mysqlcx
SYSLOG_PID=$(echo $line | sed 's/ .*//')
MESSAGE=$msgnr $line
__end__

export msgnr=$((msgnr+1))
done  < <(make cli CLI="db query 'show processlist'" 2>/dev/null | sed '1d;/show processlist/d')

