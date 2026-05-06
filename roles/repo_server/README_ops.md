# Role:  repo_server - Operations

A basic overview of the *'Period Operations'* that are largely executed via scripts.

## Overview - Scripts

The following table provides a *'step-by-step summary'* of all scripts or related *'operations.'*

> **NOTE:**  All relative paths are rooted at the base YUM Tree (`/storage/softdist/yum/`), unless listed as absolute paths (then those are the absolute paths).

| Step | Script(s) | Purpose        | Modified Dir(s)/File(s) (and Log(s))  | Notes |
| -:|:--------- | ----------------- |:------------------------------- |:------------------------------------
| 0 | *n/a*     | Manually update select info | `/storage/opt/bin/softdist.func` | One of the few, *'manual'* operations, the *'functions'* file (this should be moved to a new `/storage/opt/etc/` file) may need some variables modified.  E.g,. the new GitLab releases to download.
| 1 | `step1_getCUDA.sh` | Update nVidia Drivers/CUDA | `.staging/CUDA`#`/` (`.staging/.log/staging_reposync-CUDA`#`_*.log`) | DNF Reposync single repository
| " | `step1_getEPEL.sh` | Update Fedora EPEL | `.staging/EPEL`#`/` (`.staging/.log/rsync-EPEL`#`_*.log`) | Rsync multiple EPEL repositories (usually release *#* and `Next` for Stream) |
| " | `step1_getRedHat.sh` | Update RHEL | `.staging/RedHat`#`/` (`.staging/.log/staging_reposync-RedHat`#`.log`) | DNF Reposync all RHEL channels for release |
| " | `step1_getRPMFusion.sh` | Update RPMFusion (Free-only) | `.staging/RPMFusion`#`/` (`.staging/.log/rsync-RPMFusion`#`_*.log`) | Rsync just the 'Free' repository from RPMFusion |
| " | `step1_getTPS.sh` | Update Third Party Software (TPS) | `.staging/TPS`#`/` (`.staging/.log/staging_reposync-TPS`#`_*.log`) | DNF Reposync all TPS vendors and their channels |
| 2 | `step2_chkStaging.sh` | Validate RPM Digest/Signatures | `.staging/.validation/sig_`YYYY`-`mm`/`rpm-checkgpg_`repotree#`-*.txt` (`.staging/.log/staging_validation-`#`_*.log`) | Fully check all RPMs, existing and new, for bitrot and incomplete downloads, and list any not validated
| 3 | `step3_updRepodata.sh` | Update select Repo meta-data | (`.staging_updatemd-`#`_*.log`) | Generate any repositories not created with DNF Reposync or downloaded via rsync (e.g., GitLab, select others) |
| 4 | `step4_diffStaging2Prod.sh` | Difference Staging v. Prior Month (Production) | 
| 4(alt) | `step4alt_DiffStagingVolder.sh` | Difference Staging v. a much older Staging (many months ago) | 
| 5 | `step5_tarNewfiles.sh` | Create tarballs of just new RPMs from differences (generated in step 4) | 
| " | `step5_tarRepodata.sh` | Create tarballs of updated YUM repodata for all repositories | 
| X | `stepX_linkStaging2Prod.sh` | Hardlink old/new RPMs, copy old/new Metadata |  | Existing production RPMs are hardlinked and metadata copied under `.old/`, while new `.staging/` (Staging) RPMs are hardlinked and updated metadata copied as `./` (Production). |
`


## Step 0 - Manual Housekeeping

Step 0 is a *'manual housekeeping'* step.  Nearly all repository files and scripts provide all that is needed, or will output information that will allow one to execute without manul tasks.  One of the rare exceptions is the GitLab repository.

Because GitLab releases are >>1GiB per RPM package now, and GitLab releases (both CE and EE) are more than once a week, every year 1TiB+ of files are generated.  As such, we manually specify the new releases to download, as we cannot feasibly mirror the entire GitLab repository.

> **IMPORTANT:**  Trying to use YUM repo `excludes=` or `includes=` with GitLab would still download too many unnecessary, minor revisions, and have extensive bloat.

E.g., the following GitLab releases were inserted into the `softDist.func` (`/storage/opt/bin/softDist.func`) file in 2024 June.  You will want to append the list of releases just above the noted line (`^ ^ ^  M O D I F Y  H E R E  ^ ^ ^`).

``` shell
  ...
#       softDist.func - Software Distibution Globals and Functions

#####   GLOBALS

### CONSTANTS

# Minimum EL still being downloaded
#minEl=7
minEl=8

... 

### PACKAGE VERSION-SPECIFIC

# GitLab Releases
# 2023 # vGitLab="15.11.13"
# 2023 # vGitLab="16.0.8 16.1.5 16.2.8 16.3.6 16.4.4 16.5.4 16.6.2"
# 2024-Jan # vGitLab="16.5.7 16.6.5 16.7.3"
# 2024-Feb # vGitLab="16.5.8 16.6.7 16.7.5 16.8.2"
# 2024-Mar # vGitLab="16.7.7 16.8.4 16.9.2"
# 2024-Apr # vGitLab="16.8.5 16.9.3"
vGitLab="16.8.7 16.9.8 16.10.6 16.11.3"
    ... 

#
# ^ ^ ^   M O D I F Y  H E R E   ^ ^ ^
#


### FULL CHANNELS
  ... 
```

