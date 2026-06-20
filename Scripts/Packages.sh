#!/bin/bash

# =================================================================
# 安装和更新软件包通用函数
# 第5个参数传入需要清理的潜在冲突包名（支持空格分隔多个）
# =================================================================
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local PKG_LIST=("$PKG_NAME" $5)
	local REPO_NAME=${PKG_REPO#*/}

	echo " "

	# 在克隆前，深度遍历并删除官方 feeds 中可能引发同名冲突的旧目录
	for NAME in "${PKG_LIST[@]}"; do
		echo "Search directory: $NAME"
		local FOUND_DIRS=$(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" 2>/dev/null)

		if [ -n "$FOUND_DIRS" ]; then
			while read -r DIR; do
				rm -rf "$DIR"
				echo "Delete directory: $DIR"
			done <<< "$FOUND_DIRS"
		else
			echo "Not found directory: $NAME"
		fi
	done

	# 克隆 GitHub 远程仓库最新源码
	git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

	# 处理克隆后的特殊仓库结构（大杂烩提取或规范重命名）
	if [[ "$PKG_SPECIAL" == "pkg" ]]; then
		find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
		rm -rf ./$REPO_NAME/
	elif [[ "$PKG_SPECIAL" == "name" ]]; then
		mv -f $REPO_NAME $PKG_NAME
	fi
}

# ==================== 自定义插件远程拉取列表 ====================

# 1. 精美主题系列
UPDATE_PACKAGE "argon" "kenzok8/small-package" "main" "pkg"

UPDATE_PACKAGE "aurora" "eamonxg/luci-theme-aurora" "master"
UPDATE_PACKAGE "aurora-config" "eamonxg/luci-app-aurora-config" "master"
UPDATE_PACKAGE "kucat" "sirpdboy/luci-theme-kucat" "master"
UPDATE_PACKAGE "kucat-config" "sirpdboy/luci-app-kucat-config" "master"

# 2. 科学与核心网络组件
UPDATE_PACKAGE "homeproxy" "VIKINGYFY/homeproxy" "main"
UPDATE_PACKAGE "momo" "nikkinikki-org/OpenWrt-momo" "main"
UPDATE_PACKAGE "nikki" "nikkinikki-org/OpenWrt-nikki" "main"

# 3. 核心更替：接入 kenzok8 的 daede 全家桶（包含 dae核心、daed核心、luci-app-daede面板）
UPDATE_PACKAGE "openwrt-daede" "kenzok8/openwrt-daede" "main" "name" "dae daed"

# 4. 常用工具与扩展组件
UPDATE_PACKAGE "ddns-go" "sirpdboy/luci-app-ddns-go" "main"
UPDATE_PACKAGE "diskman" "lisaac/luci-app-diskman" "master"
UPDATE_PACKAGE "easytier" "EasyTier/luci-app-easytier" "main"
UPDATE_PACKAGE "fancontrol" "rockjake/luci-app-fancontrol" "main"
UPDATE_PACKAGE "gecoosac" "openwrt-fork/openwrt-gecoosac" "main"
UPDATE_PACKAGE "openlist2" "sbwml/luci-app-openlist2" "main"
UPDATE_PACKAGE "partexp" "sirpdboy/luci-app-partexp" "main"
UPDATE_PACKAGE "qmodem" "FUjr/QModem" "main"
UPDATE_PACKAGE "quickfile" "sbwml/luci-app-quickfile" "main"
UPDATE_PACKAGE "vnt" "lmq8267/luci-app-vnt" "main"

# 5. 带有高级依赖或多重组件的复杂插件
UPDATE_PACKAGE "mosdns" "sbwml/luci-app-mosdns" "v5" "" "v2dat"
UPDATE_PACKAGE "qbittorrent" "sbwml/luci-app-qbittorrent" "master" "" "qt6base qt6tools rblibtorrent"
UPDATE_PACKAGE "viking" "VIKINGYFY/packages" "main" "" "luci-app-timewol luci-app-wolplus"
UPDATE_PACKAGE "luci-app-pushbot" "zzsj0928/luci-app-pushbot" "master"

# 🔥【全新修改】：切除第三方移植，完美引入 gdy666 官方原版 Lucky 大打包仓库
# 使用 "name" 将本地解压目录强制规范命名为 "lucky"，确保核心与 LuCI 依赖链天然对齐
UPDATE_PACKAGE "lucky" "gdy666/luci-app-lucky" "main" "name"

# 6. 远程拉取独立的高质量 Geodata 数据包组件，全面接管规则依赖
UPDATE_PACKAGE "v2ray-geodata" "sbwml/v2ray-geodata" "master"


# ==================== 官方 feeds 深度清理 ====================

# 强力刨除官方大底中残留的其余冲突网络插件
rm -rf ../feeds/luci/applications/luci-app-{passwall*,mosdns,dockerman,bypass*}
rm -rf ../feeds/packages/net/v2ray-geodata

echo "All remote packages configured successfully!"
