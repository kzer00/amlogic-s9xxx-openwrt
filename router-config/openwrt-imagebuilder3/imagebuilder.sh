#!/bin/bash
#================================================================================================
#
# This file is licensed under the terms of the GNU General Public
# License version 2. This program is licensed "as is" without any
# warranty of any kind, whether express or implied.
#
# This file is a part of the make OpenWrt for Amlogic s9xxx tv box
# https://github.com/ophub/amlogic-s9xxx-openwrt
#
# Description: Build OpenWrt with Image Builder
# Copyright (C) 2021- https://github.com/unifreq/openwrt_packit
# Copyright (C) 2021- https://github.com/ophub/amlogic-s9xxx-openwrt
#
# Download from: https://downloads.openwrt.org/releases
# Documentation: https://openwrt.org/docs/guide-user/additional-software/imagebuilder
# Instructions:  Download OpenWrt firmware from the official OpenWrt,
#                Use Image Builder to add packages, lib, theme, app and i18n, etc.
#
# Command: ./router-config/openwrt-imagebuilder/imagebuilder.sh <branch>
#          ./router-config/openwrt-imagebuilder/imagebuilder.sh 21.02.3
#
#======================================== Functions list ========================================
#
# error_msg               : Output error message
# download_imagebuilder   : Downloading OpenWrt ImageBuilder
# adjust_settings         : Adjust related file settings
# custom_packages         : Add custom packages
# custom_config           : Add custom config
# custom_files            : Add custom files
# rebuild_firmware        : rebuild_firmware
#
#================================ Set make environment variables ================================
# IMMORTALWRT
# Set default parameters
make_path="${PWD}"
openwrt_dir="openwrt"
imagebuilder_path="${make_path}/${openwrt_dir}"
custom_files_path="${make_path}/router-config/openwrt-imagebuilder3/files"
custom_config_file="${make_path}/router-config/openwrt-imagebuilder3/config"

# Set default parameters
STEPS="[\033[95m STEPS \033[0m]"
INFO="[\033[94m INFO \033[0m]"
SUCCESS="[\033[92m SUCCESS \033[0m]"
WARNING="[\033[93m WARNING \033[0m]"
ERROR="[\033[91m ERROR \033[0m]"
#
#================================================================================================

# Encountered a serious error, abort the script execution
error_msg() {
    echo -e "${ERROR} ${1}"
    exit 1
}

# Downloading OpenWrt ImageBuilder
download_imagebuilder() {
    cd ${make_path}
    echo -e "${STEPS} Start downloading OpenWrt files..."

    # Downloading imagebuilder files
    # Download example: https://downloads.openwrt.org/releases/21.02.3/targets/armvirt/64/openwrt-imagebuilder-21.02.3-armvirt-64.Linux-x86_64.tar.xz
   # download_file="https://downloads.openwrt.org/releases/${rebuild_branch}/targets/armvirt/64/openwrt-imagebuilder-${rebuild_branch}-armvirt-64.Linux-x86_64.tar.xz"
    download_file="https://downloads.immortalwrt.org/releases/${rebuild_branch}/targets/armvirt/64/immortalwrt-imagebuilder-${rebuild_branch}-armvirt-64.Linux-x86_64.tar.xz"
    wget -q ${download_file}
    [[ "${?}" -eq "0" ]] || error_msg "Wget download failed: [ ${download_file} ]"

    # Unzip and change the directory name
    tar -xJf immortalwrt-imagebuilder-* && sync && rm -f immortalwrt-imagebuilder-*.tar.xz
    mv -f immortalwrt-imagebuilder-* ${openwrt_dir}

    sync && sleep 3
    echo -e "${INFO} [ ${make_path} ] directory status: $(ls . -l 2>/dev/null)"
}

# Adjust related files in the ImageBuilder directory
adjust_settings() {
    cd ${imagebuilder_path}
    echo "src/gz custom_repo https://raw.githubusercontent.com/kzer00/repo/main/aarch64_cortex-a53" >> repositories.conf
    sed -i 's/option check_signature/# option check_signature/g' repositories.conf
    echo -e "${STEPS} Start adjusting .config file settings..."

    # For .config file
    if [[ -s ".config" ]]; then
        # Root filesystem archives
        sed -i "s|CONFIG_TARGET_ROOTFS_CPIOGZ=.*|# CONFIG_TARGET_ROOTFS_CPIOGZ is not set|g" .config
        # Root filesystem images
        sed -i "s|CONFIG_TARGET_ROOTFS_EXT4FS=.*|# CONFIG_TARGET_ROOTFS_EXT4FS is not set|g" .config
        sed -i "s|CONFIG_TARGET_ROOTFS_SQUASHFS=.*|# CONFIG_TARGET_ROOTFS_SQUASHFS is not set|g" .config
        sed -i "s|CONFIG_TARGET_IMAGES_GZIP=.*|# CONFIG_TARGET_IMAGES_GZIP is not set|g" .config
    else
        error_msg "There is no .config file in the [ ${download_file} ]"
    fi

    # For other files
    # ......

    sync && sleep 3
    echo -e "${INFO} [ openwrt ] directory status: $(ls -al 2>/dev/null)"
}

