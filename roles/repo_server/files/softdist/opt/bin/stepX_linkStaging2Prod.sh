#!/bin/bash

#	linkStaging2Prod.sh - Hard Link Staging to Prod

#####	PARAMETERS
parmDym="${1}"


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
                        myOut="$(/usr/bin/find ./${d}/ -xdev -type f -name repomd.xml -print 2>> /dev/null | sed -e 's,/repodata/repomd.xml,,g' 2>> /dev/null | sort -u 2>> /dev/null)"
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
        echo -e "Syntax:  ${myNam}  [YYYY-mm]"
        echo -e ""
	echo -e "Where YYYY-mm is the Year-Month date tag for the PREVIOUS PROD (usually LAST month)"
	echo -e "\tto create into the old tree(${myRoot}/yum/.old/)"
        echo -e ""
}


#####	MAIN

[ "${parmDym}" == "" ] && mySyntax && exit 127


###	See if old YUM directory already exists
if [ -d "${myRoot}/yum/.old/yum_${parmDym}" ] ; then
	echo -e "\nINFO:\tOld YUM repo tree(${myRoot}/yum/.old/yum_${parmDym}) already exists"
	echo -e "\twill skip hard linking RPMs and remove old repodata directories instead of moving."
	let myMv=0
else
	echo -e "\nINFO:\tCreate old YUM repo tree(${myRoot}/yum/.old/yum_${parmDym})"
	cd "${myRoot}/yum/.old/"
	mkdir -p "${myRoot}/yum/.old/yum_${parmDym}"
	/bin/rm -f "${myRoot}/yum/.old/yum-last"
	ln -s "${myRoot}/yum/.old/yum_${parmDym}" "${myRoot}/yum/.old/yum-last"
	let myMv=1
	cd ${myCwd}
fi

###	Step 0a:  Make all new directories in old repo tree
if [ ${myMv} -ne 0 ] ; then
	echo -e "\nCreate repository tree(${myRoot}/.old/yum_${parmDym}) ..."
	cd "${myRoot}/yum/"
	for d in [A-Za-z]* ; do
		find "${d}/" -xdev -type d -name repodata -prune -o -type d -exec mkdir -p './.old/yum-last/{}' \;
	done
	cd ${myCwd}
fi

###	Step 0b:  Hard link all RPMs into old repo tree
if [ ${myMv} -ne 0 ] ; then
	echo -e "\nHard link all RPM files from PROD to old repo tree(${myRoot}/.old/yum_${parmDym}) ..."
	cd "${myRoot}/yum/"
	for d in [A-Za-z]* ; do
		find "${d}/" -xdev -type f -name '*.rpm' -exec ln '{}' './.old/yum-last/{}' \; 2>&1 | grep -iv 'failed to create'
	done
	cd ${myCwd}
fi

###	Step 0c:  Move repodata directory into old repo tree (or remove if already exists)
if [ ${myMv} -ne 0 ] ; then
	echo -e "\nMove all repodata directories from PROD to old repo tree(${myRoot}/.old/yum_${parmDym}) ..."
	echo -e "\t(*IGNORE* any warnings 'find: No such file or directory')"
	cd "${myRoot}/yum/"
	for d in [A-Za-z]* ; do
		find "${d}/" -xdev -type d -name repodata -exec mv '{}' './.old/yum-last/{}' \;
	done
	cd ${myCwd}
else
	echo -e "\nRemove all repodata directories from PROD repo tree, as old repo tree (${myRoot}/.old/yum_${parmDym}) already exists ..."
	cd "${myRoot}/yum/"
	for d in [A-Za-z]* ; do
		find "${d}/" -xdev -type d -name repodata -exec /bin/rm -rf '{}' \; 2>&1 | grep -iv 'No such file or directory'
	done
	cd ${myCwd}
fi

###	Step 1a:  Make any new directories in PROD repo tree
echo -e "\nCreate any new directories from Staging in PROD repo tree(${myRoot}/yum/) ..."
cd "${myRoot}/yum/.staging"
for d in [A-Za-z]* ; do
	find "${d}/" -xdev -type d -name repodata -prune -o -type d -exec mkdir -p '../{}' \;
done
cd ${myCwd}

###	Step 1b:  Hard link all new RPMs into PROD repo tree
echo -e "\nHard link all new RPM files from Staging into PROD repo tree(${myRoot}/yum/) ..."
cd "${myRoot}/yum/.staging/"
for d in [A-Za-z]* ; do
	find "${d}/" -xdev -type f -name '*.rpm' -exec ln '{}' '../{}' \; 2>&1 | grep -iv 'failed to create'
done
cd ${myCwd}

###	Step 1c:  Copy repodata directories from Staging into PROD repo tree
echo -e "\nCopy all repodata directories from Staging to PROD repo tree(${myRoot}/yum/) ..."
cd "${myRoot}/yum/.staging/"
for d in [A-Za-z]* ; do
	find "${d}/" -xdev -type d -name repodata -exec cp -a '{}' '../{}' \;
done
cd ${myCwd}

echo ""

# Change directory to when script was executed
cd ${myCwd}

