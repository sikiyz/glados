# GLaDOS 每日自动签到

自动签到 [GLaDOS](https://glados.network) 获取积分，延长账户有效期。

## 使用方法

### 1. 获取 Cookie

1. 浏览器登录 [glados.network](https://glados.network/console/checkin)
2. `F12` → `Application` → `Cookies` → `https://glados.network`
3. 复制 `koa:sess` 和 `koa:sess.sig` 的值
4. 拼接：`koa:sess=你的值;koa:sess.sig=你的值`

### 2. 在 VPS 上部署

```bash
# clone
git clone https://github.com/你的用户名/glados-checkin.git
cd glados-checkin
chmod +x glados_checkin.sh

# 测试运行
GLA_COOKIE="koa:sess=xxx;koa:sess.sig=xxx" ./glados_checkin.sh

# 设置 cron（每天北京时间 05:00 / UTC 21:00）
crontab -e
```

添加一行：

```cron
0 21 * * * GLA_COOKIE="koa:sess=xxx;koa:sess.sig=xxx" /root/glados-checkin/glados_checkin.sh
```

### 3. 更新脚本

```bash
cd glados-checkin && git pull
```

## 环境变量

| 变量 | 必填 | 默认值 | 说明 |
|------|------|--------|------|
| `GLA_COOKIE` | ✅ | - | GLaDOS 登录 Cookie |
| `GLA_LOG_FILE` | ❌ | `/var/log/glados_checkin.log` | 日志文件路径 |
| `GLA_RANDOM_DELAY` | ❌ | `3600` | 随机延迟上限(秒)，设 0 禁用 |

## 注意事项

- Cookie 有效期约 1~2 个月，过期后需重新获取
- 建议定时检查签到日志，发现失败及时更新 Cookie
- 本脚本仅供个人使用，请遵守 GLaDOS 服务条款
