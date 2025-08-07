# RustScan for OpenWrt

RustScan的OpenWrt移植版本 - 现代化的端口扫描器

## 项目概述

RustScan是一个用Rust编写的现代化端口扫描器，比传统的nmap更快更高效。本包是针对OpenWrt嵌入式系统的优化移植版本。

## 特性

- 🚀 **高速扫描**: 比nmap快得多的端口扫描速度
- 🧠 **自适应学习**: 使用越多，性能越好
- 📜 **脚本支持**: 支持多种编程语言的脚本
- 🔧 **嵌入式优化**: 针对OpenWrt系统优化的资源使用
- 🌐 **跨平台**: 支持多种架构 (aarch64, arm, mips/mipsel, mips64/mips64el, x86_64, i386, riscv64, powerpc64)
- ⚡ **低资源占用**: 适合路由器等嵌入式设备

## 安装

### 编译安装
```bash
# 在OpenWrt构建环境中
# 注意：请根据你的实际包路径调整以下命令
make package/path/to/rustscan/compile V=s

# 或使用并行编译
make package/path/to/rustscan/compile -j$(nproc)

# 常见路径示例：
# make package/feeds/packages/rustscan/compile    # 如果在feeds中
# make package/custom/rustscan/compile            # 如果在自定义目录
# make package/rustscan/compile                   # 如果直接在package目录
```

#### 查找包路径
```bash
# 查找rustscan包的位置
find package/ -name "rustscan" -type d

# 或查找包含“rustscan”的Makefile
find package/ -name "Makefile" -exec grep -l "PKG_NAME.*rustscan" {} \;
```

### 配置
```bash
# 启用服务
uci set rustscan.config.enabled='1'
uci commit rustscan
/etc/init.d/rustscan start
```

## 使用方法

### 基本扫描
```bash
# 扫描单个主机的常用端口
rustscan -a 192.168.1.1

# 扫描IP段
rustscan -a 192.168.1.0/24

# 扫描特定端口
rustscan -a 192.168.1.1 -p 22,80,443,8080
```

### 高级选项
```bash
# 使用配置文件
rustscan --config-path /etc/rustscan/rustscan.toml -a 192.168.1.1

# 嵌入式模式（低资源使用）
rustscan --embedded -a 192.168.1.1

# OpenWrt优化模式
rustscan --openwrt -a 192.168.1.1

# 批量扫描（调整批次大小）
rustscan -a 192.168.1.1 -b 1000

# 设置超时时间
rustscan -a 192.168.1.1 -t 2000
```

### 扫描配置文件

系统提供了三种预设配置：

1. **快速扫描** (fast): 高速扫描常用端口
2. **全面扫描** (thorough): 扫描更多端口，更多重试
3. **隐蔽扫描** (stealth): 慢速扫描，避免被检测

## 配置文件

### UCI配置 (`/etc/config/rustscan`)
```
config rustscan 'config'
    option enabled '1'
    option batch_size '2000'
    option timeout '1500'
    option tries '1'
    option ulimit '5000'
    option top_ports '1000'
```

### TOML配置 (`/etc/rustscan/rustscan.toml`)
详细的配置选项，包括性能调优和网络设置。

## 性能调优

### 嵌入式系统优化
- `batch_size`: 建议设置为1000-2000（默认4500可能过高）
- `timeout`: 根据网络情况调整，建议1500-3000ms
- `ulimit`: 文件描述符限制，建议3000-5000
- `max_threads`: 线程数限制，建议2-4个

### 内存使用
- 典型内存占用: 10-30MB
- 峰值内存占用: 50-100MB（取决于扫描规模）

## 架构支持

- ✅ aarch64 (ARM64)
- ✅ mips (MIPS32)  
- ✅ arm (ARM32)
- ✅ x86_64

## 依赖

- Rust 1.70+（编译时）
- musl libc（运行时）
- 最小存储空间: ~5MB
- 最小内存: ~16MB

## 故障排除

### 常见问题

1. **权限错误**
   ```bash
   # 确保有网络扫描权限
   rustscan --accessible -a 192.168.1.1
   ```

2. **文件描述符不足**
   ```bash
   # 调整ulimit设置
   uci set rustscan.config.ulimit='3000'
   uci commit rustscan
   ```

3. **内存不足**
   ```bash
   # 使用嵌入式模式
   rustscan --embedded --batch-size 500 -a 192.168.1.1
   ```

### 调试模式
```bash
# 启用详细输出
rustscan -a 192.168.1.1 --verbose

# 检查配置
rustscan --help
```

## 开发信息

- **上游项目**: https://github.com/bee-san/RustScan
- **版本**: 2.4.1
- **许可证**: GPL-3.0
- **维护者**: ntbowen <https://github.com/ntbowen>

## 更新日志

### v2.4.1-openwrt-1
- 更新到RustScan 2.4.1（使用master分支获得真正的2.4.1版本）
- 修复版本号不匹配问题（tag中Cargo.toml版本号未更新）
- 优化配置文件路径为OpenWrt标准路径 `/etc/rustscan/rustscan.toml`
- 简化包结构，移除开发阶段的测试脚本
- 更新作者信息
- 嵌入式系统优化
- UCI配置集成
- 多架构支持

## 贡献

欢迎提交问题报告和改进建议到上游项目或本移植版本。

## 许可证

本项目遵循GPL-3.0许可证，与上游项目保持一致。
