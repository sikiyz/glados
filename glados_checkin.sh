#!/bin/bash
#
# GLaDOS 每日自动签到脚本
# https://glados.network
#
# 使用方法:
#   1. 设置环境变量: export GLA_COOKIE="你的cookie"
#   2. 运行: ./glados_checkin.sh
#
# Cookie 获取:
#   1. 浏览器登录 https://glados.network
#   2. F12 → Application → Cookies → 复制 koa:sess 和 koa:sess.sig 的值
#   3. 拼接为: "koa:sess=xxx;koa:sess.sig=xxx"
#
# GitHub Actions / Cron 用法:
#   设置 Secret GLA_COOKIE，workflow 中:
#   env:
#     GLA_COOKIE: ${{ secrets.GLA_COOKIE }}
#

set -euo pipefail

# ========== 配置 ==========
COOKIE="${GLA_COOKIE:?错误: 请设置环境变量 GLA_COOKIE，内容为 koa:sess=xxx;koa:sess.sig=xxx}"
CHECKIN_URL="https://glados.network/api/user/checkin"
STATUS_URL="https://glados.network/api/user/status"
LOG_FILE="${GLA_LOG_FILE:-/var/log/glados_checkin.log}"
RANDOM_DELAY_MAX="${GLA_RANDOM_DELAY:-3600}"  # 随机延迟上限(秒)，默认1小时，设0禁用
# ===========================

# 随机延迟（避免所有人同一时间签到）
if [ "$RANDOM_DELAY_MAX" -gt 0 ]; then
    RANDOM_DELAY=$((RANDOM % RANDOM_DELAY_MAX))
    echo "随机延迟 ${RANDOM_DELAY} 秒..."
    sleep "${RANDOM_DELAY}"
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# ===== 签到 =====
CHECKIN_RESP=$(curl -s -X POST \
    -H "Cookie: ${COOKIE}" \
    -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
    -H "Content-Type: application/json" \
    -H "Origin: https://glados.network" \
    -H "Referer: https://glados.network/console/checkin" \
    "${CHECKIN_URL}" 2>&1)

echo "签到响应: ${CHECKIN_RESP}"

# 提取签到结果
CHECKIN_MSG=$(echo "${CHECKIN_RESP}" | grep -oE '"message":"[^"]*"' | head -1 | sed 's/"message":"//;s/"//')
POINTS=$(echo "${CHECKIN_RESP}" | grep -oE '"change":"[0-9.]+"' | grep -oE '[0-9.]+' | head -1)
[ -z "${POINTS:-}" ] && POINTS="0"

# ===== 查询账户状态 =====
STATUS_RESP=$(curl -s \
    -H "Cookie: ${COOKIE}" \
    -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
    "${STATUS_URL}" 2>&1)

echo "状态响应: ${STATUS_RESP}"

# 提取到期时间
EXPIRE=$(echo "${STATUS_RESP}" | grep -oE '"vip expire":"[^"]*"' | head -1 | sed 's/"vip expire":"//;s/"//')
LEFT=$(echo "${STATUS_RESP}" | grep -oE '"leftDays":"[^"]*"' | head -1 | sed 's/"leftDays":"//;s/"//')

# ===== 记录日志 =====
LOG_LINE="[${TIMESTAMP}] 签到: ${CHECKIN_MSG:-未知} | 积分: +${POINTS} | 剩余: ${LEFT:-?}天 | 到期: ${EXPIRE:-?}"
echo "${LOG_LINE}" >> "${LOG_FILE}"
echo "${LOG_LINE}"

# 判断成功/失败
if echo "${CHECKIN_RESP}" | grep -q '"code":0'; then
    echo "✅ 签到成功！"
    exit 0
else
    echo "❌ 签到失败，可能 Cookie 已过期，请重新获取。"
    exit 1
fi
