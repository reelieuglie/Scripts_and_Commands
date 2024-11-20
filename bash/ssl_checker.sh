#!/bin/bash 
# Source: https://unix.stackexchange.com/questions/368123/how-to-extract-the-root-ca-and-subordinate-ca-from-a-certificate-chain-in-linux
# Currently just checks OCSP
url=$1
port=$2
declare -a certlist 
getcerts () {
	openssl s_client -showcerts -verify 5 -connect $url:$port < /dev/null 2>/dev/null |  awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{ if(/BEGIN CERTIFICATE/){a++}; out="cert"a".pem"; print >out}' 
}
renamecerts () {
for cert in *.pem; do
   newname=$(openssl x509 -noout -subject -in $cert | sed -nE 's/.*CN ?= ?(.*)/\1/; s/[ ,.*]/_/g; s/__/_/g; s/_-_/-/; s/^_//g;p' | tr '[:upper:]' '[:lower:]').pem
   mv $cert $newname
   certlist+=("$newname")
   export certlist
done
}


checkocsp () {
   for i in ${certlist[@]}
   do 
   echo " ++ Checking Certificate $i ++ "
   openssl x509 -in $i -noout -ocsp_uri	 
done
}

getcerts
renamecerts
checkocsp
