# RustScan OpenWrt 部署指南

## 📋 概述

本指南详细说明如何在OpenWrt系统中编译、安装和配置RustScan端口扫描器。

> 🚧 **重要提示**: LuCI Web界面目前尚在开发中（WIP），存在JavaScript绑定错误。  
> 推荐优先使用命令行版本，功能完整且稳定。

## 🔧 编译环境要求

### 系统要求
- OpenWrt构建环境（ImmortalWrt 24.10或更高版本）
- Rust工具链支持
- 至少4GB可用磁盘空间
- 2GB以上内存

### 依赖包
```bash
# 确保feeds已更新
./scripts/feeds update -a
./scripts/feeds install -a

# 安装Rust支持
./scripts/feeds install rust
```

## 📦 包结构

```
rustscan/
├── Makefile                    # 主构建文件
├── README.md                   # 项目说明
├── DEPLOYMENT_GUIDE.md         # 本部署指南
├── files/                      # 配置文件
│   ├── rustscan.config         # UCI配置
│   ├── rustscan.init           # 系统服务脚本
│   └── rustscan.toml           # 默认TOML配置
└── patches/                    # 源码补丁
    └── 001-openwrt-config-path.patch

luci-app-rustscan/              # LuCI Web界面 🚧 WIP
├── Makefile
├── htdocs/luci-static/resources/view/rustscan/
├── root/usr/share/luci/menu.d/
├── root/usr/share/rpcd/acl.d/
└── po/zh_Hans/
```

## 🚀 编译步骤

### 重要说明

⚠️ **路径说明**: 本指南中使用 `package/path/to/rustscan/` 作为示例路径。请根据你的实际情况调整：

```bash
# 查找包的实际位置
find package/ -name "rustscan" -type d
find package/ -name "luci-app-rustscan" -type d

# 或查找包含相关包名的Makefile
find package/ -name "Makefile" -exec grep -l "PKG_NAME.*rustscan" {} \;
```

常见路径示例：
- `package/feeds/packages/rustscan/` - 如果在官方feeds中
- `package/custom/rustscan/` - 如果在自定义目录
- `package/rustscan/` - 如果直接在package目录
- `package/Applications/Zag/rustscan/` - 特定用户环境示例

### 1. 配置构建选项
```bash
# 进入OpenWrt根目录
cd /path/to/openwrt

# 配置内核和包
make menuconfig

# 选择以下选项：
# Languages → Rust → rust (host)
# Network → Network Scanners → rustscan
# LuCI → Applications → luci-app-rustscan  # 🚧 WIP - 暂未完成
```

### 2. 编译RustScan核心包
```bash
# 注意：请根据你的实际包路径调整以下命令

# 查找rustscan包的位置
find package/ -name "rustscan" -type d

# 清理之前的构建
make package/path/to/rustscan/clean

# 编译包（详细输出）
make package/path/to/rustscan/compile V=s

# 或使用并行编译加速
make package/path/to/rustscan/compile -j$(nproc)

# 检查编译结果
ls bin/packages/*/base/rustscan-*.apk

# 常见路径示例：
# make package/feeds/packages/rustscan/compile    # feeds中
# make package/custom/rustscan/compile            # 自定义目录
# make package/rustscan/compile                   # package目录
```

### 3. 编译LuCI界面（可选）🚧 **WIP - 开发中**
```bash
# 编译LuCI应用（请根据实际路径调整）
# ⚠️ 注意：LuCI界面目前尚未完成，存在JavaScript绑定错误
make package/path/to/luci-app-rustscan/compile V=s

# 检查结果
ls bin/packages/*/luci/luci-app-rustscan*.apk

# 推荐：目前优先使用命令行版本，LuCI界面正在修复中
```

## 📱 安装部署

### 1. 传输到目标设备
```bash
# 将IPK包传输到路由器
scp bin/packages/*/base/rustscan-*.apk root@192.168.1.1:/tmp/
# scp bin/packages/*/luci/luci-app-rustscan*.apk root@192.168.1.1:/tmp/  # 🚧 WIP
```

### 2. 在目标设备上安装
```bash
# SSH登录到路由器
ssh root@192.168.1.1

# 安装核心包
apk add --allow-untrusted /tmp/rustscan-*.apk

# 安装LuCI界面（可选）🚧 WIP - 暂不推荐
# apk add --allow-untrusted /tmp/luci-app-rustscan*.apk
# /etc/init.d/uhttpd restart

# 注意：目前建议只安装命令行版本，LuCI界面正在修复中
```

### 3. 基础配置
```bash
# 启用服务
uci set rustscan.config.enabled='1'
uci commit rustscan

# 启动服务
/etc/init.d/rustscan start

# 设置开机自启
/etc/init.d/rustscan enable
```

## 🎯 使用方法

