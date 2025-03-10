#!/bin/bash
#
#	pulp2rpms.sh
#	Create Tree of RPMs by Software Channel w/Hard Linked Packages from Red Hat Satellite 6 or other Pulp store
#
#	Must be run on the Red Hat Satellite Server itself
#	Requires hammer (in Satelite)
#	NOTE:  Does *NOT* run DNF/YUM createrepo (additional step left to user)
#		Also does *NOT* provide comps.xml (must be provided) or modularity (unknown solution w/o dnf download)
#
#	(C)2010-2012,2025 Bryan J Smith <b.j.smith@ieee.org>
#	Licensed under GPL Version 2.  All Rights Reserved.
#
#	NOTE:  Requires BASH 4 (hashes instead of searching arrays)
#

#set -ox


#####	GLOBALS

### PARAMETERS
dir_pulp="$1"
dir_media="$2"

### DEBUG
# -1 = quiet, 0 = normal, 1 = extra output, 9 = skip creation (just output)
let myDebug=0

### CONSTANTS
myName="pulp2rpms"
myDt="$(date +%s_%Y%b%d)"

### VARIABLES
declare -a arr_chanName=()
li_chanName=0
declare -a arr_chanPkgs=()
declare -A hash_pulpPkgs


#####	FUNCTIONS

### outSyntax
outSyntax() {
	echo ""
	echo "Syntax(1)"
	echo ""
	echo "  ${myName}.sh  (dir_plup)  (subdir_media)"
	echo ""
	echo "    where"
	echo "      (dir_pulp)    	Source Pulp store (usually /var/lib/pulp)"
	echo "      (subdir_media)	Media sudirectory (usually media)"
	echo ""
	echo "  NOTE:  Hard Links are used, so output will be under Pulp store"
	echo "	       E.g., /var/lib/pulp/rpms_${myDt}/"
	echo "  PERF:  BASH 4+ is required (uses hashes instead of arrays)"
	echo ""
} 


### getChanName
getChanName() {
	local i
	local l
	local li
	local lst_chan
	local n
	#	Get full list of Repositories with RPM Content from Hammer
	#	CSV Format:  1)ID 2)Name1 3)'yum' 4)Name2 5)label 6)CDN URL
	echo -e "[${myName}]\tList Repositories with RPM Content in Pulp (via hammer) ... "
	lst_chan="$(${bin_hmmr} --csv repository list --with-content 'rpm' | /bin/awk -F ',' '{ printf "%s,%s\n" , $1 , $5 }' 2>> /dev/null)" 
	if [ "${lst_chan}" == "" ] ; then
		echo -e "[${myName}] **ERROR(120)**\tHammer did not return any RPM Content" >> /dev/stderr
		exit 120
	fi
	for l in ${lst_chan} ; do
		# Must be numeric
		i="$(echo ${l} | /bin/awk -F ',' '{ printf $1 }' 2>> /dev/null | /bin/sed -n 's/^\([0-9]\+\)$/\1/p' )"
		# Must be alphanumeric or [._-]
		n="$(echo ${l} | /bin/awk -F ',' '{ printf $2 }' 2>> /dev/null | /bin/sed -n 's/^\([0-9A-Za-z._-]\+\)$/\1/p')"
		if [ "${i}" != "" ] && [ "${n}" != "" ] ; then
			[ ${myDebug} -ge 0 ] && echo -e "[${myName}]\t    Repository ${i})\t${n}" 
			arr_chanName[${i}]="${n}"
		fi
	done
	# Get last channel ID
	declare -a li=( "${!arr_chanName[@]}" )
	li_chanName=${li[-1]}
}


