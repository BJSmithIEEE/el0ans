#!/bin/bash

#	updRepodata.sh - Update repodata under yum/.staging

#####	PARAMETERS
mySub="${@}"


#####	Globals

# What/Where/Who Am I?
myCwd="$(pwd)"
myNam="$(basename ${0})"
myDir="$(dirname ${0})"
myAbs="$(readlink -f ${myDir})"


### Source Common Functions/Globals
. ${myAbs}/softDist.func



#####	FUNCTIONS

mySyntax() {
	echo -e ""
	if [ "${1}" == "" ] ; then
		echo -e "Last repository metadata update ... (chronologically)\n"
		echo -e "\tMeta  Date  Time\tSUBDIR (for all repositories in staging visible)"
		echo -e "\t-----------------\t--------------------------------------------------"
		cd "${myRoot}/yum/.staging/"
                for d in [A-Za-z]* ; do
                        myOut="$(/usr/bin/find ./${d}/ -xdev -type f -name repomd.xml -print 2>> /dev/null | sed -e 's,/repodata/repomd.xml,,g' 2>> /dev/null | sort -u 2>> /dev/null)"
                        if [ "${myOut}" != "" ] ; then
                		echo -e "[${d}]   \tSTAG  (${myRoot}/yum/.staging/)"
                                /usr/bin/find ./${d}/ -xdev -type f -name repomd.xml -printf "\t%TY-%Tm-%Td  %TH:%TM\t%p\n" | sed -e 's,/repodata/repomd.xml,,g' | sort -u
                                echo -e "\t-----------------\t--------------------------------------------------"
                        fi
                done
                cd "${myCwd}"
		echo -e ""
	fi
	echo -e ""
	echo -e "Syntax:  ${myNam}  SUBDIR  [SUBDIR..]"
	echo -e ""
	echo -e "Where SUBDIR is one or more (1+) of the following for RedHat${myR0} ... (chronologically)\n"
	echo -e "\tMeta  Date  Time\tSUBDIR (for RedHat${myR0} repositories in staging)"
	echo -e "\t-----------------\t--------------------------------------------------"
        cd "${myRoot}/yum/.staging"
        for d in [A-Za-z]*${myR0} ; do
                myOut="$(/usr/bin/find ./${d}/ -xdev -type f -name repomd.xml -print 2>> /dev/null | sed -e 's,/repodata/repomd.xml,,g' 2>> /dev/null | sort -u 2>> /dev/null)"
                if [ "${myOut}" != "" ] ; then
                        echo -e "[${d}]   \tSTAG  (${myRoot}/yum/.staging/)"
                        /usr/bin/find ./${d}/ -xdev -type f -name repomd.xml -printf "\t%TY-%Tm-%Td  %TH:%TM\t%p\n" | sed -e 's,/repodata/repomd.xml,,g' | sort -u
                        echo -e "\t-----------------\t--------------------------------------------------"
                fi
        done
        cd "${myCwd}"
	echo -e ""
}


#####	MAIN

[ "${mySub}" == "" ] && mySyntax && exit 127


echo -e "\n$(date)\n" >> ${myRoot}/yum/.staging/.log/staging_updatemd-${myR0}_${myDsymd}.log
echo -e "Checking:  ${mySub}\n" | tee -a ${myRoot}/yum/.staging/.log/staging_updatemd-${myR0}_${myDsymd}.log
for s in ${mySub} ; do

	# Verify subdirectory exists
	if [ -d "${myRoot}/yum/.staging/${s}" ] ; then

		# Change to staging subdirectory
		cd "${myRoot}/yum/.staging/${s}"

		# Make sure directory belongs to your release
		let mySubChk=1
		#let mySubChk=0
		#for d in [A-Za-z]*${myR0} ; do
		#	[ "${d}" == "${s}" ] && let mySubChk=1
		#done

		if [ ${mySubChk} -gt 0 ] ; then
			# Run createrepo
			if [ -r "comps.xml" ] ; then
				echo -e "\nUpdating staging repository metadata for ${s} (w/group information) ..." | tee -a ${myRoot}/yum/.staging/.log/staging_updatemd-${myR0}_${myDsymd}.log
				createrepo --groupfile comps.xml --update --verbose --workers 4 ./ 2>&1 | tee -a ${myRoot}/yum/.staging/.log/staging_updateme-${myR0}_${myDsymd}.log
			else
				echo -e "\nUpdating staging repository metadata for ${s} (NO group information) ...\n" | tee -a ${myRoot}/yum/.staging/.log/staging_updatemd-${myR0}_${myDsymd}.log
				createrepo --update --verbose --workers 4 ./ 2>&1 | tee -a ${myRoot}/yum/.staging/.log/staging_updatemd-${myR0}_${myDsymd}.log
			fi
		else
			echo -e "\n*** ERROR ***\tPassed directory (${s}) is not valid for RedHat${myR0}\n"
			mySyntax 8
			echo -e "\n$(date)\n" >> ${myRoot}/yum/.staging/.log/staging_updatemd-${myR0}_${myDsymd}.log
			exit 8

		fi

		# Change back to original directory
		cd "${myCwd}"

	else
		echo -e "\n*** ERROR ***\tCannot find subdirectory (${s}) under staging area (${myRoot}/yum/.staging/)\n"
		mySyntax 4
		echo -e "\n$(date)\n" >> ${myRoot}/yum/.staging/.log/staging_updatemd-${myR0}_${myDsymd}.log
		exit 4
	fi
done
echo -e "\nChecked:  ${mySub}\n" | tee -a ${myRoot}/yum/.staging/.log/staging_updatemd-${myR0}_${myDsymd}.log
echo -e "\n$(date)\n" >> ${myRoot}/yum/.staging/.log/staging_updatemd-${myR0}_${myDsymd}.log

