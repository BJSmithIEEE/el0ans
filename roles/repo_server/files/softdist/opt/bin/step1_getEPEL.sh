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
myLogEpel="${myRoot}/yum/.staging/.log/staging_rsync-EPEL${myPr0}_${myDsymd}.log"


#####	FUNCTIONS

mySyntax() {
        echo -e ""
        echo -e "${myNam}  [9|8|7]"
        echo -e ""
        echo -e "where X commits to updating the following Staging EPEL repositories from the Internet ..."
	echo -e ""
	echo -e "\t 9\tEPEL9 EPEL9-next"
	echo -e "\t 8\tEPEL8 EPEL8-modular [EPEL8-next(removed)]"
	echo -e "\t 7\tEPEL7(archived)"
        echo -e ""
}


syncEpel9 () {
date +%s > ${myLogEpel}
cat << \EOF-Epel | rsync -hirtv --stats --delete --files-from=- rsync://${myEpel}/ ${myRoot}/yum/.staging/EPEL${myPr0}/ &>> ${myLogEPel}
9/Everything/x86_64/Packages
9/Everything/x86_64/repodata
next/9/Everything/x86_64/Packages
next/9/Everything/x86_64/repodata
EOF-Epel
date +%s >> ${myLogEpel}
}

syncEpel8 () {
date +%s > ${myLogEpel}
cat << \EOF-Epel | rsync -hirtv --stats --delete --files-from=- rsync://${myEpel}/ ${myRoot}/yum/.staging/EPEL${myPr0}/ &>> ${myLogEpel}
8/Everything/x86_64/Packages
8/Everything/x86_64/repodata
8/Modular/x86_64/Packages
8/Modular/x86_64/repodata
EOF-Epel
date +%s >> ${myLogEpel}
}

# Requires Archive Mirror
syncEpel7 () {
date +%s > ${myLogEpel}
cat << \EOF-Epel | rsync -hirtv --stats --delete --files-from=- rsync://${myEArc}/ ${myRoot}/yum/.staging/EPEL${myPr0}/ &>> ${myLogEpel}
7/x86_64/Packages
7/x86_64/repodata
EOF-Epel
date +%s >> ${myLogEpel}
}


#####	MAIN

# NOTE:  This needs a lot more work

[ "${myPr0}" == "" ] && mySyntax && exit 127

case ${myPr0} in
	9)
		if [ -w "${myRoot}/yum/.staging/EPEL${myPr0}" ] ; then
			syncEpel9 &
			wait
		fi	
		;;

	8)
		if [ -w "${myRoot}/yum/.staging/EPEL${myPr0}" ] ; then
			syncEpel8 &
			wait
		fi	
		;;

	7)
		if [ -w "${myRoot}/yum/.staging/EPEL${myPr0}" ] ; then
			syncEpel7 &
			wait
		fi	
		;;
esac


