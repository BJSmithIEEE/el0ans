#!/bin/bash

#	chkStaging.sh - Check RPMs under yum/.staging

#####	PARAMETERS
myBas="${@}"


#####	Globals

### Basics
myCwd="$(pwd)"
myNam="$(basename ${0})"
myDir="$(dirname ${0})"
myAbs="$(readlink -f ${myDir})"


### Source Common Functions/Globals
. ${myAbs}/softDist.func



#####	FUNCTIONS

mySyntax() {
	echo -e ""
	echo -e "${myNam}  PREFIX  [PREFIX..]"
	echo -e ""
	echo -e "where PREFIX is one or more (1+) of the following for your release ..."
	echo -e ""
	cd "${myRoot}/yum/.staging"
	echo -en "\t"
	/bin/ls -d [A-Za-z]*${myR0}
	cd "${myCwd}"
	echo -e ""
}


#####	MAIN

[ "${myBas}" == "" ] && mySyntax && exit 127


# Create validation directory if it does not exist
[ ! -e "${myRoot}/yum/.staging/.validation/sig_${myDym}" ] && mkdir -p "${myRoot}/yum/.staging/.validation/sig_${myDym}" 2>> /dev/null

echo -e "\n$(date)\n" >> ${myRoot}/yum/.staging/.log/staging_validation-${myR0}_${myDsymd}.log
echo -e "Checking:  ${myBas}" | tee -a ${myRoot}/yum/.staging/.log/staging_validation-${myR0}_${myDsymd}.log
for b in ${myBas} ; do

	# Verify directory exists
	if [ -d "${myRoot}/yum/.staging/${b}" ] ; then

		# Change to staging directory
		cd "${myRoot}/yum/.staging"

		# Make sure directory belongs to your release
		let myBasChk=0
		for d in [A-Za-z]*${myR0} ; do
			[ "${d}" == "${b}" ] && let myBasChk=1
		done

		if [ ${myBasChk} -gt 0 ] ; then
			# Run validation
			echo -e "\nValidating all RPM digests/signatures for ${s} ..." | tee "${myRoot}/yum/.staging/.validation/sig_${myDym}/rpm-checkgpg_${b}-${myDsymd}.txt"
			/usr/bin/find "${b}/" -mount -type f -name '*[.]rpm' -exec rpm --checksig {} \; | tee "${myRoot}/yum/.staging/.validation/sig_${myDym}/rpm-checkgpg_${b}-${myDsymd}.txt"
			echo -e "\n${b} listing:  ${myRoot}/yum/.staging/.validation/sig_${myDym}/rpm-checkgpg_${b}-${myDsymd}.txt" | tee -a ${myRoot}/yum/.staging/.log/staging_validation-${myR0}_${myDsymd}.log
		else
			echo -e "\nPassed directory (${b}) is not valid for RedHat${myR0}\n" | tee -a ${myRoot}/yum/.staging/.log/staging_validation-${myR0}_${myDsymd}.log
			mySyntax
			echo -e "\n$(date)\n" >> ${myRoot}/yum/.staging/.log/staging_validation-${myR0}_${myDsymd}.log
			exit 8
		fi

		# Change back to original directory
		cd "${myCwd}"

	else
		echo -e "\nCannot find directory (${b}) under staging area (${myRoot}/yum/.staging/)\n" | tee -a ${myRoot}/yum/.staging/.log/staging_validation-${myR0}_${myDsymd}.log
		mySyntax
		echo -e "\n$(date)\n" >> ${myRoot}/yum/.staging/.log/staging_validation-${myR0}_${myDsymd}.log
		exit 4
	fi
done

echo -e "\n$(date)\n" >> ${myRoot}/yum/.staging/.log/staging_validation-${myR0}_${myDsymd}.log
echo -e "*****\tVerification completed, listing any invalid digest/signatures ...\n" | tee -a ${myRoot}/yum/.staging/.log/staging_validation-${myR0}_${myDsymd}.log
# Output if any signatures are 'NOT OK'
/bin/grep -i 'NOT OK' ${myRoot}/yum/.staging/.validation/sig_${myDym}/rpm-checkgpg_*-${myDsymd}.txt 2>&1 | tee -a ${myRoot}/yum/.staging/.log/staging_validation-${myR0}_${myDsymd}.log
echo -e "\nChecked:  ${myBas}\n" | tee -a ${myRoot}/yum/.staging/.log/staging_validation-${myR0}_${myDsymd}.log
echo -e "\n$(date)\n" >> ${myRoot}/yum/.staging/.log/staging_validation-${myR0}_${myDsymd}.log

