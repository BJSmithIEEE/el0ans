# ELMedia0 Ansible Post-install

Ansible and Ansible Core playbooks and roles for Enterprise Linux (EL) Media [Builder] Naught (0) post-installation (including in the Kickstart `%post`).


## Ansible Roles

The following table lists Ansible roles provided in this repository.

| role | calling playbook(s) | purpose | notes |
| --------:|:--------------:|:------------------------------------ |:--------------------------------- |
| [snmp](./roles/snmp/) | *none* (i.e., use [single-role](./single-role.yaml)) | install and configure `net-snmp` for SNMPv3 read-only (**no** SNMP1/2c) to a DISA STIG compliant configuration | RHEL8+ (net-snmp 5.8+) will utilized AES256/SHA-512 for RHEL8+ (RHEL6/7 only does AES128/SHA1 aka SHA-192) |

> **IMPORTANT:**  By default, the roles assume `become=false`, and use the `become: true` in individual or blocks of tasks where privilege escalation is required.  See [Ansible Configuration Example](#ansible-configuration-example) for more information.

> **TIP:**  To override the defaults (e.g., `./roles/`*XXX*`/defaults/main.yaml`) in roles maintain in this repository, create a variables file (e.g., `./roles/`*XXX*`/vars/main.yaml`).


## Ansible Playbooks

The following Ansible playbooks are pre-included, and are detailed in the following table.

| playbook | roles | purpose |
| --------:|:-------------------:|:------------------------------------ |
| [single-role](./single-role.yaml) | *any* (passed w/`--extra-var role=`*XXX*) | Run a single Ansbile role passed along as an extra variable -- e.g., `--extra-vars 'role=`*role*`'` |

> **WARNING:**  It is strongly recommended to only use `myCommit=true` when `--limit` is used, naming specific systems, when the inventory has production systems using the variable `myProd=true`.  See section [Ansible Inventory Variables](#ansible-inventory-variables)


### Play Single Role

Run a specific, single role on a system.  An example of this command is as follows.

``` console
ansible-playbook single-role.yaml --extra-vars "role=XXX [myCommmit=True]" --limit YYY [-k [-K]] [-u admin] [-v[v..]]  
```

## Ansible Inventory Variables

No default Ansible Inventory (`inventory`) file is provided.  However, the following variables are used as conditionals in various Ansible roles, if defined in the inventory file.

| variable | default | notes |
| --------:|:---------:| ------------------------------------ |
| `myGpu`  | *undefined* or `nvidia` | will not trigger GPU-specific tasks unless set |
| `myProd` | *undefined* or `true`   | roles will not modify system or complete blocks of tasks if `myProd=true` unless `myCommit=true` is passed on command line |
| `myRole` | *varies* | This is the role of the system (`myRole=yum`), and should not be confused **not** the Ansible role(s) (`role=...`) |

This is in addition to the built-in defaults/variables, such as the `ansible_ssh_user` that may also be defined by default or passed (see [Ansible Configuration Example](#ansible-configuration-example)).


## Ansible Configuration Example

An example Ansible configuration file ([ansible.cfg](./ansible.cfg_example)) has been provided.  Please provide your own, or copy this and modify for your environment, as the default filename (typically `ansible.cfg`).

| variable          | default | notes |
| -----------------:|:----------:|:---------------------------------------------------------------------------------------------------- |
| `ask_become_pass` | *varies* | Built-in `sudo` defaults to `true`, but CentrifyDC `dzdo` defaults to `false`, tailor to fit your environment, or pass the parameter (`-K`) on the command line |
| `ask_pass`        | *varies* | Built-in `sudo` defaults to `true`, tailor to fit your environment, or pass the parameter (`-k`) on the command line |
| `become`          | `false` | block or individual tasks should have any required `become:` to raise privilege for those tasks |
| `become_method`   | *none*  | Both built-in `sudo` and CentifyDC `dzdo` examples have been provided |
| `become_user`     | Specifies the user to become when using privilege escalation, typically `root` |
| `gather_timeout`  | `120` | Again, this has been increased from the default (usually `30` to `60`) to deal with very busy systems, like those under high load |
| `host_key_checking` | `true` | Disable at your own risk, it is strongly recommended you maintain a valid `~/.ssh/known_hosts` list on your Ansible controller node |
| `timeout`         | `60` | This has been increased from the default (usually `12`) to deal with very busy systems, like those under high load |
| `user`            | `ansadmin` | The [ELMedia0 Builder](https://github.com/BJSmithIEEE/elmedia0/) creates this user by default, with a sudoer configuration to allow access, but tailor to fit your deployed environment post-install, as the `ansadmin` user will expire and lock after installation (60 days by default) |

Again, although a default `user` (`ansadmin`) is defined, and created during installation by the [ELMedia0 Builder](https://github.com/BJSmithIEEE/elmedia0/), it will expire and lock after installation (60 days by default).  It is recommended you choose one of the following strategies in your environment, especially if and when using centralized authentication and dedicated accounts for change configuration management.
- Set the `ansible_ssh_user` for each system in the [Inventory](#ansible-inventory-and-variables) file as appropriate
- Pass the parameter (`-u`) on the command line