### getChanPkgs
getChanPkgs() {
	# Get full list of packages from Hammer
	local i
	local j
	local m
	local p
	local x
	for i in $(seq 0 ${li_chanName}) ; do
		let j=0
		if [ "${arr_chanName[${i}]}" != "" ] ; then
			[ ${myDebug} -ge 0 ] && echo -en "[${myName}]\tRepository(${arr_chanName[${i}]}): Getting package list ... (significant delay) .."
			# CSV Output: 1) Package ID 2) Package Filename 3) Package Source Filename
			# NOTE: Filter out any trailing epoch number-colon (#:), strip off any trailing '.rpm'
			arr_chanPkgs[${i}]=""
			for p in $(${bin_hmmr} --csv package list --repository-id ${i} | /bin/awk -F ',' '{ print $2 }' 2>> /dev/null | /bin/sed -e 's/[0-9]\+[:]//g' 2>> /dev/null | /bin/sed -e 's/[.]rpm$//g' 2>> /dev/null) ; do
				arr_chanPkgs[${i}]="${arr_chanPkgs[${i}]} ${p}" 
				let j=j+1
				let m=j%100 ; [ ${myDebug} -ge 0 ] && [ ${m} -eq 0 ] && echo -n ". ${j} ."
			done
			[ ${myDebug} -ge 0 ] && echo ". found(${j})"
		fi
	done
}


### getPulpPkgs
getPulpPkgs() {
	local f
	local i
	local m
	local n
	local t
	let i=0
	[ ${myDebug} -ge 0 ] && echo -en "[${myName}]\tPulp media directory(${dir_pulp}/${dir_media}): Getting package paths and names ... (significant delay) .."
	for p in $(/usr/bin/find ${dir_pulp}/${dir_media} -xdev -type f 2>> /dev/null) ; do
		# file is nearly an order of magnitude faster than rpm in identifying RPMs, even w/a grep
		/bin/file "${p}" | /usr/bin/grep -q '\sRPM\s' 2>> /dev/null
		if [ $? -eq 0 ] ; then
			# NOTE: Filter out any trailing epoch number-colon (#:)
			n="$(/usr/bin/rpm -qp ${p} 2>> /dev/null | /bin/sed -e 's/[0-9]\+[:]//g' 2>> /dev/null )"
			if [ "${n}" != "" ] ; then
				hash_pulpPkgs[${n}]="${p}"
				let i=i+1
				let m=i%100 ; [ ${myDebug} -ge 0 ] && [ ${m} -eq 0 ] && echo -n ". ${i} ."
			fi
		fi
	done
	[ ${myDebug} -ge 0 ] && echo ". found(${i})"
}


#####	MAIN

### CHECK

[ "${dir_media}" == "" ] && outSyntax && exit 1

# dir_media shouldn't have any leading dot (.) or slash (/)
tstDir="$(echo "${dir_media}" | /bin/sed -e 's,^[.]*[.]*[/]*,,g' 2>> /dev/null)"
[ "${dir_media}" != "${tstDir}" ] && echo -e "$[myName] **ERROR(126)**\tDo NOT use any leading dots (.) or slash (/) for media subdirectory name (${dir_media})" >> /dev/stderr && outSyntax && exit 126

[ "${dir_pulp}" == "" ] && outSyntax && exit 1

# dir_pulp should start with a leading slash (/) followed by at least one character
tstDir="$(echo "${dir_plup}" | /bin/sed -e 's,^/[0-9A-Za-z]\+,,g' 2>> /dev/null)"
[ "${dir_media}" == "${tstDir}" ] && echo -e "$[myName] **ERROR(125)**\tMust be an absolute path for Pulp directory (${dir_pulp})" >> /dev/stderr && outSyntax && exit 125

# dir_pulp must exist
[ ! -d "${dir_pulp}" ] && echo -e "$[myName] **ERROR(124)**\tPulp directory (${dir_pulp}) does not exist" >> /dev/stderr && outSyntax && exit 124

# dir_pulp/dir_media must exist
[ ! -d "${dir_pulp}/${dir_media}" ] && echo -e "$[myName] **ERROR(123)**\tPulp subdirectory (${dir_pulp}/${dir_media}) does not exist" >> /dev/stderr && outSyntax && exit 123

# dir_pulp/dir_media must be readable
[ ! -r "${dir_pulp}/${dir_media}" ] && echo -e "$[myName] **ERROR(122)**\tPulp subdirectory (${dir_pulp}/${dir_media}) is not readable" >> /dev/stderr && outSyntax && exit 122

# dir_pulp must be writable
[ ! -w "${dir_pulp}" ] && echo -e "$[myName] **ERROR(121)**\tPulp directory (${dir_pulp}) is not writable" >> /dev/stderr && outSyntax && exit 121

# Binary Check
bin_hmmr="`which hammer`"
[ ! -x "${bin_hmmr}" ] && echo -e "[${myName}] **ERROR(127)**\tCannot find or execute Satellite tool (hammer)" >> /dev/stderr && exit 127

