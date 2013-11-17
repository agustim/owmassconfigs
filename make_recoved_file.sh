#!/bin/bash

FILEDATA=${4:-tlwr841v8.qmp.save.tar.gz}
DIR=${5:-localtmp}

if [ $# -lt 3 ] 
	then
	echo "$0: Generate qmp recover status file. To use in node."
	echo "	$0 <IP> <HOSTNAME> <CHANNEL> [filename. Default: ${FILEDATA}] [work directory. Default: ${DIR}]"
	exit
fi
IPORIG=###IP###
IPDEST=$1
HOSTNAMEORIG=###HOSTNAME###
HOSTNAMEDEST=$2
CHANNELORIG=###CHANNEL###
CHANNELDEST=$3

mkdir -p $DIR
cd $DIR

tar zxf ../$FILEDATA 

for i in $(fgrep -sR "$IPORIG" *|cut -d: -f1|sort -u); 
do 
	sed -i -e "s|$IPORIG|$IPDEST|g" $i; 
done
for i in $(fgrep -sR "$HOSTNAMEORIG" *|cut -d: -f1|sort -u); 
do 
	sed -i -e "s|$HOSTNAMEORIG|$HOSTNAMEDEST|g" $i; 
done
for i in $(fgrep -sR "option channel $CHANNELORIG" *|cut -d: -f1|sort -u); 
do 
	sed -i -e "s|option channel $CHANNELORIG|option channel $CHANNELDEST|g" $i; 
done

tar zcf ../${HOSTNAMEDEST}.qmp.save.tar.gz *	
cd ..
rm -rf $DIR

echo "The ${HOSTNAMEDEST}.qmp.save.tar.gz was create."