import os
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

class Config:
    """系统配置类"""
    # 加密密钥
    SECRET_KEY = os.getenv('SECRET_KEY', 'your_default_secret_key')
    
    # 应用配置
    DEBUG = os.getenv('DEBUG', 'False').lower() == 'true'
    PORT = int(os.getenv('PORT', 5000))
    
    # 邮件配置
    EMAIL_HOST = os.getenv('EMAIL_HOST')
    EMAIL_PORT = int(os.getenv('EMAIL_PORT', 587))
    EMAIL_USERNAME = os.getenv('EMAIL_USERNAME')
    EMAIL_PASSWORD = os.getenv('EMAIL_PASSWORD')
    
    # 短信配置
    SMS_API_KEY = os.getenv('SMS_API_KEY')
    SMS_API_SECRET = os.getenv('SMS_API_SECRET')

# 创建配置实例
config = Config()
