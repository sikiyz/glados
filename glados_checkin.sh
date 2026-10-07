#!/bin/bash
set -euo pipefail

COOKIE="${GLA_COOKIE:?错误: 请设置环境变量 GLA_COOKIE}"
CHECKIN_URL="https://glados.network"
STATUS_URL="https://glados.network"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# ===== 执行签到 =====
CHECKIN_RESP=$(curl -s -X POST \
    -H "Cookie: ${COOKIE}" \
    -H "Content-Type: application/json" \
    -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
    "${CHECKIN_URL}" 2>&1)

echo "签到响应: ${CHECKIN_RESP}"

# ===== 查询账户状态 =====
STATUS_RESP=$(curl -s \
    -H "Cookie: ${COOKIE}" \
    -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
    "${STATUS_URL}" 2>&1)

echo "状态响应: ${STATUS_RESP}"

# ===== 更加健壮的数据解析 =====
if echo "${CHECKIN_RESP}" | grep -q '"code":0'; then
    POINTS=$(echo "${CHECKIN_RESP}" | grep -oE '"change":"[0-9.]+"' | head -1 | cut -d'"' -f4 || echo "0")
    LEFT_DAYS=$(echo "${STATUS_RESP}" | grep -oE '"leftDays":"[0-9.]+"' | head -1 | cut -d'"' -f4 | cut -d'.' -f1 || echo "未知")
    
    echo "[${TIMESTAMP}] ✅ 签到成功！获得积分: ${POINTS} | 剩余 VIP 天数: ${LEFT_DAYS} 天"
    exit 0
else
    echo "[${TIMESTAMP}] ❌ 签到失败，可能是 Cookie 失效或今日已签到。"
    exit 1
fi
