#!/bin/bash

#	diffStagingVolder.sh - Create diff files of Staging v. Older Staging

#set -ox

#####	PARAMETERS
parmDiff="${1}"
# wONT WORK # parmDiff2="${2}"
parmDiff2=""


#####	Globals

# What/Where/Who Am I?
myCwd="$(pwd)"
myNam="$(basename ${0})"
myDir="$(dirname ${0})"
myAbs="$(readlink -f ${myDir})"


### Source Common Functions/Globals
. ${myAbs}/softDist.func


### Latest
let myLastEpoch=0
myDate1=""
myDate1num=""
myDir1=""
myDate2=""
myDate2num=""
myDir2=""
myLastDate=""
myLastDir=""


#####	FUNCTIONS

getTimes() {
# NO #	local echoIt="${1}"
	local t=""
	local ts=""
	local td=""
	local flgEpoch1=1
	local flgEpoch2=1
	for t in $(/usr/bin/find ${myRoot}/yum/.repodiffs/ -xdev -maxdepth 1 -type d) ; do
		ts="$(echo ${t} | /usr/bin/sed -n 's,^.*[/]diff_\([0-9]\+\)[_]\([0-9]\+\)\([A-Za-z]\+\)\([0-9]\+\)$,\1,p')"
		td="$(echo ${t} | /usr/bin/sed -n 's,^.*[/]diff_\([0-9]\+\)[_]\([0-9]\+\)\([A-Za-z]\+\)\([0-9]\+\)$,\2\3\4,p')"
# NO #		if [ "${echoIt}" != ""  ] ; then
# NO #	       		[ "${ts}" != "" ] && echo -en "\t ${ts}"
# NO #			[ "${td}" != "" ] && echo -en "\t ${td}"
# NO #			if [ "${ts}" != "" ] || [ "${td}" != "" ] ; then
# NO #			       echo ""
# NO #			fi
# NO #		fi
		if [ "${ts}" != "" ] ; then
			# Look for Latest Time
			if [ ${ts} -gt ${myLastEpoch} ] ; then
				### DEBUG ### echo "[DEBUG] UPDATED LATEST(${ts})!"
				let myLastEpoch=ts
				myLastDate="${td}"
				myLastDir="${t}"
			fi
			# Check if Epoch 1 exists
			if [ "${myEpoch1}" != "" ] && [ "${ts}" != "" ] && [ "${ts}" == "${myEpoch1}" ] ; then
				### DEBUG ### echo "[DEBUG] FOUND OLDER STAGING(${ts})!"
				let flgEpoch1=0
				myDate1="${td}"
				myDir1="${t}"
			fi
			# Check if Epoch 2 exists
			if [ "${myEpoch2}" != "" ] && [ "${ts}" != "" ] && [ "${ts}" == "${myEpoch2}" ] ; then
				### DEBUG ### echo "[DEBUG] FOUND NEWER STAGING(${ts})!"
				let flgEpoch2=0
				myDate2="${td}"
				myDir2="${t}"
			fi
		fi
	done
	# Flag any invalid Epoch times
	if [ ${flgEpoch1} -ne 0 ] ; then
		# OLDER STAGING (myEpoch1) is invalid
		### DEBUG ### echo "[DEBUG] INVALID OLD STAGING (${myEpoch1})!"
		let myEpoch1=-1
	fi
	if [ ${myEpoch2} -eq -9999 ] && [ ${flgEpoch2} -ne 0 ] ; then
		# Set myEpoch2 to Current Time
# WONT WORK #	# Set myEpoch2 to Latest Time if it was not passed
# WONT WORK #	### DEBUG ### echo "[DEBUG] DEFAULT TO LATEST(${myLastEpoch})"
# WONT WORK #	myEpoch2="${myLastEpoch}"
# WONT WORK #	myDate2="${myLastDate}"
# WONT WORK #	myDir2="${myLastDir}"
		myEpoch2="${myDs}"
		myDate2="${myDybd}"
		myDir2="${myRoot}/yum/.repodiffs/diff_${myDsymd}"
# WONT HAPPEN #	elif [ ${flgEpoch2} -ne 0 ] ; then
# WONT HAPPEN #		# NEWER STAGING(myEpoch2) is invalid
# WONT HAPPEN #		### DEBUG ### echo "[DEBUG] INVALID NEWER STAGING(${myEpoch2})!"
# wONT HAPPEN #		let myEpoch2=-2
	fi
# WONT HAPPEN #	if [ ${myEpoch1} -eq ${myEpoch2} ] ; then
# WONT HAPPEN #		# OLDER STAGING(myEpoch1) cannot equal NEWER STAGING(myEpoch2)
# WONT HAPPEN #		### DEBUG ### echo "[DEBUG] OLDER STAGING(${myEpoch1}) CANNOT EQUAL NEWER STAGING(${myEpoch2})!"
# WONT HAPPEN #		let myEpoch1=-3
# WONT HAPPEN #	fi
}

