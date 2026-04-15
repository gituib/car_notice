#!/bin/bash

# 停车通知系统更新脚本
# 用于拉取最新代码并重启服务

set -e

echo "========================================"
echo "停车通知系统更新脚本"
echo "========================================"

# 1. 拉取最新代码
echo "\n1. 拉取最新代码..."
git pull origin main

# 2. 更新 Python 依赖
echo "\n2. 更新 Python 依赖..."
cd backend
if [ -d "venv" ]; then
    source venv/bin/activate
    pip install -r requirements.txt
else
    echo "虚拟环境不存在，跳过依赖更新"
fi
cd ..

# 3. 重启 Nginx
echo "\n3. 重启 Nginx..."
systemctl restart nginx

# 4. 重启后端服务
echo "\n4. 重启后端服务..."
systemctl restart parking-notify.service

# 5. 检查服务状态
echo "\n5. 检查服务状态..."
sleep 3
systemctl status parking-notify.service --no-pager
systemctl status nginx --no-pager

# 6. 显示更新结果
echo "\n========================================"
echo "更新完成！"
echo "========================================"
echo "前端地址: http://localhost"
echo "后端 API: http://localhost/api"
echo "健康检查: http://localhost/api/health"
echo "========================================"
