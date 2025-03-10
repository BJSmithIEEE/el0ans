#!/bin/bash
#
#	satx2tree.sh
#	Create Tree of Channels w/Hard Linked Packages from RHN Satellite Export
#
#	Must be run on the RHN Satellite Server itself
#	Requires spacecmd (pull from EPEL, but do not recommend subscribing to EPEL)
#	NOTE:  Does *NOT* run YUM createrepo (additional step left to user)
#
#	(C)2010-2012 Bryan J Smith <b.j.smith@ieee.org>
#	Licensed under GPL Version 2.  All Rights Reserved.
#
#	NOTE:  Much faster if run under BASH 4 (hashes instead of searching arrays)
#

#	Parameters
dir_satx="$1"
dir_tree="$2"

if [ "${dir_tree}" == "" ] ; then
	echo ""
	echo "Syntax(1)"
	echo "  satx2tree.sh  (dir_export)  (dir_tree)"
	echo "    where"
	echo "      (dir_export)  Source RHN Satellite Export to Read/Link from"
	echo "      (dir_tree)    Destination Tree of Channels w/Hard Linked Packages"
	echo ""
	echo "  NOTE:  Hard Links are used, so Source Export and"
	echo "         Destination Tree must be on same file system"
	echo "  PERF:  Bash4 is recommended (uses hashes instead of arrays)"
	echo ""
	exit 1
fi

#	Binary Check
bin_sats="`which satellite-sync`" ; [ ! -x "${bin_sats}" ] && echo "[satx2tree]*ERROR(127)*Cannot find or execute RHN Satellite Sync (satellite-sync) program" && exit 127
bin_scmd="`which spacecmd`" ; [ ! -x "${bin_scmd}" ] && echo "[satx2tree]*ERROR(127)*Cannot find or execute Space Command (spacecmd) script" && exit 127

#	Globals
lst_chan=""

#	Check to make sure parent directory of channel trees is empty
echo -n "[satx2tree] Output Directory(${dir_tree}) ... checking ... "
if [ -d "${dir_tree}" ] ; then
	if [ "`ls ${dir_tree}`" ] ; then
		echo ""
		echo "[satx2tree]*ERROR(124)*Directory is NOT empty"
		exit 124
	fi
fi
echo "done"
mkdir -p "${dir_tree}" 2>> /dev/null
rc=$? ; [ ${rc} -ne 0 ] && echo "[satx2tree]*ERROR(123)*Cannot create directory (mkdir rc=${rc})" && exit 123

#	Get full list of channels from export
echo -n "[satx2tree] Input Directory(${dir_satx}) ... reading channels ... "
if [ -d "${dir_satx}" ] ; then
	lst_chan="`${bin_sats} -m ${dir_satx} -l 2>> /dev/null | sed -n 's/^[0-9][^ \t]\+[ \t]\+[^ \t]\+[ \t]\+\([^ \t]\+\)[ \t]\+[0-9]\+.*$/\1/p' 2>> /dev/null | sort`"
fi
if [ "${lst_chan}" == "" ] ; then
	echo ""
	echo "[satx2tree]*ERROR(120)*Directory is not a RHN Satellite Export"
	exit 120
fi
echo -n "found("
x=0 ; for c in ${lst_chan} ; do let x=x+1 ; done ; echo "${x})"

#	Get full list of packages from RHN Satellite Server
declare -a arr_chan=()
declare -a arr_cpkg=()
let i=0
echo "[satx2tree] RHN Satellite Server(localhost) ... accessing channels ... "
echo -n "[satx2tree]   "
${bin_scmd} -s localhost login
rc=$? ; [ ${rc} -ne 0 ] && echo "[satx2tree]*ERROR(118)*Cannot access local RHN Satellite Server (spacecmd rc=${rc})" && exit 118
for c in ${lst_chan} ; do
	echo "[satx2tree]   Channel(${c}) ... getting packages list ... "
	echo -n "[satx2tree]     "
	arr_chan[${i}]="${c}"
	# NOTE: Filter out any trailing colon-number (:#)
	arr_cpkg[${i}]="`${bin_scmd} -s localhost softwarechannel_listallpackages ${c} | sed -e 's/:[0-9]\+//g' 2>> /dev/null`"
	let x=0 ; for p in ${arr_cpkg[${i}]} ; do let x=x+1 ; done ; echo "[satx2tree]     found(${x})"
	let i=i+1