outTimes() {
# WONT WORK #	echo -e "\t[NEWER]\t[Optional] End Time, if not CURRENT (default)"
        echo -e ""
	echo -e "\tStaging Epoch\tStaging  Date"
	echo -e "\t-------------\t-------------"
	/usr/bin/find ${myRoot}/yum/.repodiffs/ -xdev -maxdepth 1 -type d | sed -n 's,^.*[/]diff_\([0-9]\+\)[_]\([0-9]\+\)\([A-Za-z]\+\)\([0-9]\+\)$,\t \1\t \2-\3-\4,p' | sort -n
	# WONT WORK #	[ ${myLastEpoch} -gt 0 ] && echo -e "\nLATEST:\t ${myLastEpoch}\t(NEWER USED)"
	echo -e "\nNOW:\t ${myDs}\t $(echo ${myDybd} | /bin/sed -n 's,^\([0-9]\+\)\([A-Za-z]\+\)\([0-9]\+\)$,\1-\2-\3,p') \t(will/would be CREATED as 'LATEST')"
	echo -e ""
}

mySyntax() {
	echo -e ""
# WONT WORK #	echo -e "${myNam}\tOLDER\tNEWER, if not CURRENT]"
	echo -e "${myNam}\tOLDER"
        echo -e ""
	echo -e "where:"
	echo -e "\tOLDER\tOlder Staging Time (in seconds since Epoch)"
	outTimes
}


#####	MAIN

[ "${parmDiff}" == "" ] && mySyntax && exit 127
[ "${parmDiff2}" == "" ] && parmDiff2="-9999"

# Check if parameter 1 is an integer
let myEpoch1=parmDiff 2>> /dev/null
[ $? -ne 0 ] && let let myEpoch1=-126 && echo -e "\nERROR(126):  OLDER STAGING(${parmDiff}) is NOT an integer\n" && mySyntax && exit 126

# If passed, check if parameter 2 is an integer
let myEpoch2=parmDiff2 2>> /dev/null
[ $? -ne 0 ] && let myEpoch2=-126 && echo -e "\nERROR(126):  NEWER STAGING(${parmDiff2}) is NOT an integer\n" && mySyntax && exit 126

# Validate passed Time(s), and set NEWER STAGING(myEpoch2) to latest if not passed
getTimes
if [ ${myEpoch1} -eq -3 ] && [ "${parmDiff}" == "${myDs}" ] ; then
	echo -e "\nERROR(125):  OLDER STAGING(${parmDiff}) cannot equal CURRENT(${myDs})\n" && mySyntax && exit 62
# WONT WORK # if [ ${myEpoch1} -eq -3 ] && [ "${parmDiff}" == "${myLastEpoch}" ] ; then
# WONT WORK #	echo -e "\nERROR(125):  OLDER STAGING(${parmDiff}) cannot equal LATEST(${myLastEpoch})\n" && mySyntax && exit 62
# WONT WORK # if [ ${myEpoch1} -eq -3 ] && [ "${parmDiff}" == "${myDs}" ] ; then
# WONT WORK # 	echo -e "\nERROR(125):  OLDER STAGING(${parmDiff}) cannot equal CURRENT${myDs})\n" && mySyntax && exit 62
# WONT WORK # elif [ ${myEpoch1} -eq -3 ] ; then
# WONT WORK # 	echo -e "\nERROR(125):  OLDER STAGING(${parmDiff}) cannot equal NEWER STAGING(${parmDiff2})\n" && mySyntax && exit 62
# WONT HAPPEN # elif [ ${myEpoch1} -eq -1 ] && [ ${myEpoch2} -eq -2 ] ; then
# WONT HAPPEN # 	echo -e "\nERROR(125:  Both OLDER STAGING(${parmDiff}) and NEWER STAGING(${parmDiff2}) are not listed among the following\n" && mySyntax && exit 125
elif [ ${myEpoch1} -eq -1 ] ; then
	echo -e "\nERROR(125):  OLDER STAGING(${parmDiff}) is not listed among the following\n" && mySyntax && exit 125
