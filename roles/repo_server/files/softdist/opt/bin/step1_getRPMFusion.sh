#!/bin/bash

#set -ox

#####	PARAMETERS
myPr0="${1}"

#####	GLOBALS

# What/Where/Who Am I?
myCwd="$(pwd)"
myNam="$(basename ${0})"
myDir="$(dirname ${0})"
myAbs="$(readlink -f ${myDir})"

# Source Common Functions/Globals
. ${myAbs}/softDist.func

# Internal
myLogRFus="${myRoot}/yum/.staging/.log/staging_rsync-RPMFusion${myPr0}_${myDsymd}.log"


#####	FUNCTIONS

mySyntax() {
        echo -e ""
        echo -e "${myNam}  [9|8|7]"
        echo -e ""
        echo -e "where X commits to updating the following Staging RPM Fusion repositories from the Internet ..."
        echo -e ""
	echo -e "\t 9\tRPMFusion-free-9"
	echo -e "\t 8\tRPMFusion-free-8"
	echo -e "\t 7\tRPMFusion-free-7"
        echo -e ""
}


syncRFus9 () {
date +%s > ${myLogRFus}
cat << \EOF-RFus | rsync -hirtv --stats --delete-after --exclude='**/debug/***' --files-from=- rsync://${myRFus}/ ${myRoot}/yum/.staging/RPMFusion${myPr0}/ &>> ${myLogEPel}
free/el/updates/9/x86_64
EOF-RFus
date +%s >> ${myLogRFus}
}

syncRFus8 () {
date +%s > ${myLogRFus}
cat << \EOF-RFus | rsync -hirtv --stats --delete-after --exclude='**/debug/***' --files-from=- rsync://${myRFus}/ ${myRoot}/yum/.staging/RPMFusion${myPr0}/ &>> ${myLogRFus}
free/el/updates/8/x86_64
EOF-RFus
date +%s >> ${myLogRFus}
}

syncRFus7 () {
date +%s > ${myLogRFus}
cat << \EOF-RFus | rsync -hirtv --stats --delete-after --exclude='**/debug/***' --files-from=- rsync://${myRFus}/ ${myRoot}/yum/.staging/RPMFusion${myPr0}/ &>> ${myLogRFus}
free/el/updates/7/x86_64
EOF-RFus
date +%s >> ${myLogRFus}
}


#####	MAIN

# NOTE:  This needs a lot more work

[ "${myPr0}" == "" ] && mySyntax && exit 127

case ${myPr0} in
	9)
		if [ -w "${myRoot}/yum/.staging/RPMFusion${myPr0}" ] ; then
			syncRFus9 &
			wait
		fi	
		;;

	8)
		if [ -w "${myRoot}/yum/.staging/RPMFusion${myPr0}" ] ; then
			syncRFus8 &
			wait
		fi	
		;;

	7)
		if [ -w "${myRoot}/yum/.staging/RPMFusion${myPr0}" ] ; then
			syncRFus7 &
			wait
		fi	
		;;
esac

