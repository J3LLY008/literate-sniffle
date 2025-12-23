#!/bin/bash

# KlipperScreen 关闭脚本
# 接收来自 Klipper 的参数

LOG_FILE="/tmp/klipperscreen_disable.log"
DEBUG_LOG="/tmp/klipper_debug.log"

# 记录调试信息
echo "==========================================" >> "$DEBUG_LOG"
echo "$(date '+%Y-%m-%d %H:%M:%S'): disable_klipperscreen.sh 开始执行" >> "$DEBUG_LOG"
echo "接收到的参数: $1" >> "$DEBUG_LOG"

# 从参数获取等待时间
WAIT_TIME=$1

# 验证等待时间
if ! [[ "$WAIT_TIME" =~ ^[0-9]+$ ]] || [ "$WAIT_TIME" -lt 1 ]; then
    WAIT_TIME=5
    echo "$(date '+%Y-%m-%d %H:%M:%S'): 参数无效，使用默认值: 5" >> "$DEBUG_LOG"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S'): 使用参数等待时间: $WAIT_TIME" >> "$DEBUG_LOG"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S'): 实际使用的等待时间: $WAIT_TIME 秒" >> "$DEBUG_LOG"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_message "脚本开始执行，等待时间: $WAIT_TIME 秒"

log_message "开始关闭 KlipperScreen，将在 ${WAIT_TIME} 秒后自动恢复"

# 停止 KlipperScreen 服务
log_message "停止 KlipperScreen 服务..."
if sudo systemctl stop klipperscreen.service; then
    log_message "KlipperScreen 已停止"
else
    log_message "停止 KlipperScreen 失败"
fi

# 在后台启动监控脚本
log_message "启动自动恢复监控..."
nohup bash /data/123/monitor_klipperscreen.sh "$WAIT_TIME" > /dev/null 2>&1 &

log_message "关闭流程完成，您可以在 ${WAIT_TIME} 秒内执行其他操作"
echo "$(date '+%Y-%m-%d %H:%M:%S'): disable_klipperscreen.sh 执行完成" >> "$DEBUG_LOG"