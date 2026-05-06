# Role:  repo_server

A basic overview of the Repository Server (deployable via Ansible in the future), with links to further information.


## Overview

The following table provides the additional `README_*.md` files with more information.

| README file | Purpose    | Notes |
| -----------:|:---------- |:------------------------------------------- |
| [Tree Layout](./README_tree.md)  | Server Filesystem Layout | This is the *'end-server'* filesystem layout, not the Ansible playbook *'files/'* layout |
| [Operations](./README_ops.md)    | Periodic Repository Operations | These are the scripts to execute on a periodic (e.g., quarterly) basis |
| [Deployment](./README_deploy.md) | Deploy to New Servers or VMs |  This is how to execute the Ansible playbook role, for updating or even deploying new systems |


## Quickstart

First off, at no point are superuser privileges required (**no** `root` used).  This entire solution runs *'unprivileged.'*  The user only needs to be part of the local *'softdist'* group (e.g., modify `/etc/group` via the command `vigr`).

> **IMPORTANT:**  It is strongly recommended to run with an umask that makes files world readable, group writable (e.g., `umask 002`).  In all scripts utilized, this is the umask set.

Secondly, dedicated *'Software Distibution'* repository files (`/etc/yum.repo.d/REPO_*.repo`) have been created, that are named specifically for this solution.  They are disabled by default, and selectively enabled by the scripts.  No other changes are necessary, other than ensuring the system is subscribed to the Red Hat software channels for the system's release of RHEL software.

Third, the solution as already been *'deployed'* to the 'low side repo' server, which may be a RHEL8 workstation.

Finally, on the `softdist` server, scripts are in `/storage/opt/bin/` and RPMs will be located under `/storage/softdist/yum/` (Production), with *'new downloads'* going into the `/storage/softdist/yum/.staging/` (Staging) area. This includes doing *'differences'* and *'cutting updated tarballs'* under Staging, against Production.  Execute the scripts under `/storage/opt/bin/` in order of *'step'* (1+), as detailed in the [Operations](./README_ops.md) documentation.  Once complete, difference tarballs will be located under `/storage/softdist/tar/` for both `newfiles` (new RPM packages) and `repodata` (updated repository metadata for all packages, existing and new, in each repository).

E.g., on `softdist` as user `sysadmin` (which may be disabled 60 days after a system build if using ELMedia0), or someone else with group `softdist` access.

``` console
sysadmin@softdist$ umask 002
sysadmin@softdist$ vim /storage/opt/bin/softDist.func         # edit any variables, such as the GitLab release list

sysadmin@softdist$ /storage/opt/bin/step1_getRedHat.sh 1
sysadmin@softdist$ /storage/opt/bin/step1_getCUDA.sh 1
sysadmin@softdist$ /storage/opt/bin/step1_getEPEL.sh 8
sysadmin@softdist$ /storage/opt/bin/step1_getRPMFusion.sh 8
sysadmin@softdist$ /storage/opt/bin/step1_getTPS.sh 1

sysadmin@softdist$ /storage/opt/bin/step2_chkStaging.sh EPEL8 RPMFusion8 RedHat8 TPS8 CUDA8

sysadmin@softdist$ /storage/opt/bin/step3_updRepodata.sh ./TPS8/x86_64/gitlab_gitlab-ce ./TPS8/x86_64/gitlab_gitlab-ee

sysadmin@softdist$ /storage/opt/bin/step4_diffStaging2Prod.sh 1

sysadmin@softdist$ /storage/opt/bin/step5_tarNewfiles.sh "$(date +%Y-%m-%d)"

sysadmin@softdist$ /storage/opt/bin/step5_tarRepodata.sh "$(date +%Y-%m-%d)"

  ... files are now under /storage/softdist/tar/ by date ... 
  
  ... (after testing) ... 
sysadmin@softdist$ stepX_linkStaging2Prod.sh YYYY-mm        # where 'mm' is last month, not the current month

``` 