# WONT HAPPEN # elif [ ${myEpoch2} -eq -2 ] ; then
# WONT HAPPEN # 	echo -e "\nERROR(125):  NEWER STAGING(${parmDiff2}) is not listed among the following\n" && mySyntax && exit 125
fi

# Generate Date num based on month
myDate1num="$(echo ${myDate1} | sed -e 's/Jan/-01-/g' -e 's/Feb/-02-/g' -e 's/Mar/-03-/g' -e 's/Apr/-04-/g' -e 's/May/-05-/g' -e 's/Jun/-06-/g' -e 's/Jul/-07-/g' -e 's/Aug/-08-/g' -e 's/Sep/-09-/g' -e 's/Oct/-10-/g' -e 's/Nov/-11-/g' -e 's/Dec/-12-/g')"
myDate2num="$(echo ${myDate2} | sed -e 's/Jan/-01-/g' -e 's/Feb/-02-/g' -e 's/Mar/-03-/g' -e 's/Apr/-04-/g' -e 's/May/-05-/g' -e 's/Jun/-06-/g' -e 's/Jul/-07-/g' -e 's/Aug/-08-/g' -e 's/Sep/-09-/g' -e 's/Oct/-10-/g' -e 's/Nov/-11-/g' -e 's/Dec/-12-/g')"

echo -e "\n$(date)\n" >> ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
echo -e "\nComparing older STAGING (${myEpoch1}_${myDate1}) to STAGING (${myEpoch2}_${myDate2})\n" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log

###	If Epoch2 = current time (default), create new yum/.repodiff subdirectory with Epoch (and readable YYYYBbbdd) appended
outTimes >> ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
if [ "${myEpoch2}_${myDate2}" == "${myDsymd}" ] ; then
	echo -e "Creating directory tree (yum/.repodiffs/diff_${myDsymd}/)" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	[ ! -d "${myRoot}/yum/.repodiffs/diff_${myDsymd}/" ] && mkdir -p "${myRoot}/yum/.repodiffs/diff_${myDsymd}/files/"
fi

###	Loop on each production directory
cd ${myRoot}/yum/
for d in [A-Za-z]* ; do
	echo -e "\n[${d}]" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	
	if [ "${myEpoch2}_${myDate2}" == "${myDsymd}" ] ; then
		# Make production file list
		cd ${myRoot}/yum/
		echo -e "\tbuilding file list for PROD(yum/.repodiffs/diff_${myDsymd}/files/rpms-prod-${d}_${myDsymd}.txt)" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
		/usr/bin/find ${d}/ -mount -type f | grep '[.]rpm$' | sort -u > ${myRoot}/yum/.repodiffs/diff_${myDsymd}/files/rpms-prod-${d}_${myDsymd}.txt

		# Make staging file list
		cd ${myRoot}/yum/.staging/
		echo -e "\tbuilding file list for STAG(yum/.repodiffs/diff_${myDsymd}/files/rpms-stag-${d}_${myDsymd}.txt)" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
 		/usr/bin/find ${d}/ -mount -type f | grep '[.]rpm$' | sort > ${myRoot}/yum/.repodiffs/diff_${myDsymd}/files/rpms-stag-${d}_${myDsymd}.txt
	fi

