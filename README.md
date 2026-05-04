

自动签到 [GLaDOS](https://glados.network) 获取积分，延长账户有效期。

两步就行：
在其他 VPS 上部署

# 拉取脚本
git clone https://github.com/你的用户名/glados-checkin.git
cd glados-checkin
chmod +x glados_checkin.sh

# 先手动跑一次确认能用
GLA_COOKIE="koa:sess=你的值;koa:sess.sig=你的值" ./glados_checkin.sh

# 没问题就加到 cron
crontab -e

加这一行（每天北京时间 05:00 执行）：

0 21 * * * GLA_COOKIE="koa:sess=你的值;koa:sess.sig=你的值" /root/glados-checkin/glados_checkin.sh

Cookie 去哪拿？浏览器登录 glados.network → F12 → Application → Cookies → 复制 koa:sess 和 koa:sess.sig 的值拼起来就行。
