#!/bin/bash

# 停车通知系统协助脚本
# 用于检查服务状态、查看日志等常见操作

set -e

echo "========================================"
echo "停车通知系统协助脚本"
echo "========================================"
echo "1. 检查服务状态"
echo "2. 查看后端日志"
echo "3. 查看 Nginx 日志"
echo "4. 检查端口占用"
echo "5. 测试健康检查接口"
echo "6. 重启服务"
echo "7. 退出"
echo "========================================"

read -p "请选择操作编号: " choice

echo ""

case $choice in
    1)
        echo "检查服务状态..."
        echo "========================================"
        sudo systemctl status parking-notify.service --no-pager
        echo "========================================"
        sudo systemctl status nginx --no-pager
        ;;
    2)
        echo "查看后端日志..."
        echo "========================================"
        sudo journalctl -u parking-notify.service -n 50 --no-pager
        ;;
    3)
        echo "查看 Nginx 日志..."
        echo "========================================"
        sudo tail -n 50 /var/log/nginx/error.log
        ;;
    4)
        echo "检查端口占用..."
        echo "========================================"
        sudo lsof -i :80
        echo "----------------------------------------"
        sudo lsof -i :5000
        ;;
    5)
        echo "测试健康检查接口..."
        echo "========================================"
        curl -v http://localhost/api/health
        ;;
    6)
        echo "重启服务..."
        echo "========================================"
        sudo systemctl restart parking-notify.service
        echo "后端服务已重启"
        sudo systemctl restart nginx
        echo "Nginx 已重启"
        sleep 2
        sudo systemctl status parking-notify.service --no-pager
        ;;
    7)
        echo "退出脚本"
        exit 0
        ;;
    *)
        echo "无效的选择"
        ;;
esac

echo ""
echo "========================================"
echo "操作完成！"
echo "========================================"
