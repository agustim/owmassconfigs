#!/bin/bash


make_all()
{
	if [ $# -lt 2 ] 
	then
		echo "Use: $0 <file_list> <file_changes> [destination]"
		echo " file_list: list of devices Name:IP:Channel:Kind."
		echo " file_changes: list of changes to do." 
		return; 
	fi

	local list=$1
	local chanfile=$2
	local destination=${3:-}

	[ ! -z "$destination" -a ! -d "$destination" -a ! -f "$destination" ] && mkdir -p $destination

	for i in $(cat ${list})
	do 
		HN=$(echo $i | cut -d ":" -f 1)
		IP=$(echo $i | cut -d ":" -f 2 | cut -d "/" -f 1)
		CN=$(echo $i | cut -d ":" -f 3)
		KIND=$(echo $i | cut -d ":" -f 4)
		echo -n "Genera el ftixer $HN :"
		make_recoved_file $IP $HN $CN $chanfile $KIND.qmp.save.tar.gz
		[ -f $HN.qmp.save.tar.gz ] && echo "OK"
		if [ ! -z "$destination" -a -d "$destination" -a -f $HN.qmp.save.tar.gz ]
		then
			mv $HN.qmp.save.tar.gz $destination
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
	
CHANGESFILES=${4:-changes.txt}
FILEDATA=${5:-tlwr841v8.qmp.save.tar.gz}
DEBUG=${6:-n}
DIR=${7:-localtmp}

if [ $# -lt 3 ] 
	then
	echo "Generate qmp recover status file. To use in node."
	echo "	$0 <IP> <HOSTNAME> <CHANNEL> [Changes File. Default: ${CHANGESFILES}][filename. Default: ${FILEDATA}] [Debug (y/n). Default: ${DEBUG}] [work directory. Default: ${DIR}]"
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

	if [ ${DEBUG} == "y" ]
	then	
		echo "Change '$ORIG' -> '$DEST'"
	fi

	for i in $(fgrep -sR "$ORIG" *|cut -d: -f1|sort -u); 
	do 
		sed -i -e "s|$ORIG|$DEST|g" $i; 
	done

done < ../$4

tar zcf ../${HOSTNAMEDEST}.qmp.save.tar.gz *	
cd ..
rm -rf $DIR

if [ ${DEBUG} == "y" ]
then
	echo "The ${HOSTNAMEDEST}.qmp.save.tar.gz was create."
fi
}

make_all $@