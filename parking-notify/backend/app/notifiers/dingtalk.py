import requests
from .base import BaseNotifier

class DingTalkNotifier(BaseNotifier):
    """钉钉通知实现"""
    
    def send(self, message, webhook_url, **kwargs):
        """发送钉钉通知
        
        Args:
            message: 通知内容
            webhook_url: 钉钉机器人 webhook URL
            **kwargs: 其他参数
            
        Returns:
            bool: 是否发送成功
        """
        try:
            # 构建请求数据
            data = {
                "msgtype": "text",
                "text": {
                    "content": message
                }
            }
            
            # 发送请求
            response = requests.post(webhook_url, json=data)
            
            # 检查响应
            if response.status_code == 200:
                result = response.json()
                return result.get('errcode') == 0
            return False
        except Exception as e:
            print(f"发送钉钉通知失败: {e}")
            return False
