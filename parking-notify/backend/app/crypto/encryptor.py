import base64
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import padding
import os
from ..config.settings import config

class Encryptor:
    """加密器类，用于加密和解密数据"""
    
    def __init__(self, key=None):
        """初始化加密器
        
        Args:
            key: 加密密钥，如果不提供则使用配置中的密钥
        """
        self.key = key or config.SECRET_KEY.encode('utf-8')
        # 确保密钥长度为 32 字节（256 位）
        if len(self.key) != 32:
            # 如果密钥长度不足，使用哈希扩展
            from hashlib import sha256
            self.key = sha256(self.key).digest()
    
    def encrypt(self, data):
        """加密数据
        
        Args:
            data: 要加密的数据（字典）
            
        Returns:
            str: 加密后的字符串（base64 编码）
        """
        import json
        # 将数据转换为 JSON 字符串
        plaintext = json.dumps(data).encode('utf-8')
        
        # 生成随机 IV（初始化向量）
        iv = os.urandom(16)
        
        # 创建加密器
        cipher = Cipher(
            algorithms.AES(self.key),
            modes.GCM(iv),
            backend=default_backend()
        )
        encryptor = cipher.encryptor()
        
        # 加密数据
        ciphertext = encryptor.update(plaintext) + encryptor.finalize()
        
        # 获取认证标签
        tag = encryptor.tag
        
        # 组合 IV、标签和密文
        encrypted = iv + tag + ciphertext
        
        # 编码为 base64
        return base64.b64encode(encrypted).decode('utf-8')
    
    def decrypt(self, encrypted_data):
        """解密数据
        
        Args:
            encrypted_data: 加密的数据（base64 编码字符串）
            
        Returns:
            dict: 解密后的数据
        """
        import json
        # 解码 base64
        encrypted = base64.b64decode(encrypted_data.encode('utf-8'))
        
        # 提取 IV、标签和密文
        iv = encrypted[:16]
        tag = encrypted[16:32]
        ciphertext = encrypted[32:]
        
        # 创建解密器
        cipher = Cipher(
            algorithms.AES(self.key),
            modes.GCM(iv, tag),
            backend=default_backend()
        )
        decryptor = cipher.decryptor()
        
        # 解密数据
        plaintext = decryptor.update(ciphertext) + decryptor.finalize()
        
        # 转换为字典
        return json.loads(plaintext.decode('utf-8'))

# 创建加密器实例
encryptor = Encryptor()
