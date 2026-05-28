# Ansible role(nvidia)

The Ansible role(nvidia) automates installation and upgrades of NVIDIA Drivers and CUDA support on RHEL 7+.  It can even 'pin' specific Legacy Long Term Support (LTS) or other driver support on RHEL8/9.

> **TIP:**  For RHEL8/9, this role is build to default to, and pin (using `dnf module`) the installation, to the latest Data Center certified Long Term Support (LTS) driver, currently R580 (CUDA 13.0).

> **WARNING:**  Under RHEL7, using YUM, it only supports installing the latest, which was the R550 driver (with CUDA 12.4).


## NVIDIA Decoder Ring

Only Turing and later are supported in the new 600 driver series.  This matches the requirements of the `open` driver in the prior 500 series.

### Unofficial Quick Reference

The following Table breaks down GPU-Hardware against Legacy and Latest Drivers (and CUDA releases)

| **GPU** | **Codename** | **Example Product Series** | **Legacy R390 DC-LTS (CUDA 10.2)** | **Legacy R470 DC-LTS (CUDA 11.4)** | **Legacy R580 DC-LTS (CUDA 13.0)** | **Latest R610 (CUDA 13.3)** |
| ---:|:-------- |:----------------------:|:--------:|:--------:|:--------:|:--------:|
| GFxxx | **Fermi** | GTX5xx, NVS3xx(some) | **min: Fermi** | -  | -  | -  |
| GKxxx | **Kepler** | GTX6xx/7xx, Kx0xx/x1xx | supported | **min: Keper** | - | - |
| GMxxx | **Maxwell** | GTX9xx, Kx2xx, Mx0xx, NVS5xx | supported | supported | **min: Maxwell** | - |
| GPxxx | **Pascal** | GTX10x0, Px0xx/x2xx | **max: Pascal** | supported | supported | - |
| TUxxx | **Turing** | GTX16x0, RTX20xx RTXx000 | - | supported | supported | **min: Turing** |
| GAxxx | **Ampere** | RTX30xx, RTXAx000 | - | **max: Ampere** | supported | supported | 
| ADxxx | **Ada** | RTX40xx, RTXx500-Ada | - | - | supported | supported | 
| GBxxx | **Blackwell** | RTX50xx, RTXPro-x000 | - | - | supported | supported | 

> TIP:  The 600 series hardware requirements matches the 500 series `open` driver requirements.  E.g., even though the 500 series supported Maxwell and Pascall, the 500 `open` driver requires Turing like the 600 series.

### Data Center Certified

The following Table breaks down the Data Center certified Long Term Support (DC-LTS) drivers, including Legacy.

| **Driver** | **End of Life (EoL) [LTS?]** | **CUDA Version (at release)** | **RHEL Release Support** | **Data Center certified?** | **Extended Notes** |
| ---:|:------ |:------:|:------:|:--:|:-----------------------------------------:|
| **R390** | ~~2022 Dec~~ **[LTS]** | 9-10 (**9.1**) | **7** | **Yes** | only thru **RHEL7**, final DC-LTS for **Fermi**, supports thru Pascal |
| R396 | ~~2019 Mar~~ | 9-10 (9.2) | 7 8 | - | final 32-bit x86, 300 series and Fermi driver support |
| **R470** | ~~2024 Sep~~ **[LTS]** | 11.x (**11.4**) | **7 8** | **Yes** | only thru **RHEL8**, last DC-LTS for **Kepler**, supports thru **Ampere** |
| R495 | ~~2023 Jun~~ | 11.x (11.5) | **7 8** | - | final 400 series and Kepler driver support |
| **R535** | 2026 Jun **[LTS]** | 12.x (**12.2**) | **7 8 9** | **Yes** | min **Maxwell**, min **Turing** for `open` driver |
| R550 | ~~2025 Apr~~ | 12.x (12.4) | 7 8 9 | Yes | final **RHEL7** driver, first `open` driver to be fully functional |
| **R580** | **2028 Jun** **[LTS]** | 13.x (**13.0**) | **8 9 10** | **Yes** | first **RHEL10** driver, final DC-LTS for **Maxwell/Pascal**
| R595 | 2027 Mar | 13.x (13.2) | 8 9 10 | Yes | final 500 driver, final 500 series and Maxwell/Pascall driver support
| R610 | 2027 Jun | 13.x (13.3) | 8 9 10 | - | min **Turing**, solely `open` driver

