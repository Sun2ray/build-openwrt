#!/bin/bash

# 1. 修改默认 IP 地址为 192.168.123.1
sed -i 's/192.168.1.1/192.168.123.1/g' package/base-files/files/bin/config_generate

# 2. 设置初始密码为 password (由 $1$V4UetPzk$G5oU395.E2f5W9.i9L555. 加密而来)
# 这行会替换原有 root 的密码占位符
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$G5oU395.E2f5W9.i9L555.:18881:0:99999:7:::/g' package/lean/default-settings/files/zzz-default-settings

# 3. 添加 OpenClash 插件源码
git clone --depth=1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# 4. 添加 Passwall 插件源码 (及依赖)
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages.git package/openwrt-passwall-packages
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall.git package/luci-app-passwall

# 5. 移除 Amlogic 相关的不必要脚本 (既然你是编译 AX6，可以清理掉你给出的脚本中 s9xxx 相关内容)
# 如果你不需要 amlogic 相关的菜单，可以删掉下面这行
# rm -rf package/luci-app-amlogic

# 6. 修正 autocore (可选)
sed -i 's/TARGET_rockchip/TARGET_rockchip\|\|TARGET_qualcommax/g' package/lean/autocore/Makefile
