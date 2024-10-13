#!/bin/bash

#####	PARAMETERS
myGet="${1}"

#####	GLOBALS

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
	echo -e "where 1 commits to updating the following Staging Third Party Software (TPS) repositories from the Internet ..."
        case ${myV}${myR0} in
                redhat9)
                        echo -e "\t${cTPS9} gitlab_gitlab-ce gitlab_gitlab-ee"
                        ;;
                redhat8)
                        echo -e "\t${cTPS8} gitlab_gitlab-ce gitlab_gitlab-ee"
                        ;;
                redhat7)
                        echo -e "\t${cTPS7} gitlab_gitlab-ce gitlab_gitlab-ee"
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

# All TPS but GitLab
echo -e "\n$(date)\n" >> ${myRoot}/yum/.staging/.log/staging_reposync-TPS${myR0}_${myDsymd}.log
case ${myV}${myR0} in
	redhat9)
		if [ -w "${myRoot}/yum/.staging/TPS${myR0}" ] && [ "${cTPS9}" != "" ] ; then
			for r in ${cTPS9} ; do
				echo -e "\nDownloading repo(${r}) into repo tree(yum/.staging/TPS${myR0}/x86_64/${r}/) ..." | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-TPS${myR0}_${myDsymd}.log
				dnf reposync --downloadcomps --download-metadata --download-path=${myRoot}/yum/.staging/TPS${myR0}/x86_64/${r} --gpgcheck --norepopath --repoid=${r} 2>&1 | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-TPS${myR0}_${myDsymd}.log
			done
		fi	
		;;

	redhat8)
		if [ -w "${myRoot}/yum/.staging/TPS${myR0}" ] && [ "${cTPS8}" != "" ] ; then
			for r in ${cTPS8} ; do
				echo -e "\nDownloading repo(${r}) into repo tree(yum/.staging/TPS${myR0}/x86_64/${r}/) ..." | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-TPS${myR0}_${myDsymd}.log
				dnf reposync --downloadcomps --download-metadata --download-path=${myRoot}/yum/.staging/TPS${myR0}/x86_64/${r} --gpgcheck --norepopath --repoid=${r} 2>&1 | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-TPS${myR0}_${myDsymd}.log
			done
		fi
		;;

	redhat7)
		if [ -w "${myRoot}/yum/.staging/TPS${myR0}" ] && [ "${cTPS7}" != "" ] ; then
			for r in ${cTPS7} ; do
				echo -e "\nDownloading repo(${r}) into repo tree(yum/.staging/TPS${myR0}/x86_64/${r}/) ..." | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-TPS${myR0}_${myDsymd}.log
				# reposync --downloadcomps --download-metadata --plugins --download_path=${myRoot}/yum/.staging/TPS${myR0}/x86_64/${r} --gpgcheck --norepopath --repoid=${r} 2>&1 | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-TPS${myR0}_${myDsymd}.log
				reposync --downloadcomps --download-metadata --plugins --download_path=${myRoot}/yum/.staging/TPS${myR0}/x86_64/${r} --norepopath --repoid=${r} 2>&1 | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-TPS${myR0}_${myDsymd}.log
			done
		fi
		;;
esac

# GitLab
if [ -w "${myRoot}/yum/.staging/TPS${myR0}" ] && [ "${vGitLab}" != "" ] ; then
	for c in ce ee ; do
		echo -e "\nDownloading select updates for repo(gitlab_gitlab-${c}) into repo tree(yum/.staging/TPS${myR0}/x86_64/gitlab_gitlab-${c}/) ..." | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-TPS${myR0}_${myDsymd}.log
		for v in ${vGitLab} ; do
			if [ ${myR0} -ge 8 ] ; then
				dnf download --enablerepo=gitlab_gitlab-${c} --destdir /storage/softdist/yum/.staging/TPS${myR0}/x86_64/gitlab_gitlab-${c}/ gitlab-${c}-${v}-${c}.0.el${myR0}.x86_64 2>&1 | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-TPS${myR0}_${myDsymd}.log
			else
				yumdownloader --enablerepo=gitlab_gitlab-${c} --destdir /storage/softdist/yum/.staging/TPS${myR0}/x86_64/gitlab_gitlab-${c}/ gitlab-${c}-${v}-${c}.0.el${myR0}.x86_64 2>&1 | tee -a ${myRoot}/yum/.staging/.log/staging_reposync-TPS${myR0}_${myDsymd}.log
			fi
		done
	done
fi	
echo -e "\n$(date)\n" >> ${myRoot}/yum/.staging/.log/staging_reposync-TPS${myR0}_${myDsymd}.log

