#!/bin/bash

###     Globals

# Parameters
myCwd="$(pwd)"
myNam="$(basename ${0})"
myDir="$(dirname ${0})"
myAbs="$(readlink -f ${myDir})"


# Source Common Functions/Globals
. ${myAbs}/softDist.func


###	MAIN

echo -e ""
echo -e "CWD:\t${myCwd}"
echo -e "Name:\t${myNam}"
echo -e "Dir:\t${myDir} (${myAbs})"
echo -e "Dist:\t${myRoot}"
echo -e ""
echo -e "Epoch:\t${myDs}"
echo -e "Month:\t${myDym} (${myDyb})"
echo -e "Day:\t${myDymd} (${myDybd})"
echo -e "Stamp:\t${myDsymd}"
echo -e ""
echo -e "Vend:\t${myV}"
echo -e "Prod:\t${myP}"
echo -e "Rel:\t${myR} (Rel[+Prod]: ${myR0})"
echo -e ""