# OLD	#	# Diff production to staging, suppress common lines, and then grab only the staging lines on the right
# OLD	#	# WRONG? # echo -e "\tcomparing file list in DIFF(yum/.repodiffs/diff_${myDsymd}/rpms-new-${d}_${myDsymd}.txt) ..." | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
# OLD	#	/usr/bin/diff --suppress-common-lines -u0 ${myRoot}/yum/.repodiffs/diff_${myDsymd}/files/rpms-prod-${d}_${myDsymd}.txt ${myRoot}/yum/.repodiffs/diff_${myDsymd}/files/rpms-stag-${d}_${myDsymd}.txt | sed -n 's,^[+]\('"${d}"'.*\)$,\1,gp' > ${myRoot}/yum/.repodiffs/diff_${myDsymd}/rpms-new-${d}_${myDsymd}.txt

	# Instead of diffing production to staging, use old file list
	echo -e "\tcomparing NEW file list in DIFF(yum/.repodiffs/diff_${myEpoch2}_${myDate2}/rpms-new-${d}_${myEpoch2}_${myDate2}.txt) ..." | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	echo -e "\t    to OLD file list in DIFF(yum/.repodiffs/diff_${myEpoch1}_${myDate1}/rpms-new-${d}_${myEpoch1}_${myDate1}.txt)" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	/usr/bin/diff --suppress-common-lines -u0 ${myRoot}/yum/.repodiffs/diff_${myEpoch1}_${myDate1}/files/rpms-stag-${d}_${myEpoch1}_${myDate1}.txt ${myRoot}/yum/.repodiffs/diff_${myEpoch2}_${myDate2}/files/rpms-stag-${d}_${myEpoch2}_${myDate2}.txt | sed -n 's,^[+]\('"${d}"'.*\)$,\1,gp' > ${myRoot}/yum/.repodiffs/diff_${myDsymd}/rpms-new-${d}_${myDsymd}.txt

	# Symlink newfiles output in main .repodiff directory for tarNewfiles.sh script *IF* they already do *NOT* exist!
	echo -e "\tsymlink file list(yum/.repodiffs/diff_${myEpoch2}_${myDate2}/rpms-new-${d}_${myEpoch2}_${myDate2}.txt) ..." | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
        echo -e "\t    into main .repodiff directory as file list(yum/.repodiffs/rpms_${d}_newfiles_${myDate2num}.txt)" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	cd ${myRoot}/yum/.repodiffs/
	if [ -e "rpms_${myDate2num}_newfiles-${d}.txt" ] ; then
		echo -e "WARNING:  Newfiles symlink(yum/.repodiffs/rpms_${myDate2num}_newfiles-${d}.txt) already exists for date(${myDate2num})!" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	elif [ -s "./diff_${myEpoch2}_${myDate2}/rpms-new-${d}_${myEpoch2}_${myDate2}.txt" ] ; then
	 	ln -s ./diff_${myEpoch2}_${myDate2}/rpms-new-${d}_${myEpoch2}_${myDate2}.txt rpms_${myDate2num}_newfiles-${d}.txt
	fi
	cd ${myRoot}/yum/.staging/

	# Make file list of staging repodata
	cd ${myRoot}/yum/.staging/
	echo -e "\tbuilding file list of REPODATA(yum/.repodiffs/diff_${myEpoch2}_${myDate2}/rpms-md-${d}_${myEpoch2}_${myDate2}.txt)" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	/usr/bin/find ${d}/ -mount -type f | grep '/repodata/' | sort > ${myRoot}/yum/.repodiffs/diff_${myEpoch2}_${myDate2}/rpms-md-${d}_${myEpoch2}_${myDate2}.txt
	# APPEND any staging 'comps.xml' (package grouping) file(s)
	/usr/bin/find ${d}/ -mount -type f | grep '/comps[.]xml$' | sort >> ${myRoot}/yum/.repodiffs/diff_${myEpoch2}_${myDate2}/rpms-md-${d}_${myEpoch2}_${myDate2}.txt
	# Symlink repo metadata output in main .repodiff directory for tarNewfiles.sh script
	cd ${myRoot}/yum/.repodiffs/
	echo -e "\tsymlink file list(yum/.repodiffs/rpms-md-${myEpoch2}_${myDate2}/rpms-md-${d}_${myEpoch2}_${myDate2}.txt) ..." | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
        echo -e "\t    into main .repodiff directory(yum/.repodiffs/rpms_${d}_repodata_${myDate2num}.txt)" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	if [ -e "rpms_${myDate2num}_newfiles-${myDate2num}.txt" ] ; then
		echo -e "WARNING:  Newfiles symlink(yum/.repodiffs/rpms_${myDate2num}}_repodata-${d}.txt) already exists for date(${myDate2num})!" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	elif [ -s "./diff_${myEpoch2}_${myDate2}/rpms-md-${d}_${myEpoch2}_${myDate2}.txt" ] ; then
		ln -s ./diff_${myEpoch2}_${myDate2}/rpms-md-${d}_${myEpoch2}_${myDate2}.txt rpms_${myDate2num}_repodata-${d}.txt
	fi
	cd ${myRoot}/yum/
done

echo -e "" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
echo -e "\n$(date)\n" >> ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log

# Change directory to when script was executed
cd ${myCwd}