# Add custom packages
# If there is a custom package or ipk you would prefer to use create a [ packages ] directory,
# If one does not exist and place your custom ipk within this directory.
custom_packages() {
    cd ${imagebuilder_path}
    echo -e "${STEPS} Start adding custom packages..."

    # Create a [ packages ] directory
    [[ -d "packages" ]] || mkdir packages

    # Download luci-app-amlogic
    #amlogic_api="https://api.github.com/repos/kzer00/rootfs/releases"
    
    #
    #amlogic_file="luci-app-amlogic"
    #amlogic_file_down="$(curl -s ${amlogic_api} | grep "browser_download_url" | grep -oE "https.*${amlogic_file}.*.ipk" | head -n 1)"
    #wget -q ${amlogic_file_down} -O packages/${amlogic_file_down##*/}
    [[ "${?}" -eq "0" ]] && echo -e "${INFO} The [ ${amlogic_file} ] is downloaded successfully."
    #
    #amlogic_tano="luci-theme-tano"
    #amlogic_tano_down="$(curl -s ${amlogic_api} | grep "browser_download_url" | grep -oE "https.*${amlogic_tano}.*.ipk" | head -n 1)"
    #get -q ${amlogic_tano_down} -O packages/${amlogic_tano_down##*/}
    [[ "${?}" -eq "0" ]] && echo -e "${INFO} The [ ${amlogic_tano} ] is downloaded successfully."
    #
    #amlogic_tinyfm="luci-app-tinyfm"
    #amlogic_tinyfm_down="$(curl -s ${amlogic_api} | grep "browser_download_url" | grep -oE "https.*${amlogic_tinyfm}.*.ipk" | head -n 1)"
    #wget -q ${amlogic_tinyfm_down} -O packages/${amlogic_tinyfm_down##*/}
    [[ "${?}" -eq "0" ]] && echo -e "${INFO} The [ ${amlogic_tinyfm} ] is downloaded successfully."
    #   
    #amlogic_xmm="xmm-modem"
    #amlogic_xmm_down="$(curl -s ${amlogic_api} | grep "browser_download_url" | grep -oE "https.*${amlogic_xmm}.*.ipk" | head -n 1)"
    #wget -q ${amlogic_xmm_down} -O packages/${amlogic_xmm_down##*/}
    [[ "${?}" -eq "0" ]] && echo -e "${INFO} The [ ${amlogic_xmm} ] is downloaded successfully."
    #   
    #amlogic_atinout="atinout"
    #amlogic_atinout_down="$(curl -s ${amlogic_api} | grep "browser_download_url" | grep -oE "https.*${amlogic_atinout}.*.ipk" | head -n 1)"
    #wget -q ${amlogic_atinout_down} -O packages/${amlogic_atinout_down##*/}
    [[ "${?}" -eq "0" ]] && echo -e "${INFO} The [ ${amlogic_atinout} ] is downloaded successfully."
    #
    #amlogic_modem="modeminfo"
    #amlogic_modem_down="$(curl -s ${amlogic_api} | grep "browser_download_url" | grep -oE "https.*${amlogic_modem}.*.ipk" | head -n 1)"
    #wget -q ${amlogic_modem_down} -O packages/${amlogic_modem_down##*/}
    [[ "${?}" -eq "0" ]] && echo -e "${INFO} The [ ${amlogic_modem} ] is downloaded successfully."
    #
    #amlogic_luci_app_modeminfo="luci-app-modeminfo"
    #amlogic_luci_modem_down="$(curl -s ${amlogic_api} | grep "browser_download_url" | grep -oE "https.*${amlogic_luci_app_modeminfo}.*.ipk" | head -n 1)"
    #wget -q ${amlogic_luci_modem_down} -O packages/${amlogic_luci_modem_down##*/}
    [[ "${?}" -eq "0" ]] && echo -e "${INFO} The [ ${amlogic_luci_app_modeminfo} ] is downloaded successfully."
    #
    #amlogic_xmm="modeminfo-serial-xmm"
    #amlogic_xmm_down="$(curl -s ${amlogic_api} | grep "browser_download_url" | grep -oE "https.*${amlogic_xmm}.*.ipk" | head -n 1)"
    #wget -q ${amlogic_xmm_down} -O packages/${amlogic_xmm_down##*/}
    [[ "${?}" -eq "0" ]] && echo -e "${INFO} The [ ${amlogic_xmm} ] is downloaded successfully."
    #
    #amlogic_fibocom="modeminfo-serial-fibocom"
    #amlogic_fibocom_down="$(curl -s ${amlogic_api} | grep "browser_download_url" | grep -oE "https.*${amlogic_fibocom}.*.ipk" | head -n 1)"
    #wget -q ${amlogic_fibocom_down} -O packages/${amlogic_fibocom_down##*/}
    [[ "${?}" -eq "0" ]] && echo -e "${INFO} The [ ${amlogic_fibocom} ] is downloaded successfully."
    
    # Download other luci-app-xxx
    # ......

    sync && sleep 3
    echo -e "${INFO} [ packages ] directory status: $(ls packages -l 2>/dev/null)"
}

