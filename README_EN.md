# Non-GKI Kernel with KSU and SUSFS
![GitHub branch check runs](https://img.shields.io/github/check-runs/JackA1ltman/NonGKI_Kernel_Build/main)![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/JackA1ltman/NonGKI_Kernel_Build/latest/total)  
[Supported Devices](Supported_Devices.md) | [中文文档](README.md) | English | [Updated Logs](Updated.md)  

**Ver**.1.5

**Non-GKI**: What we commonly refer to as Non-GKI includes both GKI1.0 (kernel versions 4.19-5.4) (5.4 is QGKI) and true Non-GKI (kernel versions ≤ 4.14).  

Due to severe fragmentation in Non-GKI kernels, which not only prevents universal compatibility but also results in inconsistent build environments—including but not limited to system versions, GCC versions, and Clang versions—we have decided to start an automated Non-GKI kernel compilation project.  
This project welcomes forks for personal modifications, contributions through pull requests, and collaborations.  

**Switching to Another KernelSU Branch**: Simply install the APK package of the new KernelSU branch on your current device, then flash the kernel with the modified branch to seamlessly switch KernelSU branches.  

# Usage Example
## Profiles/DeviceCodename_ROMName.env
Each profile consists of the following elements:  
**CONFIG_ENV** - Specifies the exact configuration file location within the Action environment.  

**DEVICE_NAME** - Full device name, format: Brand_Model_Region  
**DEVICE_CODENAME** - Device codename.  

**CUSTOM_CMDS** - Typically used to specify the compiler/alternative compiler.  
**EXTRA_CMDS** - Custom parameters required by the compiler.  

**KERNEL_SOURCE** - Location of the kernel source code.  
**KERNEL_BRANCH** - The required branch of the kernel source.  

**CLANG_SOURCE** - Location of Clang (supports git, tar.gz, tar.xz).  
**CLANG_BRANCH** - Required branch for Clang (only applicable if using git).  

**GCC_GNU** - If your kernel requires GCC but does not need a custom GCC, you can enable the system-provided GNU-GCC with true or false.  
**GCC_XX_SOURCE** - Location of GCC (supports git, tar.gz, tar.xz, zip). If you're an ARMV7A device, please only fill in GCC_32.  
**GCC_XX_BRANCH** - Required branch for GCC (only applicable if using git).  

**DEFCONFIG_SOURCE** - If you require a custom DEFCONFIG file, you can provide a download link for the DEFCONFIG file.  
**DEFCONFIG_NAME** - The required DEFCONFIG file for compilation, usually formatted as device_defconfig or vendor/device_defconfig.  
**DEFCONFIG_ORIGIN_IMAGE** - (Experimental ⚠) If you do not need the default DEFCONFIG from the kernel source and cannot provide a custom DEFCONFIG, you can extract the DEFCONFIG file from the Image file you obtained (Image.gz and Image.gz-dtb need to be manually decompressed before uploading). **DEFCONFIG_NAME** must be specified and cannot be empty.  

**KERNELSU_SOURCE** - You can specify the source of KernelSU. By default, it uses setup.sh, but if necessary, manual installation can be enabled (in which case, this should be a git repository).  
**KERNELSU_BRANCH** - The branch of KernelSU to use.  
**KERNELSU_NAME** - Some KernelSU branches have different names, so you must specify the correct name. The default is KernelSU.  

**SUSFS_ENABLE** - Whether to enable SUSFS during compilation (true or false).  
**SUSFS_FIXED** - Whether to apply additional patches to fix SUSFS-related issues during kernel compilation. If this option is set to true, incorrect **PATCHES_SOURCE** and **PATCHES_BRANCH** values may cause errors.  
**SUSFS_UPDATE** - Whether to perform the SUSFS update to v1.5.7, true or false.  

**AK3_SOURCE** - Location of AnyKernel3 (if needed, only supports git).  
**AK3_BRANCH** - Required branch for AnyKernel3.  

**BOOT_SOURCE** - If you have enabled MKBOOTIMG packaging, specify the location of the original clean kernel image (must be in .img format).  

**LXC_ENABLE** - (Experimental ⚠) Enable automated kernel support for LXC/Docker (true or false).  

**HAVE_NO_DTBO** - (Experimental ⚠) If your kernel does not provide a dtbo.img but your device uses an A/B partitioning scheme with a dtbo partition, you can enable this option (true). The default is false. Reference: https://review.lineageos.org/c/LineageOS/android_kernel_xiaomi_gauguin/+/372909/2.  
**HAVE_NO_DTBO_TOOL** - (Experimental ⚠) After enabling the previous option, you can choose to enable this one to use a safer method for generating dtbo.img.  

**ROM_TEXT** - Used in the final filename of the compiled kernel to indicate which ROM it is compatible with.  

## .github/workflows/build_kernel_Device_Model_ROM_AndroidVersion.yml
We have provided example .env and .yml files for compilation. Below is an overview of the .yml structure.  
Only key configurable sections are highlighted; modifying steps and sequences extensively is not recommended.  
All patches provided by this project are not guaranteed to work properly on kernel versions ≤4.4.  
These are the example files we provide: **codename_rom_template.env** and **build_kernel_template.yml**.  
**build_kernel_arch_template.yml** is a sample YAML based on Arch Linux and is currently in **Beta** testing.  
GitHub has dropped support for Ubuntu 20.04. If you still need it or are using Clang Proton, please use **build_kernel_older_template.yml**. This is currently in Beta testing.  

- **env:** - Define essential variables independently from the Profiles configuration.
    - **PYTHON_VERSION** - The default Python command in Ubuntu is Python 3, but Python 2 is still needed in some cases. This variable allows you to specify 2 or 3. If you only need to install Python 2 without changing the default Python version, you can add PYTHON=/usr/bin/python2 to EXTRA_CMDS to force Python 2 to be used during compilation.
    - **PACK_METHOD** - Packaging method, either MKBOOTIMG or [Anykernel3](https://github.com/osm0sis/AnyKernel3) (default: Anykernel3).
    - **KERNELSU_METHOD** - The method for embedding KernelSU:
        - The default is "**shell**". 
        - If setup.sh is not used or encounters errors, change this to "**manual**". Although manual means manual installation, no manual intervention is required. Pay attention to it that execute git in choose the mode only.
        - If your kernel already has KernelSU but you want to replace it, you can use "**only**" to execute Git operations without applying patches.
    - **PATCHES_SOURCE** - SUSFS typically requires manual patches. Provide the GitHub repository URL containing the patches. If you are not using SUSFS, this can be left blank.
    - **PATCHES_BRANCH** - The required branch for the patch repository (default: main).
    - **HOOK_METHOD** - Two KernelSU patching methods are available:
        - **normal**: Standard patching, works in most cases. This is only suitable for ARM64 devices with kernel version 3.18 or higher.
        - [syscall](https://github.com/backslashxx/KernelSU/issues/5): Minimal patching method, which may improve hiding KernelSU but might cause ISO compliance issues with older Clang versions，And there are issues with support for kernels ≤4.9. It is recommended to enable this only for higher kernel versions. We now support all kernel versions, with 3.4 being the minimum supported version. For kernels with versions **4.9 or older**, it will automatically apply patches for kernel_write and kernel_read. However, it's possible that a second round of patching might be needed. For newer kernel versions, this isn't a concern.
    - **HOOK_OLDER** - If you need the syscall patch, but your device or KernelSU doesn't support the latest version of syscall, you can enable this.
    - **PROFILE_NAME** - Enter the name of your modified ENV environment variable file, such as codename_rom_template.env.
    - **KERNELSU_SUS_PATCH** - If your KernelSU is not part of KernelSU-Next and does not have a patch branch for SuSFS, you can enable this option (true). However, we do not recommend doing so, as the KernelSU branches have been heavily modified, and manual patching is no longer suitable for the current era.
    - **KPM_ENABLE** - (Experimental ⚠) Enables compilation support for KPM in SukiSU-Ultra. This is an experimental feature, so please enable it with caution.
    - **KPM_FIX** - (Experimental ⚠) The current KPM feature might have a ["stack frame" overflow vulnerability](https://www.google.com/search?q=https://github.com/SukiSU-Ultra/SukiSU-Ultra/issues/141) that leads to compilation failures. If you're experiencing this issue, enable this option.
    - **KPM_PATCH_SOURCE** - (Experimental ⚠) Normally, you don't need to provide the patch binary download link yourself, unless you have additional requirements.
    - **GENERATE_DTB** - If your kernel requires a DTB file after compilation (not .dtb, .dts, or .dtsi), you can enable this option to automatically generate the DTB file. 
    - **GENERATE_CHIP** - Set the corresponding device CPU, and provide it for DTB and KPM functions for identification. It typically supports Qualcomm (qcom) and MediaTek (mediatek), but we're unsure if other CPUs are supported.
    - **BUILD_DEBUGGER** - Enables error reporting if needed. Currently, it provides output for patch error .rej files and basic compilation error analysis., with more features expected in future updates.
    - **SKIP_PATCH** - When **BUILD_DEBUGGER** is enabled, if you want to display error file information but don't want it to affect the compilation process, you can enable this option.
    - **BUILD_OTHER_CONFIG** - If you need to merge additional .config files included in the kernel source, you can enable this option. However, you must manually modify the MERGE_CONFIG_FILES array in the "Build Kernel" section.
    - **FREE_MORE_SPACE** - If you believe the current available space is insufficient, you can enable this option to free up additional space. By default, approximately 88GB of space is available. Enabling this option can increase the available space to 102GB, but it will add 1–2 minutes to the execution time. (Only applies to the default YAML; Arch Linux or Ubuntu 20.04 can only provide 14–20GB of space.)
    - **REKERNEL_ENABLE** - If you believe your device meets the requirements to run [Re:Kernel](https://github.com/Sakion-Team/Re-Kernel) and you need Re:Kernel, you can enable this option, true or false.

- **runs-on:** ubuntu-XX.XX 
    - Different kernels may require different Ubuntu versions. The default is 22.04, but support for 20.04, 22.04 and 24.04 is available. The system version determines which package installation method is used.
    - If you are using the Arch Linux YAML, this feature is not applicable — please do not modify it.

- **Set Compile Environment**
    - This section is divided into No-GCC and With-GCC. Clang also has differentiated checks, please continue reading.
    - If no GCC is needed, Clang-only compilation is selected automatically.
    - If GCC is needed, both 64-bit and 32-bit versions must be specified. The recommended format is git, but tar.gz and zip are also supported.
    - You can choose to use only GCC without enabling Clang. Additionally, GCC allows using the system's default installed version. This can be enabled in the YAML file variables.
    - Clang sources can be in git, tar.gz, tar.xz, zip, or managed via antman.
    - If you're planning to use [Proton Clang 13](https://github.com/kdrag0n/proton-clang), you'll need to use the Older YAML. (We don't recommend Arch Linux, as it might lead to glibc issues.) We've pre-adapted the Proton Clang Toolchain, so it'll automatically detect and recognize the bundled GCC when Proton Clang is found. However, remember not to fill in the GCC field yourself.

- **Get Kernel Source**
    - Normally, kernel source code can be obtained via Git, so modifications are generally unnecessary.
    - Some smartphone manufacturers have questionable practices—they open source the code, but it's pre-packaged, or they separate drivers from the kernel source. As a result, you may need to modify this part yourself.
    
- **Set Pack Method, KernelSU, and SUSFS**
    - **Anykernel3** - If AnyKernel3 is not found in the kernel source, the one specified in env is used. Only git is supported.
    - **MKBOOTIMG** - Requires a clean kernel image. The recommended method is using a GitHub raw URL.

- **Extra Kernel Options**
    - Some kernels require additional settings during compilation. 
    - If your kernel does not, you can comment out this section.

- **Added mkdtboimg to kernel (Experimental)**
    - Most kernels do not need this feature. Some kernels, like Nameless, lack dtbo.img but do not require it.
    - This is only applicable to A/B partition devices. Enabling this could make the device unbootable, so proceed with caution.

- **Setup LXC (Experiment)**
    - Enables LXC support automatically. However, many kernels do not support this method.
    - This is mainly for testing and is not used in official builds.

- **Patch Kernel**
    - Divided into three sections: SUSFS patching, Re:Kernel patching, and supplementary patching (Patch Kernel of SUSFS, Patch Kernel of Re:Kernel, and Fixed Kernel Patch).
    - Everything is based on env.SUSFS_ENABLE, env.REKERNEL_ENABLE, and env.SUSFS_FIXED being true, but they are not necessarily all true.
    - SUSFS patching and Re:Kernel patching are highly likely to cause issues, so supplementary patching is usually required.
    - SUSFS patching and Re:Kernel patching may cause issues, requiring additional fixes (under Fixed Kernel Patch).
    - If you have a **4.9** kernel and it's not being recognized properly after patching with the default Re:Kernel patch, you can try switching to the Re:Kernel Fixed patch.
    - Make sure to correctly fill in **PATCHES_SOURCE** and **PATCHES_BRANCH**, otherwise it will result in errors.
    - When SUSFS_FIXED is enabled by default, the directory cloned via PATCHES_SOURCE and PATCHES_BRANCH will be named **NonGKI_Kernel_Patches**, even if your project has a different name.

- **Update SUSFS Version**
    - Intended to update version v1.5.5, which will stop receiving updates, to SUSFS v1.5.7.
    - This patch originates from the Treewide Commit of rsuntk, the author of the KernelSU branch.
    - Patching is not guaranteed to pass on the first attempt and may require creating your own patch for a secondary fix.
    - Whether this step is executed is controlled by a variable.
    
- **KPM Patcher (Experiment)**
    - SukiSU-Ultra now offers KPM kernel patching functionality. 
    - This feature works correctly under **Arch Linux** but behaves **abnormally on Ubuntu 22.04**. It is recommended to use the latest version of **Ubuntu or the Arch Linux YAML**.
    
## Patches/Patch_Introduction.patch
Below is an introduction to the patches included in the Patches directory:  

- **normal_patches.sh**
    - Variable: HOOK_METHOD -> normal
    - Used for manually patching Non-GKI kernels. This is also the kernel used in the manual patching section for Non-GKI kernels on the KernelSU official website. This is only suitable for ARM64 devices with kernel version 3.18 or higher. This will automatically execute for older kernel versions (kernel version ≤ 4.9) that lack SELinux-related permissions.
    - Reference: 
        - https://kernelsu.org/zh_CN/guide/how-to-integrate-for-non-gki.html
        - https://github.com/sticpaper/android_kernel_xiaomi_msm8998-ksu/commit/646d0c8
    
- **syscall_hook_patches.sh**
    - Variable: HOOK_METHOD -> syscall
    - Used for the latest minimized manual patching (Syscall) feature implemented by backslashxx. Compatibility with older compilers isn't great. But it's been adapted to support devices with kernel versions ≤ 3.18 (ARMV7A), so it's compatible with all kernels. This will automatically execute for older kernel versions (kernel version ≤ 4.9) that lack SELinux-related permissions.
        - If there are instances where syscall wasn't updated in time, you can submit an issue or a pull request.
    - Reference: https://github.com/backslashxx/KernelSU/issues/5
    
- **syscall_hook_patches_early.sh**
    - Variable: None
    - This is the original version of the syscall patch, intended for situations where you need syscall functionality but the latest version fails to execute.
    - Reference: https://github.com/backslashxx/KernelSU/issues/5

- **syscall_hook_patches_older.sh**
    - Variable: HOOK_METHOD -> syscall AND HOOK_OLDER -> true
    - Used for the latest minimized manual patching (Syscall) feature implemented by backslashxx. Compatibility with older compilers isn't great. But it's been adapted to support devices with kernel versions ≤ 3.18 (ARMV7A), so it's compatible with all kernels. This will automatically execute for older kernel versions (kernel version ≤ 4.9) that lack SELinux-related permissions.
        - Version 1.4
    - Reference: https://github.com/backslashxx/KernelSU/issues/5
    
- **backport_patches.sh**
    - Executes automatically based on kernel version.
    - Used for backporting features to Non-GKI kernels. While KernelSU-Next and SukiSU-Ultra can automatically handle backporting, other branches cannot.
    - Reference: https://github.com/backslashxx/KernelSU/issues/4#issue-2818274642
    
- **backport_patches_early.sh**
    - Automatic execution
    - This refers to the older backport solution, which is used for both the normal patch and the older version of the syscall patch.
    - Reference: https://github.com/backslashxx/KernelSU/issues/4#issue-2818274642

- **found_gcc.sh**
    - Executes automatically based on GCC detection.
    - Used for automated parsing of GCC prefixes.
    - Reference: None available.

- **check_error.sh**
    - Variable: BUILD_DEBUGGER -> true
    - Used for analyzing basic compilation errors and providing some suggestions.
    - Reference: None available.
    
- **Patch/susfs_upgrade_to_157.patch**
    - Variable: (env file) SUSFS_UPDATE -> true
    - Updates SuSFS from v1.5.5 to v1.5.7 for Non-GKI devices that have stopped receiving updates.
    - Reference: https://github.com/rsuntk/android_kernel_asus_sdm660-4.19/commit/b3c85f330b135baf5c101b07f027e69e75f42060

- **Patch/susfs_upgrade_to_158_X_X.patch**
    - Variable: (env file) SUSFS_UPDATE -> true
    - Updates SuSFS from v1.5.7 to v1.5.8 for Non-GKI devices that have stopped receiving updates.
    - References:
        - https://github.com/rsuntk/android_kernel_asus_sdm660-4.19/commit/41678dd9290f04d98b9f0523574e11f98c7ce7c1
        - https://github.com/rsuntk/android_kernel_asus_sdm660-4.19/commit/60008290523a235282176b328f390777282024c9
        - https://github.com/rsuntk/android_kernel_asus_sdm660-4.19/commit/999ae11965ac2b4f3d3c7fbebc8e09cc8bbd0fce
        
- **Patch/susfs_upgrade_to_159.patch**
    - Variable: (env file) SUSFS_UPDATE -> true
    - Updates SuSFS from v1.5.8 to v1.5.9 for Non-GKI devices that have stopped receiving updates.
    - References:
        - https://gitlab.com/simonpunk/susfs4ksu/-/commit/fc90c9428b56133a99c39f0915472c0fc25979fe
        - https://gitlab.com/simonpunk/susfs4ksu/-/commit/b9dca0f7498413f5f6e19e74b530a64d628ae315
        - https://gitlab.com/simonpunk/susfs4ksu/-/commit/10f3cbdc26cad49094572e23bb62857e056a805c
        - https://gitlab.com/simonpunk/susfs4ksu/-/commit/072a1b42bf323439c71c045a389f362f39caffe0
        - https://gitlab.com/simonpunk/susfs4ksu/-/commit/a26ba8380e1d10b2169b8148967c4f5108c2a3f7

- **Patch/susfs_upgrade_to_1510_X_X.patch**
    - Variable: (env file) SUSFS_UPDATE -> true
    - Updates SuSFS from v1.5.9 to v1.5.10 for Non-GKI devices that have stopped receiving updates.
    - References:
        - https://gitlab.com/simonpunk/susfs4ksu/-/commit/756e48167a71cdc757d7c3e5a1d4fc329714dc37
        - https://gitlab.com/simonpunk/susfs4ksu/-/commit/7fce87f6d0a4dbc67aeb4e01e37a00eecb940bdf
        - https://gitlab.com/simonpunk/susfs4ksu/-/commit/650d9c1ba08c17bc0bb86ed19d8c8ae319f400ad
        - https://gitlab.com/simonpunk/susfs4ksu/-/commit/900b35c223529337681d8a36b9123858fd0da345
        - https://gitlab.com/simonpunk/susfs4ksu/-/commit/0e5081e1a2fc93d0ba1e87091ecdca006e3cd639
        - https://gitlab.com/simonpunk/susfs4ksu/-/commit/a92aa588cb1e2163e0d9fe7dd969d012f51654b2
        - https://gitlab.com/simonpunk/susfs4ksu/-/commit/e418485fc2694900b5cc8fa44cd98d194fb6ffa7
        
- **Patch/set_memory_to_49_and_low.patch**
    - Requires **manual** execution.
    - A patch file for backporting the set_memory function to devices with kernel versions ≤ 4.9. Due to a lack of extensive testing, it's considered a test patch only and should only be used when the KPM function of SukiSU-Ultra is required.
    - Reference: None available.

- **Patch/fix_kpm.patch**
    - Variable: KPM_FIX -> true
    - Used to address compilation failures caused by the **stack frame overflow vulnerability**.
    - Reference: https://github.com/SukiSU-Ultra/SukiSU-Ultra/issues/141
    
- **Rekernel/rekernel-X.X.patch**
    - Variable: REKERNEL_ENABLE -> true
    - A patch file to enable Re:Kernel support in the kernel. The YAML will automatically determine which patch to use based on your kernel version. However, if you have a 4.9 kernel and the current patch isn't working, you'll need to change the patch to rekernel-4.9-for-fixed.patch and try again. This does not support devices with kernel versions ≤ 4.4.
    - Reference: https://github.com/Sakion-Team/Re-Kernel/blob/main/Integrate/README_CN.md
    
- **Bin/curlx.sh**
    - Automatic execution
    - Used for more convenient execution of **curl** commands, including resuming interrupted downloads.
    - Reference: Updated by [@yu13140](https://github.com/yu13140).
    
Final Reminder⚠ : Unless otherwise mentioned, there is no need to modify any other sections of the .yml workflow. The setup is designed to automatically handle various conditions.
