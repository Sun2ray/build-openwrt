#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/immortalwrt/immortalwrt / Branch: master
#========================================================================================================================

# ------------------------------- Main source started -------------------------------
#
# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='immortalwrt'" >>package/base-files/files/etc/openwrt_release

# Modify default IP（FROM 192.168.1.1 CHANGE TO 192.168.31.4）
# sed -i 's/192.168.1.1/192.168.31.4/g' package/base-files/files/bin/config_generate
#
# ------------------------------- Main source ends -------------------------------

# ------------------------------- Other started -------------------------------
#
# Add luci-app-amlogic
svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic

# Apply patch
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Other ends -------------------------------
# 1. 修改路由器初始 IP 为 10.0.0.1
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 2. 设置初始密码为 root
# OpenWrt 密码使用 shadow 密文。'q7U64ifA$K86P19B86P19B86P19B86.' 是经过加密的 'root'
sed -i 's/root:::0:99999:7:::/root:\$1\$q7U64ifA\$K86P19B86P19B86P19B86.:18888:0:99999:7:::/g' package/base-files/files/etc/shadow

# 3. 定制初始无线配置 (红米 AX6 包含 2.4G 和 5G 两个 WiFi 芯片)
# 这里的配置会在系统首次启动并生成无线配置文件 /etc/config/wireless 时生效
mkdir -p package/base-files/files/etc/uci-defaults
cat << 'EOF' > package/base-files/files/etc/uci-defaults/99-custom-wifi
#!/bin/sh
uci batch <<UIEOF
  # 统一设置所有无线网络的 SSID 
  set wireless.default_radio0.ssid='AX6'
  set wireless.default_radio1.ssid='AX6'
  
  # 统一设置加密方式为 WPA2-PSK
  set wireless.default_radio0.encryption='psk2'
  set wireless.default_radio1.encryption='psk2'
  
  # 统一设置无线密码
  set wireless.default_radio0.key='12345678'
  set wireless.default_radio1.key='12345678'
  
  # 默认开启无线发射（部分源码默认禁用无线）
  set wireless.radio0.disabled='0'
  set wireless.radio1.disabled='0'
  
  commit wireless
UIEOF
exit 0
EOF
chmod +x package/base-files/files/etc/uci-defaults/99-custom-wifi