## Step 1 - DNF Reposync

There are multiple *'Step 1'* scripts (`step1_*.sh`) for downloading software.  They can be run in any order, or even more than once.  But more than one should not be executed at a time.

> **TIP:**  Think of the *'Step 1'* scripts as like running `dnf` directly.  You don't want more than one execution of the `dnf` command.  Although just like `dnf` commands, they can be run more than once, after all other `dnf` commands complete, on the same repositories with no harm.

For RHEL8+ (DNF), the `dnf reposync` command-parameter is used in all scripts, along with the exact repos to enable.  All GPG keys must be imported for channels.  And because some channels are not using FIPS-compliant Digests and/or Signatures, **FIPS mode** must be **disabled** on the *'Repository Server.'*

> **WARNING:**  Failure to install all GPG keys for any and all repos and/or accidentally running in FIPS mode may result in the **deletion** of RPMs.  Although this is what the old repository archive (`/storage/softdist/yum/.old/`) exists for, as it maintains hard links to older packages.

> **IMPORTANT:**  It is important to let the ***'Step 1'*** scripts use `dnf reposync`, as RHEL8+ not only includes *'groups'* (`comps.xml`), but now *'modules'* that cannot be *'re-generated'* on-system (e.g., w/`createrepo`).

Revisiting the prior table for *'Step 1'* ... 

| Step | Script(s) | Purpose        | Modified Dir(s)/File(s) (and Log(s))  | Notes |
| -:|:--------- | ----------------- |:------------------------------- |:------------------------------------
| 1 | `step1_getCUDA.sh` | Update nVidia Drivers/CUDA | `.staging/CUDA`#`/` (`.staging/.log/staging_reposync-CUDA`#`_*.log`) | DNF Reposync single repository
| " | `step1_getEPEL.sh` | Update Fedora EPEL | `.staging/EPEL`#`/` (`.staging/.log/rsync-EPEL`#`_*.log`) | Rsync multiple EPEL repositories (usually release *#* and `Next` for Stream) |
| " | `step1_getRedHat.sh` | Update RHEL | `.staging/RedHat`#`/` (`.staging/.log/staging_reposync-RedHat`#`.log`) | DNF Reposync all RHEL channels for release |
| " | `step1_getTPS.sh` | Update Third Party Software (TPS) | `.staging/TPS`#`/` (`.staging/.log/staging_reposync-TPS`#`_*.log`) | DNF Reposync all TPS vendors and their channels |

``` console
[sysadmin@softdist ~]$ /storage/opt/bin/step1_getRedHat.sh

step1_getRedHat.sh  [1]

where 1 commits to updating the following Staging RHEL repositories from the Internet ...
        ansible-2.9-for-rhel-8-x86_64-rpms codeready-builder-for-rhel-8-x86_64-rpms rhel-8-for-x86_64-appstream-rpms rhel-8-for-x86_64-baseos-rpms rhel-8-for-x86_64-supplementary-rpms


[sysadmin@softdist yumY]$ /storage/opt/bin/step1_getRedHat.sh 1

  ...

[sysadmin@softdist ~]$ /storage/opt/bin/step1_getEPEL.sh

step1_getEPEL.sh  [8]

where 8 commits to updating the following Staging EPEL repositories from the Internet ...
        EPEL8 EPEL8-modular EPEL8-next


[sysadmin@softdist ~]$ /storage/opt/bin/step1_getEPEL.sh 8

  ... 

[sysadmin@softdist ~]$ /storage/opt/bin/step1_getCUDA.sh

step1_getCUDA.sh  [1]

where 1 commits to updating the following Staging nVidia CUDA repositories from the Internet ...
        cuda_cuda


[sysadmin@softdist ~]$ /storage/opt/bin/step1_getCUDA.sh 1

  ... 

[sysadmin@softdist ~]$ /storage/opt/bin/step1_getTPS.sh

step1_getTPS.sh  [1]

where 1 commits to updating the following Staging Third Party Software (TPS) repositories from the Internet ...
        docker_docker-ce microsoft_msedge microsoft_powershell microsoft_vscode pgdg_pgdg-common pgdg_pgdg10 pgdg_pgdg11 pgdg_pgdg12 pgdg_pgdg13 pgdg_pgdg14 pgdg_pgdg15 pgdg_pgdg16 wazuh_wazuh-4 gitlab_gitlab-ce gitlab_gitlab-ee


[sysadmin@softdist ~]$ /storage/opt/bin/step1_getTPS.sh 1

  ... 

```

The CUDA and RedHat scripts take a long duration (1+ hours) to complete.  It is recommended you run these in a `nohup` or `tmux` session.  The log files will be output into the standard logging location for staging (`/storage/softdist/yum/.staging/.log/) as detailed in the prior table (e.g., `staging_reposync-*.log or `rsync-*.log`).  One log will be generated per command, so if all four (4) *'Step 1'* commands are executed, there should be four (4) log files.

