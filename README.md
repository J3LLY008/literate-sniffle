# KlipperScreen Manager

一个用于管理 KlipperScreen 的 Klipper 扩展，允许临时关闭屏幕并在指定时间后自动恢复，适合在需要执行归位、调平等操作时使用。

## 功能特点

- 🖥️ 一键关闭 KlipperScreen
- ⏱️ 可配置的自动恢复时间
- 🔄 后台自动监控和恢复
- 🚀 不影响其他打印操作
- 📝 完整的日志记录（存储在 `/tmp` 目录）
- ⚙️ 支持参数覆盖配置
- 🎯 智能监控：检测手动启动并提前退出
- 🔍 状态检查：定期检查服务状态

## 安装指南

### 1. 拉取脚本目录

```bash
cd /data
git clone https://cnb.cool/3dmellow/public/klipper-klipperscreen-manager
```

* 请注意下方代码中的`/data/klipper/klippy/extras`需要替换成实际路径，此路径只适合`fast`系统
```bash
curl -# -L --retry 3 --retry-delay 2 -o /data/klipper/klippy/extras/gcode_shell_command.py https://raw.githubusercontent.com/dw-0/kiauh/master/kiauh/extensions/gcode_shell_cmd/assets/gcode_shell_command.py
```

### 2. 安装脚本文件

```bash
cd /data/klipper-klipperscreen-manager
chmod +x /data/klipper-klipperscreen-manager/scripts/*.sh
```

### 3. 配置 Klipper

将 `config/klipper_macros.cfg` 中的内容添加到您的 `printer.cfg` 文件中，或者使用 include 语句：

```ini
[include klipper_macros.cfg]
```

## 使用方法

### 基本命令
* 使用默认等待时间（60秒）
```bash
RESTART_KLIpperSCREEN
```
* 使用指定等待时间
```bash
RESTART_KLIpperSCREEN TIME=120
```

* 手动立即启动 KlipperScreen
```bash
ENABLE_KLIpperSCREEN
```

### 工作流程

1. 执行 `RESTART_KLIpperSCREEN` 关闭 KlipperScreen
2. 在后台启动监控进程，定期检查服务状态
3. 如果在此期间手动执行 `ENABLE_KLIpperSCREEN`，监控进程会检测到并提前退出
4. 如果等待时间结束且 KlipperScreen 仍未启动，监控进程会自动启动它

## 配置说明

### 自定义默认等待时间

在 `klipper_macros.cfg` 中修改 `variable_time` 的值：

```ini
[gcode_macro RESTART_KLIpperSCREEN]
variable_time: 60  # 修改这个值来改变默认等待时间（秒）
```

### 参数说明

- `TIME`：可选的等待时间参数，单位为秒
- 有效范围：1-300 秒（5分钟）
- 如果未指定参数，使用配置的默认值

## 脚本说明

### disable_klipperscreen.sh

主关闭脚本，负责：
- 停止 KlipperScreen 服务
- 在后台启动监控脚本
- 记录详细的操作日志

### monitor_klipperscreen.sh

智能监控脚本，负责：
- 定期检查 KlipperScreen 状态（每2秒）
- 检测手动启动并提前退出
- 在指定时间后自动重新启动 KlipperScreen（如果未运行）

### enable_klipperscreen.sh

手动启动脚本，负责：
- 立即启动 KlipperScreen 服务

## 日志文件

所有日志文件存储在 `/tmp` 目录下，系统重启后会自动清理：

- `/tmp/klipperscreen_disable.log` - 关闭脚本日志
- `/tmp/klipperscreen_monitor.log` - 监控脚本日志  
- `/tmp/klipperscreen_enable.log` - 启动脚本日志
- `/tmp/klipper_debug.log` - 调试日志（所有脚本共用）

查看日志：
```bash
tail -f /tmp/klipper_debug.log
```

**注意**：由于日志存储在 `/tmp` 目录，系统重启后所有日志将被自动清除。

## 故障排除

### 常见问题

1. **脚本没有执行权限**
   ```bash
   sudo chmod +x /data/123/*.sh
   ```

2. **KlipperScreen 服务名称不正确**
   检查服务名称：
   ```bash
   sudo systemctl list-units | grep klipper
   ```

3. **日志文件权限问题**
   由于日志现在存储在 `/tmp` 目录，通常不会有权限问题。
   如果遇到问题，可以手动创建：
   ```bash
   sudo touch /tmp/klipperscreen_disable.log
   sudo touch /tmp/klipperscreen_monitor.log
   sudo touch /tmp/klipperscreen_enable.log
   sudo touch /tmp/klipper_debug.log
   sudo chmod 666 /tmp/klipperscreen_*.log /tmp/klipper_debug.log
   ```

4. **Klipper 配置错误**
   检查 Klipper 日志：
   ```bash
   sudo journalctl -u klipper -n 30
   ```

### 测试安装

```bash
# 测试关闭脚本（5秒后恢复）
/data/123/disable_klipperscreen.sh 5

# 测试启动脚本
/data/123/enable_klipperscreen.sh
```

## 文件结构

```
klipper-klipperscreen-manager/
├── README.md
├── scripts/
│   ├── disable_klipperscreen.sh
│   ├── monitor_klipperscreen.sh
│   └── enable_klipperscreen.sh
└── config/
    └── klipper_macros.cfg
```
## 更新日志

### v1.0.0
- 初始版本发布
- 实现基本关闭和自动恢复功能
- 添加智能监控和手动启动检测
- 所有日志存储在 `/tmp` 目录
- 完整的错误处理和日志记录

---

## 技术支持

如果您遇到问题，请：
1. 首先查看 `/tmp/klipper_debug.log` 中的详细日志
2. 检查 Klipper 服务状态：`sudo systemctl status klipper`
3. 检查 KlipperScreen 服务状态：`sudo systemctl status klipperscreen.service`

## 兼容性

- 支持 Klipper 所有版本
- 需要 systemd 系统
- 已在多种 Linux 发行版上测试