### 命令行使用
```bash
# 基本扫描
rustscan -a 192.168.1.1

# 扫描特定端口
rustscan -a 192.168.1.1 -p 22,80,443

# 扫描网段
rustscan -a 192.168.1.0/24

# 使用配置文件
rustscan --config-path /etc/rustscan/rustscan.toml -a 192.168.1.1

# 嵌入式模式（低资源使用）
rustscan --embedded -a 192.168.1.1

# 详细输出
rustscan -a 192.168.1.1 --verbose
```

### Web界面使用
1. 访问路由器管理界面
2. 导航到 **服务 → RustScan**
3. 配置扫描参数
4. 执行快速扫描或使用高级功能

## ⚙️ 配置调优

### 针对不同设备的优化

#### 高端路由器 (>512MB RAM)
```bash
uci set rustscan.config.batch_size='4500'
uci set rustscan.config.timeout='1000'
uci set rustscan.config.ulimit='8000'
uci commit rustscan
```

#### 中端路由器 (256-512MB RAM)
```bash
uci set rustscan.config.batch_size='2000'
uci set rustscan.config.timeout='1500'
uci set rustscan.config.ulimit='5000'
uci commit rustscan
```

#### 低端路由器 (<256MB RAM)
```bash
uci set rustscan.config.batch_size='1000'
uci set rustscan.config.timeout='3000'
uci set rustscan.config.ulimit='3000'
uci commit rustscan
```

### 网络环境优化

#### 局域网扫描
```bash
uci set rustscan.config.timeout='1000'
uci set rustscan.config.tries='1'
```

#### 广域网扫描
```bash
uci set rustscan.config.timeout='5000'
uci set rustscan.config.tries='3'
```

## 🐛 故障排除

### 常见问题

#### 1. 编译失败
```bash
# 检查Rust工具链
rustc --version

# 清理并重新编译（请根据实际路径调整）
make package/path/to/rustscan/clean
make package/path/to/rustscan/compile V=s
```

#### 2. 运行时错误
```bash
# 检查配置文件
cat /etc/config/rustscan

# 查看系统日志
logread | grep rustscan

# 检查文件权限
ls -la /usr/bin/rustscan
ls -la /etc/rustscan/
```

#### 3. 性能问题
```bash
# 监控资源使用
top
free
df -h

# 调整配置参数
uci set rustscan.config.batch_size='1000'
uci commit rustscan
```

#### 4. Web界面无法访问 🚧 **WIP - 已知问题**
```bash
# ⚠️ 注意：LuCI界面目前存在JavaScript绑定错误，正在修复中
# 问题："Bind must be called on a function" TypeError

# 临时解决方案：优先使用命令行版本
# rustscan -a 192.168.1.1 --greppable

# 如果必须使用Web界面：
# /etc/init.d/uhttpd restart
# ls -la /usr/share/rpcd/acl.d/luci-app-rustscan.json
# 清除浏览器缓存
```

### 调试模式
```bash
# 启用详细日志
rustscan -a 192.168.1.1 --verbose

# 检查配置
rustscan --help

# 测试连接
rustscan -a 127.0.0.1 -p 22
```

## 📊 性能基准

### 预期性能指标

| 设备类型 | RAM | 扫描速度 | 资源占用 |
|----------|-----|----------|----------|
| 高端路由器 | >512MB | 1000端口/秒 | 30-50MB |
| 中端路由器 | 256-512MB | 500端口/秒 | 20-30MB |
| 低端路由器 | <256MB | 200端口/秒 | 10-20MB |

### 优化建议
- 根据设备性能调整`batch_size`
- 在低端设备上使用`--embedded`模式
- 避免同时扫描大量目标
- 定期清理日志文件

## 🔒 安全考虑

### 使用建议
- 仅在授权网络中使用
- 避免扫描外部网络
- 定期更新到最新版本
- 监控扫描日志

### 权限控制
- 默认仅root用户可执行
- Web界面需要管理员权限
- 可通过UCI配置访问控制

## 📝 更新维护

### 版本更新
```bash
# 检查新版本
# 下载新的源码包
# 重新编译和安装

# 备份配置
cp /etc/config/rustscan /tmp/rustscan.backup

# 安装新版本
opkg install --force-reinstall /tmp/rustscan_new.ipk

# 恢复配置
cp /tmp/rustscan.backup /etc/config/rustscan
```

### 日常维护
```bash
# 清理日志
logread -c

# 检查磁盘空间
df -h

# 更新配置
uci commit rustscan
```

## 📞 支持

### 获取帮助
- 查看README.md了解基本使用
- 运行`rustscan --help`查看命令选项
- 检查系统日志排查问题
- 参考上游项目文档

### 报告问题
请提供以下信息：
- OpenWrt版本和架构
- 设备型号和规格
- 错误日志和配置文件
- 复现步骤

---

## 版本信息

- **RustScan版本**: 2.4.1
- **文档版本**: v2.4.1-openwrt-1
- **维护者**: ntbowen <https://github.com/ntbowen>
- **更新时间**: 2025-08-07

**注意**: 本指南基于ImmortalWrt 24.10环境编写，其他OpenWrt版本可能需要适当调整。
