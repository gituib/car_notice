from flask import request, jsonify
from ..crypto.encryptor import encryptor
from ..qrcode.generator import qr_generator
from ..notifiers.manager import notifier_manager
import time


def generate_qrcode():
    """生成二维码
    
    请求体：
    {
        "notification_config": {
            "dingtalk": "webhook_url",
            "feishu": "webhook_url",
            "wechat": "webhook_url",
            "email": "email_address",
            "sms": "phone_number"
        },
        "message": "自定义通知内容",
        "qrcode_config": {
            "color": "#000000",
            "background": "#FFFFFF"
        }
    }
    
    响应：
    {
        "success": true,
        "qrcode": "data:image/png;base64,..."
    }
    """
    try:
        # 获取请求数据
        data = request.get_json()
        
        # 提取配置
        notification_config = data.get('notification_config', {})
        message = data.get('message', '有人需要您移车，请尽快处理')
        qrcode_config = data.get('qrcode_config', {})
        
        # 构建加密数据
        encrypted_data = {
            'notification_config': notification_config,
            'message': message,
            'timestamp': int(time.time())
        }
        
        # 加密数据
        encrypted_str = encryptor.encrypt(encrypted_data)
        
        # 生成二维码
        qrcode_data = qr_generator.generate(
            encrypted_str,
            color=qrcode_config.get('color', '#000000'),
            background=qrcode_config.get('background', '#FFFFFF')
        )
        
        # 返回响应
        return jsonify({
            'success': True,
            'qrcode': qrcode_data
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400


def send_notification():
    """发送通知
    
    请求体：
    {
        "encrypted_data": "加密的数据",
        "message": "扫码者输入的留言（可选）"
    }
    
    响应：
    {
        "success": true,
        "results": {
            "dingtalk": true,
            "feishu": true
        }
    }
    """
    try:
        # 获取请求数据
        data = request.get_json()
        encrypted_data = data.get('encrypted_data')
        user_message = data.get('message', '')
        
        # 解密数据
        decrypted_data = encryptor.decrypt(encrypted_data)
        
        # 提取配置
        notification_config = decrypted_data.get('notification_config', {})
        base_message = decrypted_data.get('message', '有人需要您移车，请尽快处理')
        
        # 构建最终消息
        if user_message:
            final_message = f"{base_message}\n\n留言：{user_message}"
        else:
            final_message = base_message
        
        # 发送通知
        results = notifier_manager.send_notification(notification_config, final_message)
        
        # 检查是否至少有一个通知成功
        success = any(results.values())
        
        # 返回响应
        return jsonify({
            'success': success,
            'results': results
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400


def health_check():
    """健康检查
    
    响应：
    {
        "status": "ok"
    }
    """
    return jsonify({'status': 'ok'})
