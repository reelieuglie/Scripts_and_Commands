#!/bin/bash 
# Source: https://unix.stackexchange.com/questions/368123/how-to-extract-the-root-ca-and-subordinate-ca-from-a-certificate-chain-in-linux
# Currently just checks OCSP
url=$1
port=$2
declare -a certlist 
sslcmd=$(which openssl)

if ! command -v openssl > /dev/null; then
	echo "The command openssl is not in the \$PATH or not installed. Please fix. Exiting."
	exit 1
fi

getcerts () {
	$sslcmd s_client -showcerts -verify 5 -connect $url:$port < /dev/null 2>/dev/null |  awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{ if(/BEGIN CERTIFICATE/){a++}; out="cert"a".pem"; print >out}' 
}
renamecerts () {
for cert in *.pem; do
   newname=$($sslcmd x509 -noout -subject -in $cert | sed -nE 's/.*CN ?= ?(.*)/\1/; s/[ ,.*]/_/g; s/__/_/g; s/_-_/-/; s/^_//g;p' | tr '[:upper:]' '[:lower:]').pem
   mv $cert $newname
   certlist+=("$newname")
   export certlist
done
}


checkocsp () {
   for i in ${certlist[@]}
   do 
   echo " ++ Checking Certificate $i ++ "
   $sslcmd x509 -in $i -noout -ocsp_uri	 
done
}

cleanup () {
  for i in ${certlist[@]}
   do
   read -p "Do you want to delete $i: " yn
   case $yn in
     [Yy]* ) echo "Deleting $i";  rm $i && echo "Deleted $i" || echo "Failed to delete $i";;
     [Nn]* ) echo "Not deleting $i";;
     * ) echo "Please answer yes or no.";;
    esac
    done
}

getcerts
renamecerts
checkocsp
cleanup 

getcerts
renamecerts
checkocsp
cleanup
