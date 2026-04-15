import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from ..config.settings import config
from .base import BaseNotifier

class EmailNotifier(BaseNotifier):
    """邮件通知实现"""
    
    def send(self, message, to_email, **kwargs):
        """发送邮件通知
        
        Args:
            message: 通知内容
            to_email: 收件人邮箱
            **kwargs: 其他参数
            
        Returns:
            bool: 是否发送成功
        """
        try:
            # 检查邮件配置
            if not config.EMAIL_HOST or not config.EMAIL_USERNAME or not config.EMAIL_PASSWORD:
                print("邮件配置未设置")
                return False
            
            # 构建邮件
            msg = MIMEMultipart()
            msg['From'] = config.EMAIL_USERNAME
            msg['To'] = to_email
            msg['Subject'] = "停车通知"
            
            # 添加邮件正文
            msg.attach(MIMEText(message, 'plain', 'utf-8'))
            
            # 连接 SMTP 服务器
            with smtplib.SMTP(config.EMAIL_HOST, config.EMAIL_PORT) as server:
                server.starttls()
                server.login(config.EMAIL_USERNAME, config.EMAIL_PASSWORD)
                server.send_message(msg)
            
            return True
        except Exception as e:
            print(f"发送邮件通知失败: {e}")
            return False