# Bash verison check
[ ${BASH_VERSINFO[0]} -lt 4 ] && echo -e "[${myName}] **ERROR(127)**\tBASH version 4 or later required" >> /dev/stderr && exit 127


### CHANNELS

# Get list of channels
getChanName


### PACKAGES

# Get full list of packages from Hammer
getChanPkgs

# Get full list of packages from Pulp directory
getPulpPkgs


### MAKE TREES (FOR YUM)

# Everything should be world readable
umask 022

# Create output directory
if [ ${myDebug} -lt 9 ] ; then
	/bin/mkdir -p "${dir_pulp}/rpms_${myDt}" 2>> /dev/null
	rc=$?
else
	rc=0
fi
[ ${rc} -ne 0 ] && echo -e "[${myName}]\t**ERROR(122)** Cannot create directory(${dir_pulp}/rpms_${myDt}) mkdir(rc=${rc})" >> /dev/stderr && exit 122

# Hard link packages into YUM directories
[ ${myDebug} -ge 0 ] && echo -e "[${myName}]\tOutput Directory(${dir_pulp}/rpms_${myDt})"

# For each channel
for i in $(seq 0 ${li_chanName}) ; do
	let j=0
	if [ "${arr_chanName[${i}]}" != "" ] ; then
		let j=0
		c="${arr_chanName[${i}]}"

		# Create output directory
		if [ ${myDebug} -lt 9 ] ; then
			/bin/mkdir -p "${dir_pulp}/rpms_${myDt}/${c}/Packages" 2>> /dev/null
			rc=$?
		else
			rc=0
		fi
		[ ${rc} -ne 0 ] && echo -e "[${myName}]\t**ERROR(122)** Cannot create directory(${dir_pulp}/rpms_${myDt}/${c}/Packages) mkdir(rc=${rc})" >> /dev/stderr && exit 122

		[ ${myDebug} -ge 0 ] && echo -en "[${myName}]\t    Repository(${arr_chanName[${i}]}) - Output Directory(${dir_pulp}/rpms_${myDt}/${c}/Packages) .."
		for n in ${arr_chanPkgs[${i}]} ; do
			# Get first letter for subdirectory
			n1="$(echo ${n} | /bin/sed -n 's/^\(.\).*$/\L\1/p' 2>> /dev/null)"
			if [ ! -z "${hash_pulpPkgs[${n}]}" ] ; then
				#	Package found, create hard link
				if [ ${myDebug} -lt 9 ] ; then
					# Create Package subdirectory if it doesn't exist
					[ ! -d "${dir_pulp}/rpms_${myDt}/${c}/Packages/${n1}" ] && /bin/mkdir -p "${dir_pulp}/rpms_${myDt}/${c}/Packages/${n1}" >> /dev/null
					# Now hardlink
					/bin/ln "${hash_pulpPkgs[${n}]}" "${dir_pulp}/rpms_${myDt}/${c}/Packages/${n1}/${n}.rpm" >> /dev/null
				else
					echo "/bin/ln ${hash_pulpPkgs[${n}]}" "${dir_pulp}/rpms_${myDt}/${c}/Packages/${n1}/${n}.rpm"
				fi
				let j=j+1
			fi
			let m=j%100 ; [ ${myDebug} -ge 0 ] && [ ${m} -eq 0 ] && echo -n ". ${j} ."
		done
		[ ${myDebug} -ge 0 ] && echo ". found(${j})"
	fi
done


if [ ${myDebug} -ge 0 ] ; then
	echo -e "[${myName}]\tCompleted"
	echo -e "[${myName}]\t    Red Hat Satellite / Pulp Media directory(${dir_pulp}/${dir_media})"
	echo -e "[${myName}]\t    Hard Linked RPMs Packages Tree(${dir_pulp}/rpms_${myDt})"
	echo -e "[${myName}]\tREMEMBER:"
	echo -e "[${myName}]\t    *NO* YUM repository metadata have been created (e.g., use 'createrepo [-d comps.xml]')"
	echo -e "[${myName}]\t    *NO* comps.xml files have been provided (copy from existing YUM repos)"
	echo -e "[${myName}]\t    Use rsync or another tool to copy and ensure hard links (-H) are preserved for size"
fi

