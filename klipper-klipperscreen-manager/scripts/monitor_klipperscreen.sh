#!/bin/bash

# KlipperScreen 智能监控脚本

LOG_FILE="/tmp/klipperscreen_monitor.log"
DEBUG_LOG="/tmp/klipper_debug.log"
CHECK_INTERVAL=2  # 检查间隔（秒）

# 从参数获取等待时间
WAIT_TIME=$1

# 验证等待时间
if ! [[ "$WAIT_TIME" =~ ^[0-9]+$ ]] || [ "$WAIT_TIME" -lt 1 ]; then
    WAIT_TIME=5
fi

# 记录调试信息
echo "==========================================" >> "$DEBUG_LOG"
echo "$(date '+%Y-%m-%d %H:%M:%S'): monitor_klipperscreen.sh 开始执行" >> "$DEBUG_LOG"
echo "$(date '+%Y-%m-%d %H:%M:%S'): 监控等待时间: $WAIT_TIME 秒" >> "$DEBUG_LOG"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_message "监控脚本开始执行，等待时间: ${WAIT_TIME} 秒"

elapsed_time=0
klipperscreen_manually_started=false

log_message "开始智能监控 KlipperScreen 状态"

# 智能监控循环
while [ $elapsed_time -lt $WAIT_TIME ]; do
    # 检查 KlipperScreen 是否已经在运行
    if systemctl is-active --quiet klipperscreen.service; then
        log_message "检测到 KlipperScreen 已被手动启动（等待 ${elapsed_time} 秒后）"
        echo "$(date '+%Y-%m-%d %H:%M:%S'): KlipperScreen 已手动启动，监控提前结束" >> "$DEBUG_LOG"
        klipperscreen_manually_started=true
        break
    fi
    
    # 等待检查间隔
    sleep $CHECK_INTERVAL
    elapsed_time=$((elapsed_time + CHECK_INTERVAL))
    
    # 每10秒记录一次状态
    if [ $((elapsed_time % 10)) -eq 0 ]; then
        log_message "监控中... 已等待 ${elapsed_time}/${WAIT_TIME} 秒"
    fi
done

# 如果 KlipperScreen 没有被手动启动，且等待时间已到，则自动启动
if [ "$klipperscreen_manually_started" = false ]; then
    log_message "等待时间到，自动启动 KlipperScreen..."
    echo "$(date '+%Y-%m-%d %H:%M:%S'): 自动启动 KlipperScreen..." >> "$DEBUG_LOG"
    
    if sudo systemctl start klipperscreen.service; then
        log_message "KlipperScreen 自动启动成功"
        echo "$(date '+%Y-%m-%d %H:%M:%S'): KlipperScreen 自动启动成功" >> "$DEBUG_LOG"
    else
        log_message "KlipperScreen 自动启动失败"
        echo "$(date '+%Y-%m-%d %H:%M:%S'): KlipperScreen 自动启动失败" >> "$DEBUG_LOG"
    fi
else
    log_message "监控任务完成（KlipperScreen 已手动启动）"
    echo "$(date '+%Y-%m-%d %H:%M:%S'): 监控任务完成，KlipperScreen 已手动启动" >> "$DEBUG_LOG"
fi

log_message "监控脚本执行完成"
echo "$(date '+%Y-%m-%d %H:%M:%S'): monitor_klipperscreen.sh 执行完成" >> "$DEBUG_LOG"