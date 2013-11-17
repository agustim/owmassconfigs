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