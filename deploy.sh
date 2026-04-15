#!/bin/bash

# 停车通知系统一键部署脚本
# 部署前端到 Nginx，后端作为独立服务运行

set -e

echo "========================================"
echo "停车通知系统一键部署脚本"
echo "========================================"

# 1. 安装必要的依赖
echo "\n1. 安装必要的依赖..."
apt update

# 检查 Nginx 是否安装
if ! command -v nginx &> /dev/null; then
    echo "Nginx 未安装，正在安装..."
    apt install -y nginx
else
    echo "Nginx 已安装，跳过安装步骤"
fi

# 安装其他依赖
# 检查 Python 3 是否安装
if ! command -v python3 &> /dev/null; then
    echo "Python 3 未安装，正在安装..."
    apt install -y python3
else
    echo "Python 3 已安装，跳过安装步骤"
fi

# 检查 pip 是否安装
if ! command -v pip3 &> /dev/null; then
    echo "pip 未安装，正在安装..."
    apt install -y python3-pip
else
    echo "pip 已安装，跳过安装步骤"
fi

# 检查 python3-venv 是否安装
if ! dpkg -l | grep -q python3-venv; then
    echo "python3-venv 未安装，正在安装..."
    apt install -y python3-venv
else
    echo "python3-venv 已安装，跳过安装步骤"
fi

# 保存脚本所在目录
SCRIPT_DIR="$(dirname "$0")"

# 2. 创建并激活虚拟环境
echo "\n2. 创建并激活虚拟环境..."
cd "$SCRIPT_DIR/backend"
python3 -m venv venv
source venv/bin/activate

# 3. 安装 Python 依赖
echo "\n3. 安装 Python 依赖..."
pip install -r requirements.txt

# 4. 配置环境变量
echo "\n4. 配置环境变量..."
if [ ! -f .env ]; then
    cp .env.example .env
    # 生成随机 SECRET_KEY
    SECRET_KEY=$(openssl rand -hex 32)
    sed -i "s/your_secure_secret_key/$SECRET_KEY/g" .env
    echo "已创建 .env 文件并生成随机 SECRET_KEY"
else
    echo ".env 文件已存在，跳过配置"
fi

# 5. 配置 Nginx
echo "\n5. 配置 Nginx..."
NGINX_CONF="/etc/nginx/sites-available/parking-notify"
NGINX_LINK="/etc/nginx/sites-enabled/parking-notify"

# 创建 Nginx 配置文件
cat > $NGINX_CONF << 'EOF'
server {
    listen 80;
    server_name localhost;

    # 前端静态文件
    location / {
        root /var/www/parking-notify;
        index index.html;
        try_files $uri $uri/ =404;
    }

    # 后端 API 代理
    location /api {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# 创建符号链接
ln -sf $NGINX_CONF $NGINX_LINK

# 测试 Nginx 配置
nginx -t

# 重启 Nginx
systemctl restart nginx

# 6. 部署前端静态文件
echo "\n6. 部署前端静态文件..."
FRONTEND_DIR="/var/www/parking-notify"
mkdir -p $FRONTEND_DIR

# 检查前端目录是否存在
if [ ! -d "$SCRIPT_DIR/frontend" ]; then
    echo "错误：前端目录不存在，请检查目录结构"
    exit 1
fi

if [ ! -d "$SCRIPT_DIR/frontend/templates" ]; then
    echo "错误：前端模板目录不存在，请检查目录结构"
    exit 1
fi

if [ ! -d "$SCRIPT_DIR/frontend/public" ]; then
    echo "错误：前端静态资源目录不存在，请检查目录结构"
    exit 1
fi

# 复制前端文件
cp -r "$SCRIPT_DIR/frontend/templates"/* "$FRONTEND_DIR/"
cp -r "$SCRIPT_DIR/frontend/public" "$FRONTEND_DIR/"
chown -R www-data:www-data $FRONTEND_DIR

# 7. 启动后端服务
echo "\n7. 启动后端服务..."
# 创建 systemd 服务文件
SERVICE_FILE="/etc/systemd/system/parking-notify.service"
cat > $SERVICE_FILE << 'EOF'
[Unit]
Description=Parking Notify Backend Service
After=network.target

[Service]
User=root
WorkingDirectory=/var/www/parking-notify/backend
ExecStart=/var/www/parking-notify/backend/venv/bin/python run.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 复制后端文件到 /var/www
mkdir -p /var/www/parking-notify/backend
cp -r "$SCRIPT_DIR/backend/"* /var/www/parking-notify/backend/

# 重新加载 systemd 配置
systemctl daemon-reload
# 启动服务
systemctl start parking-notify.service
# 设置开机自启
systemctl enable parking-notify.service

# 8. 检查服务状态
echo "\n8. 检查服务状态..."
sleep 3
systemctl status parking-notify.service --no-pager
systemctl status nginx --no-pager

# 9. 显示部署结果
echo "\n========================================"
echo "部署完成！"
echo "========================================"
echo "前端地址: http://localhost"
echo "后端 API: http://localhost/api"
echo "健康检查: http://localhost/api/health"
echo "\n注意："
echo "1. 确保 80 端口和 5000 端口未被占用"
echo "2. 如需修改配置，请编辑 /etc/nginx/sites-available/parking-notify"
echo "3. 如需查看后端日志，请运行: sudo journalctl -u parking-notify.service"
echo "========================================"
