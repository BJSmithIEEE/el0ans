# Role:  repo_server - Tree Layout

A basic overview of the *'end-server'* filesytem layout, and not the Ansible playbook *'files/'* layout.

## Overview - Tree Layout

The following table provides a summary of the two (2), primary trees on any main *'Repository Server.'*

| Directory            | Purpose              | Example Subdirectories | Notes |
|:-------------------- |:--------------------:|:--------------------:|:----------------------------------------- |
| `/storage/opt/`      | Scripts and support  | `bin/`               | SELinux file context is set equivalent to TLD `/opt/` |
| `/storage/softdist/` | RPMs, Metadata, Logs | `iso/` `tar/` `yum/` | see following, additional table for a breakdown of `/storage/softdist/` |

The following table details the make-up of the *'software distribution'* tree (under `/storage/softdist/`).

| Softdist Subdirectory | Purpose              | Example Subdirectories | Notes |
|:-------------------- |:--------------------:|:--------------------:|:----------------------------------------- |
| `tar/`                 | Tarballs for copying | `rpms_YYYY-mm-dd_newfiles/` `rpms_YYYY-mm-dd_repodata/` |  Archives of only new Repository RPM files and updated Metadata, usually organized by directory name of patching date |
| `yum/`                 | Production and Staging Info, Logs and Repositories | `.log/` `.repodiffs/` `.staging/` `_rpm-gpg/` *repotree*`/` | see following, additional table for a breakdown |

The following table details the make-up of the *'YUM Subdirectories'* (under `/storage/softdist/yum/`), in addition to the *'repository trees' (the later of which are covered in the next table).

| YUM Subdirectory     | Purpose              | Notes     |
|:-------------------- |:--------------------:|:---------------------------------------------------- |
| `[.staging/].log/`   | Script Output Logs   | Most logs write to `.staging/.log/`, but some write to `.log/` (Production)
| `.mkisofs/`          | Symlinks used for ISO files | These are used as part of *optional* **step 6** (`step6_mkiso-yumrhel.sh`) -- see [Operations](./README_ops.sh`) |
| `.old/`              | Hard links (RPMs) or copies (repodata) to prior months | These are generated as part of **step X** (`stepX_linkStaging2Prod.sh`) which preserves the prior Production state -- see [Operations](./README_ops.sh`) |
| `.repodiffs/`        | History of repository differences (very extensive) | These are generated as part of *step 4* (`step4_diffStaging2Prod.sh`, or alternative `step4alt_diffStagingVolder.sh`) to only do differences from the prior month (or several prior months) -- see [Operations](./README_ops.sh`)  |
| `_rpm-gpg/`          | RPM Repository GPG Keys | Since the *'Repository Server'* is pulling all RPMs from various versions, it should actually storage and even import all keys (for past and future releases too) |
| `.staging/.validation/` | RPM Digest/Signature Validation | These are generated as part of *step 2* (`step2_chkStaging.sh`) -- see [Operations](./README_ops.sh`)
| `[.staging/]`*repotree*`/` | Actual Software Repositories | These are the actual, *'standalone,'* fill DNF/YUM-RPM Repository Trees, see the following, next section.


## Repositories

The following table details the primary, top-level DNF/YUM-Repository Trees (under `/storage/softdist/yum/`), even if there may be more than one repository per Tree.

| YUM *repotree* | Purpose (1 or 2+)           | Example, Actual DNF/YUM-Repository Tree Locations
| --------------:|:---------------------------:|:----------------------------------------------------------
| `CUDA`#`/`     | nVidia Drivers/CUDA (1)     | `[.staging/]CUDA8/x86_64/` |
| `EPEL`#`/`     | Fedora EPEL (2+)            | `[.staging/]EPEL8/8/Everything/` `[.staging/]EPEL8/next/8/Everyth8ing/` |
| `RedHat`#`/`   | RHEL Channels (2+)          | `[.staging/]RedHat8/x86_64/codeready-builder-for-rhel8-x86_64_rpm/` `[.staging/]RedHat8/x86_64/rhel-8-for-x86_64-appstream-rpms/` `[.staging/]RedHat8/x86_64/rhel-8-for-x86_64-baseos-rpms/` `[.staging/]RedHat8/x86_64/rhel-8-for-x86_64-supplementary-rpms/` |
| `TPS`#`/`    | Third Party Software (2+)   | [.staging/]TPS8/x86_64/gitlab_gitlab-ce/` `[.staging/]TPS8/x86_64/gitlab_gitlab-ee/` `[.staging/]TPS8/x86_64/microsoft_msedge/` `[.staging/]TPS8/x86_64/microsoft_powershell/` `[.staging/]TPS8/x86_64/microsoft_vscode/`



## Tarballs

The main output, by date, just repo differences (new RPMs) and an updated metadata set.

`/storage/softdist/tar`

*to be completed in more detail*