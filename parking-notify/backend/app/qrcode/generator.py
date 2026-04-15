import qrcode
from io import BytesIO
import base64

class QRCodeGenerator:
    """二维码生成器类"""
    
    def generate(self, data, color="#000000", background="#FFFFFF", size=10):
        """生成二维码
        
        Args:
            data: 要编码的数据
            color: 二维码颜色，默认为黑色
            background: 背景颜色，默认为白色
            size: 二维码大小，默认为 10
            
        Returns:
            str: base64 编码的二维码图片
        """
        # 创建二维码对象
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=size,
            border=4,
        )
        
        # 添加数据
        qr.add_data(data)
        qr.make(fit=True)
        
        # 创建图片
        img = qr.make_image(fill_color=color, back_color=background)
        
        # 转换为 base64
        buffer = BytesIO()
        img.save(buffer, format="PNG")
        img_str = base64.b64encode(buffer.getvalue()).decode('utf-8')
        
        # 返回 data URI
        return f"data:image/png;base64,{img_str}"

# 创建二维码生成器实例
qr_generator = QRCodeGenerator()
