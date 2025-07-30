#/bin/bash

# For now, this only outputs the enabled nVidia driver module to STDOUT

/usr/bin/dnf module list nvidia-driver 2>> /dev/null | /usr/bin/sed -n 's,^nvidia-driver[ \t]\+\([0-9]\+-dkms\)[ \t]\+\[e\][ \t]\+.*$,\1,gp' 2>> /dev/null

