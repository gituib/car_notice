#!/bin/bash

# 停车通知系统一键部署脚本
# 部署前端到 Nginx，后端作为独立服务运行

set -e

echo "========================================"
echo "停车通知系统一键部署脚本"
echo "========================================"

# 1. 安装必要的依赖
echo "\n1. 安装必要的依赖..."
sudo apt update
sudo apt install -y nginx python3 python3-pip python3-venv

# 2. 创建并激活虚拟环境
echo "\n2. 创建并激活虚拟环境..."
cd "$(dirname "$0")/backend"
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
sudo cat > $NGINX_CONF << 'EOF'
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
sudo ln -sf $NGINX_CONF $NGINX_LINK

# 测试 Nginx 配置
sudo nginx -t

# 重启 Nginx
sudo systemctl restart nginx

# 6. 部署前端静态文件
echo "\n6. 部署前端静态文件..."
FRONTEND_DIR="/var/www/parking-notify"
sudo mkdir -p $FRONTEND_DIR
sudo cp -r "$(dirname "$0")/frontend/templates/"* $FRONTEND_DIR/
sudo cp -r "$(dirname "$0")/frontend/public/" $FRONTEND_DIR/
sudo chown -R www-data:www-data $FRONTEND_DIR

# 7. 启动后端服务
echo "\n7. 启动后端服务..."
# 创建 systemd 服务文件
SERVICE_FILE="/etc/systemd/system/parking-notify.service"
sudo cat > $SERVICE_FILE << 'EOF'
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
sudo mkdir -p /var/www/parking-notify/backend
sudo cp -r "$(dirname "$0")/backend/"* /var/www/parking-notify/backend/

# 重新加载 systemd 配置
sudo systemctl daemon-reload
# 启动服务
sudo systemctl start parking-notify.service
# 设置开机自启
sudo systemctl enable parking-notify.service

# 8. 检查服务状态
echo "\n8. 检查服务状态..."
sleep 3
sudo systemctl status parking-notify.service --no-pager
sudo systemctl status nginx --no-pager

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
