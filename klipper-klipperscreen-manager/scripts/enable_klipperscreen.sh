#!/bin/bash

# KlipperScreen 手动启动脚本

LOG_FILE="/tmp/klipperscreen_enable.log"
DEBUG_LOG="/tmp/klipper_debug.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# 记录调试信息
echo "==========================================" >> "$DEBUG_LOG"
echo "$(date '+%Y-%m-%d %H:%M:%S'): enable_klipperscreen.sh 开始执行" >> "$DEBUG_LOG"

log_message "手动启动 KlipperScreen"

echo "$(date '+%Y-%m-%d %H:%M:%S'): 启动 KlipperScreen 服务..." >> "$DEBUG_LOG"

if sudo systemctl start klipperscreen.service; then
    log_message "KlipperScreen 启动成功"
    echo "$(date '+%Y-%m-%d %H:%M:%S'): KlipperScreen 启动成功" >> "$DEBUG_LOG"
    echo "KlipperScreen 已启动"
else
    log_message "KlipperScreen 启动失败"
    echo "$(date '+%Y-%m-%d %H:%M:%S'): KlipperScreen 启动失败" >> "$DEBUG_LOG"
    echo "KlipperScreen 启动失败"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S'): enable_klipperscreen.sh 执行完成" >> "$DEBUG_LOG"