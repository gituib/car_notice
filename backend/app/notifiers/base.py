from abc import ABC, abstractmethod

class BaseNotifier(ABC):
    """通知基类"""
    
    @abstractmethod
    def send(self, message, **kwargs):
        """发送通知
        
        Args:
            message: 通知内容
            **kwargs: 其他参数
            
        Returns:
            bool: 是否发送成功
        """
        pass
