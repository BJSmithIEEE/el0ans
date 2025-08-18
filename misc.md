# Miscellaneous

Various miscellaneous information and notes.

## sssd with smbd

The 2025 July patches for Microsoft Windows Server 2008 - 2022 prevent use of the Samba AD backend (`idmap config` *DOMAIN*`: backend = ad`).
But the Samba SSS backend (`idmap config` *DOMAIN*`: backend = sss`)  continues to work for RHEL8+, but is not an option in RHEL7 or earlier.

The Samba SSS backend does NOT use the legacy SSSD winbind library (`sssd-libwbclient`) which was deprecated in 2022.
The latter was removed as an option Upstream (Samba) because SSSD isn't really an option outside GNU/Linux (maybe BSD in the future).

> IMPORTANT:  This is only required when CIFS/SMB file services (e.g., `smbd`) are in use, although it's nice to be able to use the Winbind commands (e.g., `wbinfo`) to match to LibC (e.g., `getent`).


