from .dingtalk import DingTalkNotifier
from .feishu import FeishuNotifier
from .wechat import WeChatNotifier
from .email import EmailNotifier
from .sms import SMSNotifier

class NotifierManager:
    """通知管理器"""
    
    def __init__(self):
        """初始化通知管理器"""
        self.notifiers = {
            'dingtalk': DingTalkNotifier(),
            'feishu': FeishuNotifier(),
            'wechat': WeChatNotifier(),
            'email': EmailNotifier(),
            'sms': SMSNotifier()
        }
    
    def send_notification(self, notification_config, message):
        """发送通知
        
        Args:
            notification_config: 通知配置
            message: 通知内容
            
        Returns:
            dict: 发送结果
        """
        results = {}
        
        # 遍历所有通知方式
        for notify_type, config in notification_config.items():
            if config and notify_type in self.notifiers:
                notifier = self.notifiers[notify_type]
                # 根据通知类型调用相应的发送方法
                if notify_type == 'dingtalk' or notify_type == 'feishu' or notify_type == 'wechat':
                    success = notifier.send(message, webhook_url=config)
                elif notify_type == 'email':
                    success = notifier.send(message, to_email=config)
                elif notify_type == 'sms':
                    success = notifier.send(message, phone_number=config)
                else:
                    success = False
                
                results[notify_type] = success
        
        return results

# 创建通知管理器实例
notifier_manager = NotifierManager()
