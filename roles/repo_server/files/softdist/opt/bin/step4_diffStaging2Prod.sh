#!/bin/bash

#	diffStagingVsProd.sh - Create diff files of Staging v. Prod

#####	PARAMETERS
parmDiff="${1}"


#####	Globals

# What/Where/Who Am I?
myCwd="$(pwd)"
myNam="$(basename ${0})"
myDir="$(dirname ${0})"
myAbs="$(readlink -f ${myDir})"


### Source Common Functions/Globals
. ${myAbs}/softDist.func


###
myMv=1		# whether to move(1) repodata to old/yum_YYYY-mm or just remove (0)


#####	FUNCTIONS

mySyntax() {
	echo -e ""
	if [ "${1}" == "" ] ; then
		echo -e "\tMeta  Date  Time\tSUBDIR (for all repositories in staging visible)"
		echo -e "\t-----------------\t--------------------------------------------------"
                cd "${myRoot}/yum/.staging"
                for d in [A-Za-z]* ; do
                        myOut="$(/usr/bin/find ./${d}/ /-xdev -type f -name repomd.xml -print 2>> /dev/null | sed -e 's,/repodata/repomd.xml,,g' 2>> /dev/null | sort -u 2>> /dev/null)"
                        if [ "${myOut}" != "" ] ; then
                                echo -e "[${d}]  STAG  (${myRoot}/yum/.staging/)"
                                /usr/bin/find ./${d}/ -xdev -type f -name repomd.xml -printf "\t%TY-%Tm-%Td  %TH:%TM\t%p\n" | sed -e 's,/repodata/repomd.xml,,g' | sort -u
				echo -e "[${d}]  PROD  (${myRoot}/yum/)"
				/usr/bin/find ../${d}/ -xdev -type f -name repomd.xml -printf "\t%TY-%Tm-%Td  %TH:%TM\t%p\n" | sed -e 's,/repodata/repomd.xml,,g' | sort
                                echo -e "\t-----------------\t--------------------------------------------------"
                        fi
                done
                cd "${myCwd}"
                echo -e ""
	fi
	echo -e ""
        echo -e "${myNam}  [1]"
        echo -e ""
	echo -e "where 1 commits to creating the diff files under tree(${myRoot}/yum/.repodiffs/)"
        echo -e ""
}


#####	MAIN

[ "${parmDiff}" != "1" ] && mySyntax && exit 127


echo -e "\n$(date)\n" >> ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
echo -e "\nComparing to PRODUCTION (usually last month)\n" >> ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log 
###	See if symlinks for current day of month already exist
for f in ${myRoot}/yum/.repodiffs/rpms_${myDybd}*.txt ${myRoot}/yum/.repodiffs/rpms_${myDymd}*.txt ; do
	if [ -s "${f}" ] ; then
		echo -e "\nERROR(63):\tCannot create new diffs, at least one or more (1+) symbolic links (or files) exist for current day." | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
		echo -e "\nPlease remove the following symbolic links (or files) before executing again ...\n" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
		ls ${myRoot}/yum/.repodiffs/rpms_${myDybd}*.txt ${myRoot}/yum/.repodiffs/rpms_${myDymd}*.txt 2>> /dev/null | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
		echo -e ""
		echo -e "\n$(date)\n" >> ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
		exit 63
	fi
done


###	Create new yum/.repodiff subdirectory with Epoch (and readable YYYYBbbdd) appended
if [ ! -d "${myRoot}/yum/.repodiffs/diff_${myDsymd}" ] ; then
	echo -e "\ncreating directory tree (yum/.repodiffs/diff_${myDsymd}) ...\n" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	mkdir -p "${myRoot}/yum/.repodiffs/diff_${myDsymd}/files/"
fi

