#!/bin/sh

usage(){
        echo "Script for automate patching process in Monsanto RHEL Servers"
        echo "Usage: $0 <REPO> <OUTPUT FILE>"
        exit 1
}

get_current_repo(){
	echo $(cat /etc/yum.repos.d/*.repo | egrep -i '(rhel[[:digit:]]{1}\/([[:digit:]]{4}-\d{2}-[[:digit:]]{2}|[[:alpha:]]*).+x86_64-server-[[:digit:]]\/$|rhel[[:digit:]]{1}\/current/rhel-x86_64-server-[[:digit:]]\/$)' | awk '{split($0,a,"/"); print a[6]}')
	
}


[[ $# -lt 2 ]] && usage
        new_repo=$1
        output_file=$2
        echo $(cat /etc/redhat-release) | tee -a $output_file
        echo -n "Are you proceed to patch the current system (y/n)? "
	read answer_proceed
	if echo "$answer_proceed" | grep -iq "^y" ; then
    		echo $(uptime) | tee -a $output_file
 	else
 		exit 1
    		
	fi

	touch $output_file 
	echo "=> Current Repo is: $(get_current_repo)"  | tee -a $output_file
	echo "=> Your report selected in parameters: $new_repo" | tee -a $output_file
        echo -n "Is this a same repo (y/n)? "
	read answer
	if echo "$answer" | grep -iq "^y" ; then
    		echo "=> Repo not modified" | tee -a $output_file
 	else
            {
                sed -i -e "s/$(get_current_repo)/$new_repo/" /etc/yum.repos.d/mon_rhel6.repo | tee -a $output_file
		echo "=> Current Repo is: $(get_current_repo)"  | tee -a $output_file
	    }
        fi
        echo "=> Starting cleaning"
        yum clean all | tee -a $output_file
        echo "=> Patching"
        yum -y update | tee -a $output_file
        echo "=> Finished"

	echo -n "Do you want to reboot the system (y/n)? "
	read answer_reboot
	if echo "$answer_reboot" | grep -iq "^y" ; then
    		echo "=> Rebooting system: $(date)" | tee -a $output_file
                sleep 5 && reboot
 	else
 		exit 1
    		
	fi
        



