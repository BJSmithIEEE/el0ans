#!/bin/bash

#####	PARAMETERS
myGet="${1}"

#####   GLOBALS

# What/Where/Who Am I?
myCwd="$(pwd)"
myNam="$(basename ${0})"
myDir="$(dirname ${0})"
myAbs="$(readlink -f ${myDir})"


# Source Common Functions/Globals
. ${myAbs}/softDist.func


#####   FUNCTIONS

mySyntax() {
        echo -e ""
        echo -e "${myNam}  [1]"
        echo -e ""
        echo -e "where 1 commits to updating the following Staging RHEL repositories from the Internet ..."
	case ${myV}${myR0} in
	        redhat9)
			echo -e "\t${cRedHat9}"
			;;
		redhat8)
			echo -e "\t${cRedHat8}"
			;;
		redhat7)
			echo -e "\t${cRedHat7}"
			;;
		redhat7wks)
			echo -e "\t${cRedHat7wks}"
			;;
		*)
			echo -e "\tUNKNOWN"
			;;
	esac
        echo -e ""
}


#####	MAIN

# NOTE:  This needs a lot more work, like using hashes instead of named variables (no need for case statement), log redirection, etc...

[ "${myGet}" == "" ] && mySyntax && exit 127

echo -e "\n$(date)\n" >> ${myRoot}/yum/.staging/.log/staging_reposync-RedHat${myR0}_${myDsymd}.log
case ${myV}${myR0} in
	redhat9)
		if [ -w "${myRoot}/yum/.staging/RedHat${myR0}" ] && [ "${cRedHat9}" != "" ] ; then
			for r in ${cRedHat9} ; do
				echo -e "\nDownloading repo(${r}) into repo tree(yum/.staging/RedHat${myR0}/x86_64/) ..." | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-RedHat${myR0}_${myDsymd}.log
				dnf reposync --downloadcomps --download-metadata ${xRedHat9} --download-path=${myRoot}/yum/.staging/RedHat${myR0}/x86_64 --gpgcheck --repoid=${r} 2>&1 | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-RedHat${myR0}_${myDsymd}.log
			done
		fi
		;;

	redhat8)
		if [ -w "${myRoot}/yum/.staging/RedHat${myR0}" ] && [ "${cRedHat8}" != "" ] ; then
			for r in ${cRedHat8} ; do
				echo -e "\nDownloading repo(${r}) into repo tree(yum/.staging/RedHat${myR0}/x86_64/) ..." | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-RedHat${myR0}_${myDsymd}.log
				dnf reposync --downloadcomps --download-metadata ${xRedHat8} --download-path=${myRoot}/yum/.staging/RedHat${myR0}/x86_64 --gpgcheck --repoid=${r} 2>&1 | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-RedHat${myR0}_${myDsymd}.log
			done
		fi
		;;

	redhat7)
		if [ -w "${myRoot}/yum/.staging/RedHat${myR0}" ] && [ "${cRedHat7}" != "" ] ; then
			for r in ${cRedHat7} ; do
				echo -e "\nDownloading repo(${r}) into repo tree(yum/.staging/RedHat${myR0}/x86_64/) ..." | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-RedHat${myR0}_${myDsymd}.log
				# reposync --downloadcomps --download-metadata --plugins --download_path=${myRoot}/yum/.staging/RedHat${myR0}/x86_64 --gpgcheck --repoid=${r} 2>&1 | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-RedHat${myR0}_${myDsymd}.log
				reposync --downloadcomps --download-metadata --plugins --download_path=${myRoot}/yum/.staging/RedHat${myR0}/x86_64 --repoid=${r} 2>&1 | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-RedHat${myR0}_${myDsymd}.log
			done
		fi
		;;
	redhat7wks)
		if [ -w "${myRoot}/yum/.staging/RedHat${myR0}" ] && [ "${cRedHat7wks}" != "" ] ; then
			for r in ${cRedHat7wks} ; do
				echo -e "\nDownloading repo(${r}) into repo tree(yum/.staging/RedHat${myR0}/x86_64//) ..." | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-RedHat${myR0}_${myDsymd}.log
				# reposync --downloadcomps --download-metadata --plugins --download_path=${myRoot}/yum/.staging/RedHat${myR0}/x86_64 --gpgcheck --repoid=${r} 2>&1 | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-RedHat${myR0}_${myDsymd}.log
				reposync --downloadcomps --download-metadata --plugins --download_path=${myRoot}/yum/.staging/RedHat${myR0}/x86_64 --repoid=${r} 2>&1 | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-RedHat${myR0}_${myDsymd}.log
			done
		fi
		;;
esac
echo -e "\n$(date)\n" >> ${myRoot}/yum/.staging/.log/staging_reposync-RedHat${myR0}_${myDsymd}.log