> **TIP:**  This is a highly modified and augmented table from the official NVIDIA Data Center Documentation maintained here:  https://docs.nvidia.com/datacenter/tesla/drivers/latest/supported-drivers-and-cuda-toolkit-versions.html

### RHEL v. Hardware Support

The following Table breaks down the RHEL releases and their NVIDIA GPU hardware support as well as the DC-LTS (and version range) support.

| **GPU/Driver** | **RHEL7** | **RHEL8** | **RHEL9** | **RHEL10** |
| ----------------:|:------------------------:|:------------------------:|:------------------------:|:------------------------:| 
| **Codename Support** | Fermi to Ada | Kepler to Blackwell | Maxwell to Blackwell | Maxwell to Blackwell |
| **Example Product(s)** | GTX5xx, NVS3xx(some) to RTX40xx, RTXx500-Ada | GTX6xx/7xx, Kx0xx/x1xx to RTX50xx, RTXPro-x000 | GTX6xx/7xx, Kx0xx/x1xx to RTX50xx, RTXProx000 | GTX6xx/7xx, Kx0xx/x1xx to RTX50xx, RTXProx000 |
| **Legacy 300 series** | R390 DC-LTS (R346-396) | - | - | 
| **Legacy 400 series** | R470 DC-TLS (all, R410-495) | R470 DC-LTS (all, R410-495) | - | - |
| **Legacy 500 series** | R535 DC-LTS (R510-550) | R580 DC-LTS (R515-595) | R580 DC-LTS (R580-595, Wayland-only) | - |
| **Latest 600 series** | - | R610+ | R610+ | R610+ (Wayland-only) |

> TIP:  The 600 series hardware requirements matches the 500 series `open` driver requirements.  E.g., even though the 500 series supported Maxwell and Pascall, the 500 `open` driver requires Turing like the 600 series.

## Using role(nvidia)

*to be written*


## Finding Exact Hardware

The Appendix of each driver README has a list of Support Hardware.

### Latest and Legacy R580, R470 and R390 Hardware Support

Here is the README Appendix from R610 (610.43.02 shown).  It includes the direct HTML anchor links to the Legacy R580, R470 and R390 Data Center certified and Long Term Support (DC-LTS) hardware support lists.

 * Latest R610:  https://us.download.nvidia.com/XFree86/Linux-x86_64/610.43.02/README/supportedchips.html
 * Legacy R580 DC-LTS:  https://us.download.nvidia.com/XFree86/Linux-x86_64/610.43.02/README/supportedchips.html#legacy_580.xx
 * Legacy R470 DC-LTS:  https://us.download.nvidia.com/XFree86/Linux-x86_64/610.43.02/README/supportedchips.html#legacy_470.xx
 * Legacy R390 DC-LTS:  https://us.download.nvidia.com/XFree86/Linux-x86_64/610.43.02/README/supportedchips.html#legacy_390.xx
 
### GPU Product by PCI ID
 
The list PCI devices command (`lspci`) can identify the VGA controller.
``` console
$ lspci | grep -i 'vga.*nvidia'

05:00.0 VGA compatible controller: NVIDIA Corporation GK107GL [Quadro K2000] (rev a1)
```

Using the PCI bus:target reference, we can identify the PCI ID using the numeric (-n) and verbosity (-v) options.
``` console
$ lspci -nv | grep -i '05:00:00.*vga'

05:00.0 0300: 10de:0ffe (rev a1) (prog-if 00 [VGA controller])
```

This NVIDIA Quadro K2000 has a PCI ID of 10de (NVIDIA) and 0ffe (submodel).

> **IMPORTANT**:  A model may have multiple PCI IDs and may have different driver support.  Get the exact submodel in the PCI ID.