# Add custom packages, lib, theme, app and i18n, etc.
custom_config() {
    cd ${imagebuilder_path}
    echo -e "${STEPS} Start adding custom config..."

    config_list=""
    if [[ -s "${custom_config_file}" ]]; then
        config_list="$(cat ${custom_config_file} 2>/dev/null | grep -E "^CONFIG_PACKAGE_.*=y" | sed -e 's/CONFIG_PACKAGE_//g' -e 's/=y//g' -e 's/[ ][ ]*//g' | tr '\n' ' ')"
        echo -e "${INFO} Custom config list: \n$(echo "${config_list}" | tr ' ' '\n')"
    else
        echo -e "${INFO} No custom config was added."
    fi
}

# Add custom files
# The FILES variable allows custom configuration files to be included in images built with Image Builder.
# The [ files ] directory should be placed in the Image Builder root directory where you issue the make command.
custom_files() {
    cd ${imagebuilder_path}
    echo -e "${STEPS} Start adding custom files..."

    if [[ -d "${custom_files_path}" ]]; then
        # Copy custom files
        [[ -d "files" ]] || mkdir -p files
        cp -rf ${custom_files_path}/* files

        sync && sleep 3
        echo -e "${INFO} [ files ] directory status: $(ls files -l 2>/dev/null)"
    else
        echo -e "${INFO} No customized files were added."
    fi
}

# Rebuild OpenWrt firmware
rebuild_firmware() {
    cd ${imagebuilder_path}
    echo -e "${STEPS} Start building OpenWrt with Image Builder..."

    # Selecting default packages, lib, theme, app and i18n, etc.
    # sorting by https://build.moz.one
    my_packages="\
        acpid attr base-files bash bc bind-server blkid block-mount blockd bsdtar  \
        btrfs-progs busybox bzip2 cgi-io chattr comgt comgt-ncm coremark  \
        coreutils coreutils-base64 coreutils-nohup coreutils-truncate curl docker  \
        kmod-usb-net-rndis dosfstools dumpe2fs e2freefrag e2fsprogs exfat-mkfs  \
        f2fs-tools f2fsck fdisk gawk getopt gzip hostapd-common iconv iw iwinfo jq jshn  \
        kmod-brcmfmac kmod-brcmutil kmod-cfg80211 kmod-mac80211 libjson-script  \
        liblucihttp liblucihttp-lua libnetwork losetup lsattr lsblk lscpu mkf2fs  \
        mount-utils openssl-util parted perl-http-date perlbase-file perlbase-getopt  \
        perlbase-time perlbase-unicode perlbase-utf8 pigz ppp ppp-mod-pppoe  \
        proto-bonding pv rename resize2fs runc subversion-client subversion-libs tar  \
        tini ttyd tune2fs uclient-fetch uhttpd uhttpd-mod-ubus unzip uqmi usb-modeswitch  \
        uuidgen wget-ssl whereis which wpad-basic wwan xfs-fsck xfs-mkfs xz  \
        xz-utils ziptool zoneinfo-asia zoneinfo-core zstd  \
        \
        luci luci-base luci-compat luci-i18n-base-en luci-lib-base  \
        luci-lib-ip luci-lib-ipkg luci-lib-jsonc luci-lib-nixio  \
        luci-mod-admin-full luci-mod-network luci-mod-status luci-mod-system  \
        luci-proto-3g luci-proto-bonding luci-proto-ipip luci-proto-ipv6 luci-proto-ncm  \
        luci-proto-openconnect luci-proto-ppp luci-proto-qmi luci-proto-relay  \
        luci-app-modeminfo openssh-sftp-server luci-app-openclash \
        luci-app-amlogic xmm-modem modeminfo-serial-xmm \
        luci-app-passwall atinout modeminfo-serial-fibocom \
        kmod-usb-net-rndis -luci-app-turboacc \
        ${config_list} \
        "

    # Rebuild firmware
    make image PROFILE="Default" PACKAGES="${my_packages}" FILES="files"

    sync && sleep 3
    echo -e "${INFO} [ openwrt/bin/targets/armvirt/64 ] directory status: $(ls bin/targets/*/* -l 2>/dev/null)"
    echo -e "${SUCCESS} The rebuild is successful, the current path: [ ${PWD} ]"
}

# Show welcome message
echo -e "${STEPS} Welcome to Rebuild OpenWrt Using the Image Builder."
[[ -x "${0}" ]] || error_msg "Please give the script permission to run: [ chmod +x ${0} ]"
[[ -z "${1}" ]] && error_msg "Please specify the OpenWrt Branch, such as [ ${0} 21.02.3 ]"
rebuild_branch="${1}"
echo -e "${INFO} Rebuild path: [ ${PWD} ]"
echo -e "${INFO} Rebuild branch: [ ${rebuild_branch} ]"
#
# Perform related operations
download_imagebuilder
adjust_settings
custom_packages
custom_config
custom_files
rebuild_firmware
#
# Show server end information
echo -e "Server space usage after compilation: \n$(df -hT ${make_path}) \n"
# All process completed
wait