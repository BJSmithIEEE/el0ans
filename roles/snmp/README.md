# Ansible Role SNMP

The SNMP (Simple Network Management Protocol) role in the repository [el0ans](https://github.com/BJSmithIEEE/el0ans/) provides an Ansible automation solution to configure RHEL provided `net-snmp` SNMPv3 read-only on target machines.  This role is part of a collection of Ansible playbooks and roles designed for managing post-installation configurations on Enterprise Linux (EL) systems.

## Overview of the SNMP Role:

- **Purpose**: Automates the installation and configuration of SNMP, enabling remote monitoring and management of network devices and systems.
- **Features**:
  - Handles installation of necessary SNMP packages.
  - Meets STIG compliant configuration -- e.g., Disables SNMP v1 and v2c, and only enables SNMP v3 read-only
  - Uses FIPS compliant ciphers and hashes -- e.g., AES256, SHA-512 on RHEL8+, although only AES128 and SHA-1 (aka 192-bit) are supported on RHEL6/7
  - Configurable MIB access and uses TCP Wrappers to limit access
   
