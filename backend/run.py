from flask import Flask
from flask_cors import CORS
from app.api.routes import api_bp
from app.config.settings import config

# 创建 Flask 应用
app = Flask('parking_notify')

# 配置 CORS
CORS(app)

# 注册 API 蓝图
app.register_blueprint(api_bp, url_prefix='/api')

# 启动应用
if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=config.PORT,
        debug=config.DEBUG
    )