> **NOTE:**  The *'Step 1'* scripts do still handle RHEL7 with legacy YUM `reposync` (separate command).  However, due to issues with its checking and generation, repositories are not automatically created.  They are manually generated for RHEL7 channels in Step 3.


## Step 2 - Validate Staging

Once all *'Step 1'* DNF Reposync and rsync operations have completed, all existing and new RPM packages should be checked for both valid file digest (integrity) as well as signature (non-repudiation, if signed).  Like Step 1, this step may be repeated as well, although it can take hours to verify all packages.

> **WARNING:**  Failure to install all GPG keys for any and all repos and/or accidentally running in FIPS mode may result in *'false positive'* findings for digests and/or signatures.  Although it will not delete any packages in *'Step 2,'* **unlike** `dnf reposync` *'Step 1.'*

Revisiting the prior table for *'Step 1'* ... 

| Step | Script(s) | Purpose        | Modified Dir(s)/File(s) (and Log(s))  | Notes |
| -:|:--------- | ----------------- |:------------------------------- |:------------------------------------
| 2 | `step2_chkStaging.sh` | Validate RPM Digest/Signatures | `.staging/.validation/sig_`YYYY`-`mm`/`rpm-checkgpg_`repotree#`-*.txt` (`.staging/.log/staging_validation-`#`_*.log`) | Fully check all RPMs, existing and new, for bitrot and incomplete downloads, and list any not validated

The script takes a *'repotree'* name as one or more (1+) parameters.  It's usually safe to call it with more than one (>1), including all.


``` console
[sysadmin@softdist ~]$ /storage/opt/bin/step2_chkStaging.sh

step2_chkStaging.sh  PREFIX  [PREFIX..]

where PREFIX is one or more (1+) of the following for your release ...

        EPEL8  RPMFusion8  RedHat8  TPS8  CUDA8


[sysadmin@softdist ~]$ /storage/opt/bin/step2_chkStaging.sh  EPEL8  RPMFusion8  RedHat8  TPS8  CUDA8

   ...

```

Validation usually takes several hours (2-6 hours) to complete.  It is recommended you execute this command in a `nohup` or `tmux` session.  The log files will be output into the standard logging location for staging (`/storage/softdist/yum/.staging/.log/) as detailed in the prior table (e.g., `staging_validation-*.log`).  One log will be generated per command.

In addition, the actual *'validation'* output is stored in another location for Staging (`.staging/.validation/sig_`YYYY`-`mm`/`rpm-checkgpg_`repotree#`-*.txt`).  This file may be *'tailed'* while running.  What one would look for as a `NOT ok` output.  E.g.,

``` console
[sysadmin@softdist ~]$ grep -i 'NOT ok' /storage/software/yum/.staging/.validation/sig_$(date +%Y-%m)/rpm-checkpgp_*.txt

```

The script attempts to catch these, and any will be both listed to STDOUT, as well as in the log file, at the very end.


## Step 3 - Update Select Repositories

| Step | Script(s) | Purpose        | Modified Dir(s)/File(s) (and Log(s))  | Notes |
| -:|:--------- | ----------------- |:------------------------------- |:------------------------------------
| 3 | `step3_updRepodata.sh` | Update select Repo meta-data | (`.staging_updatemd-`#`_*.log`) | Generate any repositories not created with DNF Reposync or downloaded via rsync (e.g., GitLab, select others) |
`

*to be completed in more detail*


## Step 4 - Difference Staging v. Prior Month(s)

| Step | Script(s) | Purpose        | Modified Dir(s)/File(s) (and Log(s))  | Notes |
| -:|:--------- | ----------------- |:------------------------------- |:------------------------------------
| 4 | `step4_diffStaging2Prod.sh` | Difference Staging v. Prior Month (Production) | 
| 4(alt) | `step4alt_DiffStagingVolder.sh` | Difference Staging v. a much older Staging (many months ago) | 
`

*to be completed in more detail*



## Step 5 - Tarball New RPMs and Updated Repodata

| Step | Script(s) | Purpose        | Modified Dir(s)/File(s) (and Log(s))  | Notes |
| -:|:--------- | ----------------- |:------------------------------- |:------------------------------------
| 5 | `step5_tarNewfiles.sh` | Create tarballs of just new RPMs from differences (generated in step 4) | 
| " | `step5_tarRepodata.sh` | Create tarballs of updated YUM repodata for all repositories | 
`

*to be completed in more detail*



## Step X - Link Staging as New Production

| Step | Script(s) | Purpose        | Modified Dir(s)/File(s) (and Log(s))  | Notes |
| -:|:--------- | ----------------- |:------------------------------- |:------------------------------------
| X | `stepX_linkStaging2Prod.sh` | Hardlink old/new RPMs, copy old/new Metadata |  | Existing production RPMs are hardlinked and metadata copied under `.old/`, while new `.staging/` (Staging) RPMs are hardlinked and updated metadata copied as `./` (Production). |
`

*to be completed in more detail*

