#!/bin/bash
# GLaDOS签到 - 每天5-6点随机

COOKIE="koa:sess=eyJ1c2VySWQiOjY5NjkxMCwiX2V4cGlyZSI6MTgwMDc5MzA4Mjc4MiwiX21heEFnZSI6MjU5MjAwMDAwMDB9;koa:sess.sig=m0KJaAPsBj84u3pp-xQpgME2XPk"
LOG_FILE="/var/log/glados_checkin.log"

# 随机延迟0-3600秒（5:00-6:00之间）
RANDOM_DELAY=$((RANDOM % 3600))
sleep ${RANDOM_DELAY}

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 签到
RESPONSE=$(curl -s -X POST -H "Cookie: ${COOKIE}" -H "User-Agent: Mozilla/5.0" \
    "https://glados.network/api/user/checkin" 2>&1)

# 提取积分
POINTS=$(echo "${RESPONSE}" | grep -oE '"change":"[0-9.]+"' | grep -oE '[0-9.]+' | head -1)
[ -z "$POINTS" ] && POINTS="0"

# 简洁记录
echo "[${TIMESTAMP}] GLaDOS: +${POINTS}" >> "${LOG_FILE}"
