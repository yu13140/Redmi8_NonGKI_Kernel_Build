# Non-GKI Kernel with KSU and SUSFS
![GitHub branch check runs](https://img.shields.io/github/check-runs/JackA1ltman/NonGKI_Kernel_Build/main)![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/JackA1ltman/NonGKI_Kernel_Build/latest/total)  
[支持列表](Supported_Devices.md) | 中文文档 | [English](README_EN.md) | [更新日志](Updated.md)  

**Ver**.1.5

**Non-GKI**：我们常说的Non-GKI包括了GKI1.0（内核版本4.19-5.4）（5.4为QGKI）和真正Non-GKI（内核版本≤4.14）  

由于Non-GKI内核存在严重的碎片化，不仅仅体现在内核无法通用，更是存在编译环境参差不齐，包括但不限于系统版本，GCC版本，Clang版本等等，因此决定开始自动化编译Non-GKI内核项目  
本项目欢迎Fork后自行编辑使用，也欢迎增加修改后提交合并，或者成为合作伙伴  

**切换其他KernelSU分支**：仅需要在当前设备下安装新KernelSU分支的APK安装包后，刷入修改过分支的内核，即可实现无缝切换KernelSU分支  

# 使用例
## Profiles/设备代号_ROM名称.env
总共由以下内容组成：  
**CONFIG_ENV** - 用来表明在Action环境中具体配置文件位置  

**DEVICE_NAME** - 设备全称，格式：设备品牌_型号_地区  
**DEVICE_CODENAME** - 设备代号  

**CUSTOM_CMDS** - 通常用于指明所用编译器/备用编译器  
**EXTRA_CMDS** - 通常用于编译器所需的自定义参数  

**KERNEL_SOURCE** - 内核源码所在之处  
**KERNEL_BRANCH** - 内核源码所需分支  

**CLANG_SOURCE** - Clang所在之处，但支持git、tar.gz、tar.xz  
**CLANG_BRANCH** - Clang所需分支，但前提是git  

**GCC_GNU** - 若你的内核需要GCC，但不需要自定义GCC，可通过选项启用系统提供的GNU-GCC，true或false  
**GCC_XX_SOURCE** - GCC所在之处，若你是ARMV7A设备，请仅填写GCC_32，支持git、tar.gz、tar.xz、zip  
**GCC_XX_BRANCH** - GCC所需分支，但前提是git  

**DEFCONFIG_SOURCE** - 若有自定义DEFCONFIG文件需求可提供DEFCONFIG文件的下载地址  
**DEFCONFIG_NAME** - 不管是否自定义，都需要提供用于编译的必要DEFCONFIG文件，通常格式为：设备_defconfig、vendor/设备_defconfig  
**DEFCONFIG_ORIGIN_IMAGE** - (实验性⚠)若你不需要内核源码中自带的DEFCONFIG，也无法提供自定义DEFCONFIG，则可以通过你所获取到的Image文件（Image.gz和Image.gz-dtb需要自行解压后上传文件）进行解包后获得defconfig文件，**DEFCONFIG_NAME**一定要填写，这不能为空

**KERNELSU_SOURCE** - 你可以自行设定KernelSU的来源，通常情况下是setup.sh。但有需求可启用手动安装的方式，此时则为git  
**KERNELSU_BRANCH** - 提供KernelSU的所属分支  
**KERNELSU_NAME** - 部分KernelSU分支存在不同的名称，所以你需要填写正确名称，默认为KernelSU  

**SUSFS_ENABLE** - 是否在编译时启用SUSFS，true或false  
**SUSFS_FIXED** - 是否启用SUSFS错误修补，一般用于内核修补时产生错误后，二次补充修补。若该项为true，若**PATCHES_SOURCE**和**PATCHES_BRANCH**不正确，则会导致错误  
**SUSFS_UPDATE** - 是否执行SUSFS更新至v1.5.7的操作，true或false  

**AK3_SOURCE** - Anykernel3所在之处，若需要的话，仅支持git  
**AK3_BRANCH** - Anykernel3所需分支  

**BOOT_SOURCE** - 若你已经启用MKBOOTIMG的方式，要填写原始干净内核的地址，仅限img格式  

**LXC_ENABLE** - (实验性⚠)启用自动化内核LXC/Docker支持，true或false  

**HAVE_NO_DTBO** - (实验性⚠)若你的内核没有提供dtbo.img，且你的设备属于A/B分区且存在dtbo分区，则可启用本选项(true)，默认为false，参考：https://review.lineageos.org/c/LineageOS/android_kernel_xiaomi_gauguin/+/372909/2  
**HAVE_NO_DTBO_TOOL** - (实验性⚠)在上一项启用后，你可以选择启用这项来获得更加安全的生成dtbo.img方案  

**ROM_TEXT** - 用于编译成功后用于上传文件标题，声明内核可用的ROM  

## .github/workflow/build_kernel_设备简称_型号_ROM_Android版本.yml
我们编写了env和用于编译的yml的例本，接下来是对yml例本的解析  
这里仅指出大概可供修改的地方，具体可按需求修改，我们不建议过度修改步骤和顺序  
本项目提供的所有补丁均不能保证在≤4.4内核能够正常使用  
这是我们提供的示例文件：**codename_rom_template.env**和**build_kernel_template.yml**  
**build_kernel_arch_template.yml**为基于Arch Linux的示例YAML，当前为Beta测试  
Github放弃了Ubuntu 20.04，若你有需求，或者使用Clang Proton，请使用**build_kernel_older_template.yml**，当前为Beta测试  

- **env:** - 设置必要修改的变量，独立于Profiles
  - **PYTHON_VERSION** - Ubuntu的Python命令默认为Python3，但2仍有需求，因此增加该变量，可填写**2**或**3**。如果你仅仅需要安装python2但不想修改默认python，那你可以在EXTRA_CMDS中增加PYTHON=/usr/bin/python2，便可以强制执行python2参与编译
  - **PACK_METHOD** - 打包方式，分为MKBOOTIMG，和[Anykernel3](https://github.com/osm0sis/AnyKernel3)，默认为Anykernel3
  - **KERNELSU_METHOD** - 嵌入KernelSU的方式：
    - 通常情况下使用**shell**方式即可
    - 但如果你提供了非setup.sh的方式，或者该方式报错，请将其修改**manual**，manual虽然是手动安装，但实际上并不需要维护者修改任何内容，但注意，选该模式仅能使用git
    - 若你的内核已经存在KernelSU，但你想要替换，可使用**only**，仅执行git不执行修补
  - **PATCHES_SOURCE** - 使用susfs不可避免需要手动修补，这是用来填写你存放patch的github项目地址，当然如果你不采用susfs，则不需要填写，可参考我的用于Patch的git项目
  - **PATCHES_BRANCH** - patch项目所需的分支，一般为main
  - **HOOK_METHOD** - 我们提供了两种方式用于KernelSU手动修补：
    - **normal**代表最常见的修补方式，一般不会出问题，仅适合内核版本≥3.18（ARM64）设备
    - [syscall](https://github.com/backslashxx/KernelSU/issues/5)是最新的最小化修补方式，似乎会提高隐藏，但是在低版本clang下可能会有ISO编译规范问题，目前已经支持包括3.4版本内核为最低版本的所有内核，对于**内核版本≤4.9**的内核，会自动执行针对kernel_write和kernel_read的修补补丁，但可能存在需要二次修补的情况，更高版本内核则不需要考虑这个事情
  - **HOOK_OLDER** - 若你需要syscall补丁，但你的设备或KernelSU不支持最新版本的syscall则可以启用
  - **PROFILE_NAME** - 填写成你修改好的env环境变量文件的名称，例如codename_rom_template.env
  - **KERNELSU_SUS_PATCH** - 如果你的KernelSU不属于KernelSU-Next，并且也没有针对SuSFS的修补分支，可以启用该项目（true），但我们不建议这么做，因为分支KernelSU的魔改情况严重，手动修补已经不能顺应现在的时代了
  - **KPM_ENABLE** - (实验性⚠)启用对SukiSU-Ultra的KPM编译支持，该项为实验项，请小心启用
  - **KPM_FIX** - (实验性⚠)当前KPM功能可能存在[“栈帧”溢出漏洞](https://github.com/SukiSU-Ultra/SukiSU-Ultra/issues/141)导致编译失败，若你存在该问题请启用本项
  - **KPM_PATCH_SOURCE** - (实验性⚠)通常你不需要自行提供patch二进制下载链接，除非你有额外需求
  - **GENERATE_DTB** - 如果你的内核编译后，需要DTB文件（不是.dtb、.dts、.dtsi），则可以开启本项自动执行生成DTB步骤
  - **GENERATE_CHIP** - 设定对应设备CPU，并提供给DTB和KPM功能用于识别，通常支持qcom、mediatek，但我们不确定其他CPU是否支持
  - **BUILD_DEBUGGER** - 若需要提供出错时的报告可使用该选项，目前提供patch错误rej文件的输出，以及基础的编译错误分析，其他功能可期待未来更新
  - **SKIP_PATCH** - 当启用DEBUGGER后，若你需要展示错误文件信息但又不希望影响编译流程，则可开启本项
  - **BUILD_OTHER_CONFIG** - 若你需要合并内核源码中自带的其他.config文件，可启用本项，但是需要自行修改”Build Kernel“中数组MERGE_CONFIG_FILES中的内容
  - **FREE_MORE_SPACE** - 若你认为当前的空间不足，则可以启用该项来获得更多空间释放，默认情况下可获得约88GB空间，启用本项可获得102GB空间，但执行时间会增加1-2分钟（仅限默认YAML，Arch Linux或Ubuntu 20.04仅可获得14-20GB空间）
  - **REKERNEL_ENABLE** - 如果你认为你的设备具备运行[Re:Kernel](https://github.com/Sakion-Team/Re-Kernel)的条件，并且你需要Re:Kernel，则可以启用本项，true或者false

- **runs-on: ubuntu-XX.XX** 
  - 不同内核所需系统不同，默认为22.04，我们预先提供了两套包安装选项（适配20.04、22.04和24.04），我们通过检测系统版本进行决定包安装
  - 若使用Arch Linux YAML则该功能不适用，请不要修改

- **Set Compile Environment**
  - 这里分为无GCC和有GCC，Clang也有区分判定，请继续往下看
  - 若无GCC，则会自动选择仅Clang，而通常情况下，仅Clang可用于使用antman进行管理的Clang，这些步骤我们都已经可以自动识别，因此不需要修改yml来实现
  - 若有GCC，则需填写GCC 64位和32位的版本，对于GCC我们建议git形式，但同时支持tar.gz和zip
  - 你可以选择仅使用GCC而不启用Clang，并且GCC允许使用系统默认安装的GCC，可在yaml文件变量中开启
  - 根据本人的使用情况，我们对于Clang支持为git、tar.gz、tar.xz、zip以及上述提到的antman管理软件
  - 如果你计划使用[Proton Clang 13](https://github.com/kdrag0n/proton-clang)，则需要使用Older YAML（我们不推荐Arch Linux，可能会导致glibc问题），我们已经预先适配了Proton Clang Toolchain，会在检测到Proton Clang后自动识别附带的GCC，但也记得不要填写GCC

- **Get Kernel Source**
  - 正常来说内核源码都可以通过Git方式获得，所以基本不需要修改
  - 某些国产厂商的水平堪忧，开源但却是自打包，或者驱动与内核源码分离，因此可能需要你自己修改这个部分
  
- **Set Pack Method and KernelSU and SUSFS**
  - 我们默认提供Anykernel3和MKBOOTIMG两种打包方式，其中AK3可以自动检测内核源码中是否存在，若不存在则调用env提供的SOURCE和BRANCH，对于AK3仅提供git方式，MKBOOTIMG由我们默认提供，一般不需要自行获取
  - **Anykernel3** 需要提供对应项目的地址和分支，且仅支持git方式，或者使用我们提供的默认方式，一般不会出错
  - **MKBOOTIMG** 需要提供干净的原始内核镜像文件，我们建议使用Github raw地址

- **Extra Kernel Options** 
  - 有些内核编译时需要提供更多设置项
  - 通常为针对defconfig文件的补充项，但的确，有些完善的内核其实并不需要额外的设置项，不需要就把该模块中所有内容注释掉即可跳过

- **Added mkdtboimg to kernel (Experiment)** 
  - 如你所见，很多内核，或者说大部分内核都不需要该功能，有些内核例如nameless虽然没有dtbo,但实际上他的确不需要。而且仅限A/B分区的设备，且存在危险性，例如加上dtbo反而无法启动设备等等，三思而后行

- **Setup LXC (Experiment)** 
  - 自动部署LXC，但许多内核并不支持该方式，可用于Fork后自行尝试，在本人的官方编译中应该不会选择支持LXC
  
- **Patch Kernel**
  - 分为三个部分，SUSFS修补、Re:Kernel修补以及补充修补（Patch Kernel of SUSFS 、Patch Kernel of Re:Kernel 和 Fixed Kernel Patch）
  - 一切基于env.SUSFS_ENABLE、env.REKERNEL_ENABLE 和 env.SUSFS_FIXED为true，但不一定都为true
  - SUSFS修补 和 Re:Kernel修补 大概率会产生问题，因此通常情况下需要补充修补
  - 若你为**4.9**内核，在使用默认的Re:Kernel补丁修补后无法正常识别到，可切换至Re:Kernel Fixed补丁尝试
  - 补充修补需要执行你重新制作的patch补丁（步骤为：Fixed Kernel Patch）
  - 切记填写好**PATCHES_SOURCE**和**PATCHES_BRANCH**，否则会导致错误
  - 默认SUSFS_FIXED启用后，通过PATCHES_SOURCE和PATCHES_BRANCH所git下来的目录的名称叫**NonGKI_Kernel_Patches**，即便你的项目不是这个名称
  
- **Update SUSFS Version**
  - 旨在将停止更新的版本v1.5.5进行更新SUSFS v1.5.7的操作
  - 该补丁源于KernelSU分支作者rsuntk的Treewide Commit
  - 修补不能保证一次性通过，可能需要自行制作用于二次修补的补丁
  - 由变量控制是否执行该步骤
  
- **KPM Patcher (Experiment)**
  - 为SukiSU-Ultra提供KPM内核Patch功能
  - 该功能在**Arch Linux**下可以正常执行，在**Ubuntu22.04下异常**，建议使用**最新版Ubuntu或者Arch Linux YAML**

## Patches/补丁介绍.patch
以下是对Patches目录中包含补丁的介绍  

- **normal_patches.sh**
  - 变量：HOOK_METHOD -> normal
  - 用于执行Non-GKI内核的手动修补，也是KernelSU官网Non-GKI内核手动修补部分的内核，仅适合内核版本≥3.18（ARM64）设备，会自动执行对缺少SELinux相关权限的旧版本内核（内核版本≤4.9）
  - 参考：
    - https://kernelsu.org/zh_CN/guide/how-to-integrate-for-non-gki.html
    - https://github.com/sticpaper/android_kernel_xiaomi_msm8998-ksu/commit/646d0c8

- **syscall_hook_patches.sh**
  - 变量：HOOK_METHOD -> syscall
  - 用于执行backslashxx大佬最新实现的最小化手动修补(Syscall)功能，对旧版本编译器兼容性不是很好，但适配支持了内核版本≤3.18（ARMV7A）设备，会自动执行对缺少SELinux相关权限的旧版本内核（内核版本≤4.9），因此全内核可用
    - 若存在没有及时更新syscall的情况，可提出issue或pr
  - 参考：https://github.com/backslashxx/KernelSU/issues/5
  
- **syscall_hook_patches_older.sh**
  - 变量：HOOK_METHOD -> syscall 和 HOOK_OLDER -> true
  - 用于执行backslashxx大佬最新实现的最小化手动修补(Syscall)功能，对旧版本编译器兼容性不是很好，但适配支持了内核版本≤3.18（ARMV7A）设备，会自动执行对缺少SELinux相关权限的旧版本内核（内核版本≤4.9），因此全内核可用
    - 版本：1.4
  - 参考：https://github.com/backslashxx/KernelSU/issues/5
  
- **syscall_hook_patches_early.sh**
  - 暂无执行方式
  - syscall的最初版本，适用于需要syscall但执行最新版失败的情况
  - 参考：https://github.com/backslashxx/KernelSU/issues/5
  
- **backport_patches.sh** 
  - 自动判断内核版本执行
  - 用于执行对Non-GKI内核的反向移植，除了KernelSU-Next和SukiSU-Ultra可以实现自动反向移植外，其他的分支均无法实现
  - 参考：https://github.com/backslashxx/KernelSU/issues/4#issue-2818274642
  
- **backport_patches_early.sh** 
  - 自动执行
  - 旧版向后移植方案，用于normal patch和syscall旧版
  - 参考：https://github.com/backslashxx/KernelSU/issues/4#issue-2818274642

- **found_gcc.sh**
  - 自动判断GCC执行
  - 用于对GCC前缀进行自动化解析
  - 参考：暂无
  
- **check_error.sh**
  - 变量：BUILD_DEBUGGER -> true
  - 用于分析基础的编译错误，并提供一定建议
  - 参考：暂无
  
- **Patch/susfs_upgrade_to_157.patch**
  - 变量：(env文件)SUSFS_UPDATE -> true
  - 对停止更新的Non-GKI设备的SuSFS进行更新，从v1.5.5更新至v1.5.7
  - 参考：https://github.com/rsuntk/android_kernel_asus_sdm660-4.19/commit/b3c85f330b135baf5c101b07f027e69e75f42060
  
- **Patch/susfs_upgrade_to_158_X_X.patch**
  - 变量：(env文件)SUSFS_UPDATE -> true
  - 对停止更新的Non-GKI设备的SuSFS进行更新，从v1.5.7更新至v1.5.8
  - 参考：
    - https://github.com/rsuntk/android_kernel_asus_sdm660-4.19/commit/41678dd9290f04d98b9f0523574e11f98c7ce7c1
    - https://github.com/rsuntk/android_kernel_asus_sdm660-4.19/commit/60008290523a235282176b328f390777282024c9
    - https://github.com/rsuntk/android_kernel_asus_sdm660-4.19/commit/999ae11965ac2b4f3d3c7fbebc8e09cc8bbd0fce
    
- **Patch/susfs_upgrade_to_159.patch**
  - 变量：(env文件)SUSFS_UPDATE -> true
  - 对停止更新的Non-GKI设备的SuSFS进行更新，从v1.5.8更新至v1.5.9
  - 参考：
    - https://gitlab.com/simonpunk/susfs4ksu/-/commit/fc90c9428b56133a99c39f0915472c0fc25979fe
    - https://gitlab.com/simonpunk/susfs4ksu/-/commit/b9dca0f7498413f5f6e19e74b530a64d628ae315
    - https://gitlab.com/simonpunk/susfs4ksu/-/commit/10f3cbdc26cad49094572e23bb62857e056a805c
    - https://gitlab.com/simonpunk/susfs4ksu/-/commit/072a1b42bf323439c71c045a389f362f39caffe0
    - https://gitlab.com/simonpunk/susfs4ksu/-/commit/a26ba8380e1d10b2169b8148967c4f5108c2a3f7

- **Patch/susfs_upgrade_to_1510_X_X.patch**
  - 变量：(env文件)SUSFS_UPDATE -> true
  - 对停止更新的Non-GKI设备的SuSFS进行更新，从v1.5.9更新至v1.5.10
  - 参考：
    - https://gitlab.com/simonpunk/susfs4ksu/-/commit/756e48167a71cdc757d7c3e5a1d4fc329714dc37
    - https://gitlab.com/simonpunk/susfs4ksu/-/commit/7fce87f6d0a4dbc67aeb4e01e37a00eecb940bdf
    - https://gitlab.com/simonpunk/susfs4ksu/-/commit/650d9c1ba08c17bc0bb86ed19d8c8ae319f400ad
    - https://gitlab.com/simonpunk/susfs4ksu/-/commit/900b35c223529337681d8a36b9123858fd0da345
    - https://gitlab.com/simonpunk/susfs4ksu/-/commit/0e5081e1a2fc93d0ba1e87091ecdca006e3cd639
    - https://gitlab.com/simonpunk/susfs4ksu/-/commit/a92aa588cb1e2163e0d9fe7dd969d012f51654b2
    - https://gitlab.com/simonpunk/susfs4ksu/-/commit/e418485fc2694900b5cc8fa44cd98d194fb6ffa7
    
- **Patch/set_memory_to_49_and_low.patch**
  - 变量：KPM_ENABLE -> true
  - 用于对内核版本≤4.9的设备移植set_memory功能的补丁文件，因为缺少大量测试，因此只作为测试补丁，且该补丁仅用于需要使用SukiSU-Ultra的KPM功能的情况下
  - 参考：暂无

- **Patch/backport_kernel_read_and_kernel_write_to_ksu.patch**
  - 变量：HOOK_NEWER -> true
  - 用于执行对Non-GKI内核（**内核版本≤4.9**）的反向移植，可能存在需要二次修补的情况
  - 参考：https://github.com/backslashxx/KernelSU/issues/4#issue-2818274642
  
- **Patch/fix_kpm.patch**
  - 变量：KPM_FIX -> true
  - 用于应对**栈帧溢出漏洞**导致的编译失败问题
  - 参考：https://github.com/SukiSU-Ultra/SukiSU-Ultra/issues/141
  
- **Rekernel/rekernel-X.X.patch**
  - 变量：REKERNEL_ENABLE -> true
  - 让内核支持Re:Kernel的补丁文件，YAML会根据你的内核版本自动判断使用的补丁，不过若你是4.9内核且当前补丁不可用，就需要将补丁修改成rekernel-4.9-for-fixed.patch后尝试，不支持内核版本≤4.4设备
  - 参考：https://github.com/Sakion-Team/Re-Kernel/blob/main/Integrate/README_CN.md
  
- **Bin/curlx.sh**
  - 自动执行
  - 用于更加便捷的执行包括断点续传在内的curl命令
  - 参考：由[@yu13140](https://github.com/yu13140)提供更新
  
最后提醒⚠️：非上述提示的步骤理论上不需要你做任何修改，我已经尽可能实现多情况判定
