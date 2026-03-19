#######	FUNCTIONS

#####	ojHome()
#####	export JAVA_HOME for the JRE and/or SDK of an installed OpenJDK version
#####	parameters:
#####	    $1  =  Java Version -- e.g., 1.8.0, 11, 17 & 21 for RHEL (OpenJDK LTS releases)
ojHome() {
	# Get version
	local jVer="${1}"
	# Check version was passed
	[ "${jVer}" == "" ] && echo -e "\n[SYNTAX] OpenJDK version must be passed\n" 2>> /dev/stderr && return
	# Check version is numeric (with optional periods for 8 aka 1.8.0 and earlier)
	local jVal="$(echo ${jVer} | /bin/sed -n 's/^\([0-9][0-9.]*\)$/\1/p' 2>> /dev/null)"
	[ "${jVal}" == "" ] && echo -e "\n[SYNTAX] OpenJDK version passed(${jVer}) is NOT numeric\n" 2>> /dev/stderr && return
	# Check if OpenJDK RPM for version is installed
	/bin/rpm -q java-${jVer}-openjdk 2>&1 >> /dev/null
	[ $? -ne 0 ] && echo -e "\n[SYSTEM] OpenJDK version passed(${jVer}) does not exist in the RPM database\n" 2>> /dev/stderr && return
	# Check default JPackage directory path (under /usr/lib/jvm/) exists for RPM package
	local jPkg="$(/bin/rpm -q java-${jVer}-openjdk 2>> /dev/null)"
	[ ! -d "/usr/lib/jvm/${jPkg}" ] && echo -e "\n[SYSTEM] OpenJDK version passed(${jVer}) exists in RPM database(${jPkg}), but ...\n\tthe appropriate JAVA_HOME directory(/usr/lib/jvm/${jPkg}) does NOT seem to exist?\n" 2>> /dev/stderr && return
	# Success, set JAVA_HOME
	export JAVA_HOME="/usr/lib/jvm/${jPkg}"
	echo -e "\n\texport JAVA_HOME=${JAVA_HOME}\n"
}

#####	ojList()
#####	list the latest release of all installed OpenJDK versions
#####	parameters:
#####	    [-v]  =  optional verbosity -- print JAVA_HOME and all binaries for version (also verifies JPackage path exists)
ojList(){
	# Get verbosity
	local bVerb="${1}"
	# Get all OpenJDK RPM versions installed
	local jVers="$(/bin/rpm -qa | /bin/sed -n 's/^\(java-\([0-9][0-9.]*\)-openjdk-[0-9].*\)$/\t\2(\1)/p' 2>> /dev/null | /bin/sort 2>> /dev/null)"
	[ "${jVers}" == "" ] && echo -e "\n[SYSTEM] No OpenJDK RPMs installed\n" 2>> dev/stderr && return
	# Print all OpenJDK RPM versions installed
	echo -e "\n\tVersion\tJPackage %NAME-%VERSION-%RELEASE[.%disttag].%ARCH"
	echo -e "\t-------\t---------------------------------------------------"
	for v in ${jVers} ; do echo -e "\t${v}" | /bin/sed -e 's/[(]/\t/g' -e 's/[)]//g' 2>> /dev/null ; done
	if [ "${bVerb}" == '-v' ] ; then
		# Print out directory and binaries for each, installed version
		for v in ${jVers} ; do
			local jPkg="$(echo ${v} | /bin/sed -n 's/^[^(]*[(]\([^)]\+\)[)].*$/\1/p' 2>> /dev/null)"
			echo -e "\n${v}"
			if [ ! -d "/usr/lib/jvm/${jPkg}" ] ; then
				echo -e "\tJAVA_HOME:  does NOT exist!"
			else
				echo -e "\tJAVA_HOME:  /usr/lib/jvm/${jPkg}"
				echo -e "\t binaries:"
				/bin/ls /usr/lib/jvm/${jPkg}/bin/ 2> /dev/null | /bin/sort -u 2>> /dev/null | /bin/sed -n 's/^\(.\+\)$/\t\t\1/p' 2>> /dev/null
			fi
		done
	fi
	echo -e ""
}


#######	DEFAULTS (examples for user ~/.bashrc)

### save PATH prior to prepending OpenJDK ./bin
# export PATHojPre=${PATH}

### default to OpenJDK 21
# ojHome 21
# export PATH=${JAVA_HOME}/bin:${PATHojPre}

### change later to OpenJDK 17
# ojHome 17
# export PATH=${JAVA_HOME}/bin:${PATHojPre}