done

cnum=${#arr_chan[*]}
#	Print out list of packages in each channel
let cidx=0
while [ ${cidx} -lt ${cnum} ] ; do
	for p in ${arr_cpkg[${cidx}]} ; do
		echo "${p}" >> "${dir_tree}/${arr_chan[${cidx}]}.lst"
	done
	let cidx=cidx+1
done

#	Get full list of packages from export
if [ ${BASH_VERSINFO[0]} -ge 4 ] ; then
	#	Use hashes
	declare -A hash_pkg
else
	#	Search arrays
	declare -a arr_path=()
	declare -a arr_ppkg=()
fi
let i=0
echo "[satx2tree] Input Directory(${dir_satx}) ... reading packages ..."
echo -n "[satx2tree]   Packages ."
for f in `find ${dir_satx} -mount -name '*.rpm' 2>> /dev/null` ; do
	n="`rpm -qp ${f} 2>> /dev/null`"
	if [ ${BASH_VERSINFO[0]} -ge 4 ] ; then
		#	Use hashes
		hash_pkg[${n}]="${f}"
	else
		#	Search arrays
		arr_path[${i}]="${f}"
		arr_ppkg[${i}]="${n}"
	fi
	let i=i+1
	let m=i%100 ; [ ${m} -eq 0 ] && echo -n ". ${i} ."
done
echo ". found(${i})"

#	Hard link packages into YUM directories
echo "[satx2tree] Output Directory(${dir_tree}) ... linking packages ..."
#	For each channel
let cidx=0
cnum=${#arr_chan[*]}

while [ ${cidx} -lt ${cnum} ] ; do
	echo -n "[satx2tree]   Repo(${arr_chan[${cidx}]}) "
	mkdir -p "${dir_tree}/${arr_chan[${cidx}]}" 2>> /dev/null
	rc=$? ; [ ${rc} -ne 0 ] && echo "[satx2tree]*ERROR(123)*Cannot create directory (mkdir rc=${rc})" && exit 123

	#	For each package in channel
	let pidx=0
	let pfnd=0
	for p in ${arr_cpkg[${cidx}]} ; do
		#	Look for package in export
		if [ ${BASH_VERSINFO[0]} -ge 4 ] ; then
			#	Use hashes (much faster)
			if [ ! -z "${hash_pkg[${p}]}" ] ; then
				#	Package found, create hard link
				echo -n "."
				let pfnd=pfnd+1
				ln ${hash_pkg[${p}]} "${dir_tree}/${arr_chan[${cidx}]}/${p}.rpm" 2>> /dev/null
			else
				echo -n "x"
			fi
		else
			#	Search arrays (much slower)
			let fidx=0
			fnum=${#arr_ppkg[*]}
			#	Locate package by looping through export packages
			for f in ${arr_ppkg[*]} ; do
				[ "${p}" == "${f}" ] && break
				let fidx=fidx+1
			done
			if [ ${fidx} -lt ${fnum} ] ; then
				#	Package found, create hard link
				echo -n "."
				let pfnd=pfnd+1
				ln "${arr_path[${fidx}]}" "${dir_tree}/${arr_chan[${cidx}]}/${p}.rpm" 2>> /dev/null
			else
				echo -n "x"
			fi			
		fi
		let pidx=pidx+1
	done
	echo " linked(${pfnd} of ${pidx})"
	let cidx=cidx+1
done

echo "[satx2tree] Completed"
echo "[satx2tree]   RHN Satellite Server Export Directory(${dir_satx})"
echo "[satx2tree]   Hard Linked Channel Packages Directory(${dir_tree})"
echo ""
echo "[satx2tree]*REMEMBER*"
echo "[satx2tree]   *NO* YUM Repositories have been created (e.g., use 'createrepo')"
echo "[satx2tree]   *PRESERVE* hard links when copying (e.g., rsync '-H' option)"
echo "[satx2tree]     (otherwise disk usage may be exponentially increased)"

