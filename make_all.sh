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
				./make_recoved_file.sh $IP $HN $CN
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
	
}