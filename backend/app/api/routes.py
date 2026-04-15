from flask import Blueprint
from .handlers import generate_qrcode, send_notification, health_check

# 创建蓝图
api_bp = Blueprint('api', __name__)

# 路由定义
api_bp.route('/generate', methods=['POST'])(generate_qrcode)
api_bp.route('/notify', methods=['POST'])(send_notification)
api_bp.route('/health', methods=['GET'])(health_check)