###	Loop on each production directory
cd ${myRoot}/yum/
for d in [A-Za-z]* ; do
	echo -e "[${d}]" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	
	# Make production file list
	cd ${myRoot}/yum/
	echo -e "\tbuilding file list for PROD(yum/.repodiffs/diff_${myDsymd}/files/rpms-prod-${d}_${myDsymd}.txt) ... " | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	/usr/bin/find ${d}/ -mount -type f | grep '[.]rpm$' | sort -u > ${myRoot}/yum/.repodiffs/diff_${myDsymd}/files/rpms-prod-${d}_${myDsymd}.txt
	# Make staging file list
	cd ${myRoot}/yum/.staging/
	echo -e "\tbuilding file list for STAG(yum/.repodiffs/diff_${myDsymd}/files/rpms-stag-${d}_${myDsymd}.txt) ... " | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	/usr/bin/find ${d}/ -mount -type f | grep '[.]rpm$' | sort > ${myRoot}/yum/.repodiffs/diff_${myDsymd}/files/rpms-stag-${d}_${myDsymd}.txt

	# Diff production to staging, suppress common lines, and then grab only the staging lines on the right
	echo -e "\tcomparing file list in DIFF(yum/.repodiffs/diff_${myDsymd}/rpms-new-${d}_${myDsymd}.txt) ..." | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	/usr/bin/diff --suppress-common-lines -u0 ${myRoot}/yum/.repodiffs/diff_${myDsymd}/files/rpms-prod-${d}_${myDsymd}.txt ${myRoot}/yum/.repodiffs/diff_${myDsymd}/files/rpms-stag-${d}_${myDsymd}.txt | sed -n 's,^[+]\('"${d}"'.*\)$,\1,gp' > ${myRoot}/yum/.repodiffs/diff_${myDsymd}/rpms-new-${d}_${myDsymd}.txt
	# Symlink newfiles output in main .repodiff directory for tarNewfiles.sh script
	echo -e "\t\tsymlink file list(yum/.repodiffs/diff_${myDsymd}/rpms-new-${d}_${myDsymd}.txt)" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
        echo -e "\t\t  into main .repodiff directory (yum/.repodiffs/rpms-${d}_newfiles_${myDymd}.txt)" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	cd ${myRoot}/yum/.repodiffs/
	if [ -s "./diff_${myDsymd}/rpms-new-${d}_${myDsymd}.txt" ] ; then
	 	ln -s ./diff_${myDsymd}/rpms-new-${d}_${myDsymd}.txt rpms_${myDymd}_newfiles-${d}.txt
	fi
	cd ${myRoot}/yum/.staging/
	
	# Make file list of staging repodata
	cd ${myRoot}/yum/.staging/
	echo -e "\tbuilding file list of REPODATA(yum/.repodiffs/diff_${myDsymd}/rpms-md-${d}_${myDsymd}.txt) ..." | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	/usr/bin/find ${d}/ -mount -type f | grep '/repodata/' | sort > ${myRoot}/yum/.repodiffs/diff_${myDsymd}/rpms-md-${d}_${myDsymd}.txt
	# APPEND any staging 'comps.xml' (package grouping) file(s)
	/usr/bin/find ${d}/ -mount -type f | grep '/comps[.]xml$' | sort >> ${myRoot}/yum/.repodiffs/diff_${myDsymd}/rpms-md-${d}_${myDsymd}.txt
	# Symlink repo metadata output in main .repodiff directory for tarNewfiles.sh script
	cd ${myRoot}/yum/.repodiffs/
	echo -e "\t\tsymlink file list(yum/.repodiffs/rpms-md-${myDsymd}/rpms-new-${d}_${myDsymd}.txt)" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
        echo -e "\t\t  into main .repodiff directory(yum/.repodiffs/rpms-${d}_repodata_${myDymd}.txt)" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
	if [ -s "./diff_${myDsymd}/rpms-md-${d}_${myDsymd}.txt" ] ; then
		ln -s ./diff_${myDsymd}/rpms-md-${d}_${myDsymd}.txt rpms_${myDymd}_repodata-${d}.txt
	fi
	cd ${myRoot}/yum/
done

echo -e "" | tee -a ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log
echo -e "\n$(date)\n" >> ${myRoot}/yum/.log/prodVstag_repodiffs-${myDsymd}.log

# Change directory to when script was executed
cd ${myCwd}

