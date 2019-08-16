#! /bin/bash

export msgnr=1
export tag=topprox


# temporary top settings
export TMPHOME=/tmp/$(basename $0).$$
mkdir -p $TMPHOME
trap "rm -rf $TMPHOME" EXIT


# .toprc has been base64-encoded, I found no other way of embedding it into a bash file
# if you want diferent settings, just go about, set your defaults, and 
# use the bit `base64 ~/.toprc` spits out

cat <<\__end__ | base64 --decode >$TMPHOME/.toprc
dG9wJ3MgQ29uZmlnIEZpbGUgKExpbnV4IHByb2Nlc3NlcyB3aXRoIHdpbmRvd3MpCklkOmksIE1v
ZGVfYWx0c2NyPTAsIE1vZGVfaXJpeHBzPTEsIERlbGF5X3RpbWU9My4wLCBDdXJ3aW49MApEZWYJ
ZmllbGRzY3VyPaWoMzQ7PUBEt7o5xSYnKissLS4vMDEyNTY4PD4/QUJDRkdISUpLTClNTk9QUVJT
VFVWV1hZWltcXV5fYGFiY2RlZmdoaWoKCXdpbmZsYWdzPTE5Mzg0NCwgc29ydGluZHg9MTgsIG1h
eHRhc2tzPTAsIGdyYXBoX2NwdXM9MCwgZ3JhcGhfbWVtcz0wCglzdW1tY2xyPTEsIG1zZ3NjbHI9
MSwgaGVhZGNscj0zLCB0YXNrY2xyPTEKSm9iCWZpZWxkc2N1cj2lprm3uiiztMS7vUA8p8UpKiss
LS4vMDEyNTY4Pj9BQkNGR0hJSktMTU5PUFFSU1RVVldYWVpbXF1eX2BhYmNkZWZnaGlqCgl3aW5m
bGFncz0xOTM4NDQsIHNvcnRpbmR4PTAsIG1heHRhc2tzPTAsIGdyYXBoX2NwdXM9MCwgZ3JhcGhf
bWVtcz0wCglzdW1tY2xyPTYsIG1zZ3NjbHI9NiwgaGVhZGNscj03LCB0YXNrY2xyPTYKTWVtCWZp
ZWxkc2N1cj2lurs8vb6/wMFNQk7DRDM0t8UmJygpKissLS4vMDEyNTY4OUZHSElKS0xPUFFSU1RV
VldYWVpbXF1eX2BhYmNkZWZnaGlqCgl3aW5mbGFncz0xOTM4NDQsIHNvcnRpbmR4PTIxLCBtYXh0
YXNrcz0wLCBncmFwaF9jcHVzPTAsIGdyYXBoX21lbXM9MAoJc3VtbWNscj01LCBtc2dzY2xyPTUs
IGhlYWRjbHI9NCwgdGFza2Nscj01ClVzcglmaWVsZHNjdXI9paanqKqwube6xMUpKywtLi8xMjM0
NTY4Ozw9Pj9AQUJDRkdISUpLTE1OT1BRUlNUVVZXWFlaW1xdXl9gYWJjZGVmZ2hpagoJd2luZmxh
Z3M9MTkzODQ0LCBzb3J0aW5keD0zLCBtYXh0YXNrcz0wLCBncmFwaF9jcHVzPTAsIGdyYXBoX21l
bXM9MAoJc3VtbWNscj0zLCBtc2dzY2xyPTMsIGhlYWRjbHI9MiwgdGFza2Nscj0zCkZpeGVkX3dp
ZGVzdD0wLCBTdW1tX21zY2FsZT0wLCBUYXNrX21zY2FsZT0wLCBaZXJvX3N1cHByZXNzPTAKCg==
__end__


while IFS= read line; do

echo $tag $msgnr $line

logger --journald <<__end__
MESSAGE_ID=$(journalctl --new-id | sed -n 2p)
SYSLOG_IDENTIFIER=$tag
SYSLOG_PID=$(echo $line | sed 's/ .*//')
MESSAGE=$msgnr $line
__end__

export msgnr=$((msgnr+1))
done  < <(HOME=$TMPHOME top -b -n1 -c -o %MEM | sed -n '/^ *PID/,+8p' | sed 1d)

