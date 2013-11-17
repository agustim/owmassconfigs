#!/bin/bash


make_all()
{
	if [ $@ -lt 1 ]; then return; fi

	local list=$1
	local destination=${2:-}

	for i in $(cat ${list})
	do 
		HN=$(echo $i | cut -d ":" -f 1)
		IP=$(echo $i | cut -d ":" -f 2 | cut -d "/" -f 1)
		CN=$(echo $i | cut -d ":" -f 3)
		KIND=$(echo $i | cut -d ":" -f 4)
		if [ -f $KIND.qmp.save.tar.gz ];
			then
				echo Genera el ftixer $HN
				make_recoved_file $IP $HN $CN 
				if [ ! -z $destination]
				then
					mv $KIND.qmp.save.tar.gz $destination
				fi
			fi
	done
}

qmpdef_recover()
{
	if [ $# -lt 1 ]
	then 
		echo "qmp_save_recover [fileconfig]"
		return
	fi
	scp $1.qmp.save.tar.gz root@172.30.22.1:/tmp/qmp.save.tar.gz || (ssh-keygen -f "$HOME/.ssh/known_hosts" -R 172.30.22.1 ; scp $1.qmp.save.tar.gz root@172.30.22.1:/tmp/qmp.save.tar.gz)
	ssh root@172.30.22.1 qmpcontrol recover_state

}

make_recoved_file()
{
	
FILEDATA=${4:-tlwr841v8.qmp.save.tar.gz}
DIR=${5:-localtmp}

if [ $# -lt 3 ] 
	then
	echo "Generate qmp recover status file. To use in node."
	echo "	$0 <IP> <HOSTNAME> <CHANNEL> [filename. Default: ${FILEDATA}] [work directory. Default: ${DIR}]"
	return
fi
if [ ! -f ${FILEDATA} ];
then
	echo "Doesn't exist ${FILEDATA}."
	return
fi

HOSTNAMEDEST=$2

mkdir -p $DIR
cd $DIR

tar zxf ../$FILEDATA 

while read c
do
	ORIG=$(echo "$c" | cut -d "|" -f 1)
	DEST=$(echo "$c" | cut -d "|" -f 2)

	for i in $DEST
	do 
        P=$(echo $i|grep -o '\$[[:digit:]]\+')
        if [ ! -z $P ]
        then
                eval PARM=$P
                DEST=$(echo "$DEST"|sed -e "s/${P}/${PARM}/g")
        fi
	done
	echo "Change '$ORIG' -> '$DEST'"

	for i in $(fgrep -sR "$ORIG" *|cut -d: -f1|sort -u); 
	do 
		sed -i -e "s|$ORIG|$DEST|g" $i; 
	done

done < ../changes.txt

tar zcf ../${HOSTNAMEDEST}.qmp.save.tar.gz *	
cd ..
rm -rf $DIR

echo "The ${HOSTNAMEDEST}.qmp.save.tar.gz was create."
}

