import requests
from .base import BaseNotifier

class FeishuNotifier(BaseNotifier):
    """飞书通知实现"""
    
    def send(self, message, webhook_url, **kwargs):
        """发送飞书通知
        
        Args:
            message: 通知内容
            webhook_url: 飞书机器人 webhook URL
            **kwargs: 其他参数
            
        Returns:
            bool: 是否发送成功
        """
        try:
            # 构建请求数据
            data = {
                "msg_type": "text",
                "content": {
                    "text": message
                }
            }
            
            # 发送请求
            response = requests.post(webhook_url, json=data)
            
            # 检查响应
            if response.status_code == 200:
                result = response.json()
                return result.get('code') == 0
            return False
        except Exception as e:
            print(f"发送飞书通知失败: {e}")
            return False
