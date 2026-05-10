#!/usr/bin/env bash
# deploy_to_ucloud_hk.sh
# 把 /tmp 下一个 HTML 部署到 <your-host-alias> (<your-server-ip>) 公网,通过 nginx /路径 暴露。
#
# 用法:
#   ./deploy_to_ucloud_hk.sh <topic> [local_html_path]
#
# 例:
#   ./deploy_to_ucloud_hk.sh nslb /tmp/nslb_intro.html
#   → 公网地址: http://<your-server-ip>/nslb/
#
# 前置:
#   - ssh <your-host-alias> 已配置(~/.ssh/config 有 Host <your-host-alias>)
#   - sudo 密码 = "<your-sudo-password>"(需用户在 CLAUDE.md 中提供)
#   - <existing-site> 站点 server_name 含 IP <your-server-ip>,可借道注入 location
#
# 关键坑(全踩过):
#   1. 云安全组只开 80/443/3000/8045/12345 等业务端口,8765 BLOCKED
#   2. server_name 冲突:多个 server 用同 IP,后加的会被 ignore
#   3. server-level return 404 短路 location 匹配,必须包进 location /
#   4. .bak 文件放 sites-enabled/ 会被加载导致 conflicting server name warn

set -e

TOPIC="${1:?用法: $0 <topic> [local_html_path]}"
LOCAL_HTML="${2:-/tmp/${TOPIC}_intro.html}"

if [[ ! -f "$LOCAL_HTML" ]]; then
  echo "错误:本地 HTML 不存在: $LOCAL_HTML" >&2
  exit 1
fi

REMOTE=<your-host-alias>
SUDOPW=1
SITE=/etc/nginx/sites-enabled/<existing-site>  # 借道 <existing-site> 站(80 端口本来 return 404)

echo "[1/4] 上传 HTML 到 $REMOTE..."
scp -q "$LOCAL_HTML" "$REMOTE:/tmp/${TOPIC}_index.html"

echo "[2/4] 部署到 /var/www/${TOPIC}/ + 注入 nginx location..."
ssh "$REMOTE" "echo '$SUDOPW' | sudo -S bash -c '
  set -e
  mkdir -p /var/www/${TOPIC}
  cp /tmp/${TOPIC}_index.html /var/www/${TOPIC}/index.html

  # 备份(放 sites-available 避免被 nginx 加载)
  cp $SITE /etc/nginx/sites-available/<existing-site>.bak.\$(date +%s)

  # 注入 location 到 80 server,同时把 server-level return 404 包进 location /
  python3 << PYEOF
import re
path = \"$SITE\"
with open(path) as f: s = f.read()

inject = \"\"\"
    location /${TOPIC}/ {
        alias /var/www/${TOPIC}/;
        index index.html;
    }
    location = /${TOPIC} { return 301 /${TOPIC}/; }
\"\"\"

# 已存在则跳过
if \"/${TOPIC}/\" not in s:
    # 在 listen 80 server block 的 return 404 之前注入
    s = re.sub(
        r\"(    listen 80;\n    server_name [^;]+;\n)(    return 404;|    location / \\{ return 404; \\})\",
        r\"\\1\" + inject + r\"\\2\", s, count=1
    )
    # 把 server-level return 404 包进 location /(若还没包过)
    s = s.replace(
        \"    return 404; # managed by Certbot\",
        \"    location / { return 404; }\"
    )
    with open(path, \"w\") as f: f.write(s)
    print(\"injected\")
else:
    print(\"already injected, skip nginx config change\")
PYEOF

  nginx -t && systemctl reload nginx
'"

echo "[3/4] 验证公网访问..."
sleep 1
status=$(env -u http_proxy -u https_proxy -u all_proxy curl -s -o /dev/null -w "%{http_code}" -m 5 "http://<your-server-ip>/${TOPIC}/")

echo "[4/4] 完成"
echo
if [[ "$status" == "200" ]]; then
  echo "  ✓ 公网地址: http://<your-server-ip>/${TOPIC}/"
else
  echo "  ✗ 公网状态码: $status (预期 200)"
  echo "    检查 ssh <your-host-alias> 'sudo nginx -t' 与 /etc/nginx/sites-enabled/<existing-site>"
  exit 1
fi
