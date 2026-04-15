# 停车通知系统

一个通过二维码实现的停车通知系统，支持多种通知方式（钉钉、飞书、企业微信、邮件、短信）。

## 功能特点

- 生成包含通知配置的加密二维码
- 扫码即可发送移车通知
- 支持多种通知方式
- 车主可自定义通知内容
- 扫码者可输入简短留言
- 彩色二维码样式
- 无需数据持久化，配置信息加密嵌入二维码
- 一键部署脚本
- 系统更新功能
- 故障排查协助功能

## 技术栈

- 后端：Python + Flask
- 前端：HTML5 + CSS3 + JavaScript
- 二维码生成：qrcode 库
- 加密：cryptography 库
- 通知集成：各平台 API

## 项目结构

```
├── README.md              # 项目说明文件
├── backend/              # 后端代码
│   ├── .env.example      # 环境变量示例
│   ├── app/              # 应用主目录
│   │   ├── api/          # API 模块
│   │   │   ├── handlers.py     # API 处理函数
│   │   │   ├── routes.py       # API 路由
│   │   ├── config/        # 配置模块
│   │   ├── crypto/        # 加密模块
│   │   │   └── encryptor.py    # 加密实现
│   │   ├── notifiers/     # 通知模块
│   │   │   ├── base.py         # 通知基类
│   │   │   ├── dingtalk.py     # 钉钉通知
│   │   │   ├── email.py        # 邮件通知
│   │   │   ├── feishu.py       # 飞书通知
│   │   │   ├── manager.py      # 通知管理器
│   │   │   ├── sms.py          # 短信通知
│   │   │   └── wechat.py       # 企业微信通知
│   │   └── qrcode/        # 二维码模块
│   │       └── generator.py    # 二维码生成
│   ├── requirements.txt   # Python 依赖
│   └── run.py             # 应用启动入口
├── deploy.sh             # 一键部署脚本
├── update.sh             # 系统更新脚本
├── assist.sh             # 故障排查协助脚本
├── .gitignore            # Git 忽略文件
└── frontend/             # 前端代码
    ├── public/            # 静态资源
    │   └── css/           # 样式文件
    │       └── style.css  # 主样式文件
    └── templates/         # HTML 模板文件
        ├── index.html     # 生成二维码页面
        └── notify.html    # 发送通知页面
```

## 安装与部署

### 方法一：一键部署（推荐）

1. 克隆仓库
```bash
git clone https://github.com/gituib/car_notice.git
cd car_notice
```

2. 运行部署脚本
```bash
chmod +x deploy.sh
./deploy.sh
```

3. 按照提示完成部署

部署脚本会自动完成以下操作：
- 安装必要的依赖（Nginx、Python 3、pip、python3-venv）
- 创建并激活虚拟环境
- 安装Python依赖
- 配置环境变量（生成随机SECRET_KEY）
- 配置Nginx反向代理
- 部署前端静态文件
- 创建并启动systemd服务
- 检查服务状态

部署完成后，系统会显示访问地址和相关信息。

### 方法二：手动部署

#### 1. 后端安装

1. 进入后端目录
```bash
cd backend
```

2. 创建并激活虚拟环境
```bash
python3 -m venv venv
source venv/bin/activate
```

3. 安装依赖
```bash
pip install -r requirements.txt
```

4. 配置环境变量
```bash
cp .env.example .env
# 编辑 .env 文件，设置 SECRET_KEY 等配置
# 建议使用 openssl rand -hex 32 生成随机 SECRET_KEY
```

5. 启动后端服务
```bash
python run.py
```

#### 2. 前端部署

前端文件可以部署在任何静态文件服务器上，例如：

- Nginx
- Apache
- GitHub Pages
- Netlify

##### Nginx 配置示例

```nginx
server {
    listen 80;
    server_name localhost;

    # 前端静态文件
    location / {
        root /path/to/frontend;
        index index.html;
        try_files $uri $uri/ =404;
    }

    # 后端 API 代理
    location /api {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 使用方法

### 1. 生成二维码

1. 访问前端生成二维码页面（默认为 `http://localhost`）
2. 填写通知配置（至少选择一种通知方式）：
   - 钉钉：填写机器人 Webhook URL
   - 飞书：填写机器人 Webhook URL
   - 企业微信：填写机器人 Webhook URL
   - 邮件：填写收件人邮箱
   - 短信：填写手机号码
3. 自定义通知内容（可选）：设置通知模板，可包含 `{message}` 占位符表示扫码者的留言
4. 设置二维码颜色（可选）：选择二维码的前景色和背景色
5. 点击「生成二维码」按钮
6. 下载生成的二维码并打印贴在车上

### 2. 发送通知

1. 扫描车上的二维码
2. 在打开的页面中输入留言（可选）
3. 点击「发送通知」按钮
4. 系统会通过配置的所有方式发送通知给车主

## 通知方式配置

### 钉钉
1. 打开钉钉群，点击群设置 → 智能群助手 → 添加机器人 → 自定义
2. 填写机器人名称，选择安全设置（推荐使用「自定义关键词」，如「移车」）
3. 复制机器人的 Webhook URL
4. 在生成二维码页面填写该 URL

### 飞书
1. 打开飞书群，点击群设置 → 群机器人 → 添加机器人 → 自定义机器人
2. 填写机器人名称和描述
3. 复制机器人的 Webhook URL
4. 在生成二维码页面填写该 URL

### 企业微信
1. 打开企业微信群，点击群设置 → 群机器人 → 添加
2. 填写机器人名称
3. 复制机器人的 Webhook URL
4. 在生成二维码页面填写该 URL

### 邮件
1. 在 `.env` 文件中配置邮件服务器信息：
   - `SMTP_SERVER`：邮件服务器地址
   - `SMTP_PORT`：邮件服务器端口
   - `SMTP_USERNAME`：邮件服务器用户名
   - `SMTP_PASSWORD`：邮件服务器密码
   - `SMTP_SENDER`：发件人邮箱
2. 在生成二维码页面填写收件人邮箱

### 短信
1. 在 `.env` 文件中配置短信 API 信息：
   - `SMS_API_KEY`：短信 API 密钥
   - `SMS_API_URL`：短信 API 地址
   - `SMS_SIGNATURE`：短信签名
2. 在生成二维码页面填写手机号码

## 系统维护

### 更新系统
```bash
./update.sh
```

该脚本会执行以下操作：
- 拉取最新代码
- 更新Python依赖
- 重启Nginx服务
- 重启后端服务
- 检查服务状态

### 故障排查
```bash
./assist.sh
```

该脚本提供以下功能：
- 检查服务状态
- 查看后端日志
- 查看Nginx日志
- 检查端口占用
- 测试健康检查接口
- 重启服务

## 健康检查

系统提供健康检查接口，可用于监控服务状态：
```bash
curl http://localhost/api/health
```

## 环境变量配置

系统使用 `.env` 文件存储环境变量，主要配置项如下：

| 配置项 | 描述 | 默认值 | 必须 |
| ------ | ---- | ------ | ---- |
| `SECRET_KEY` | 用于加密配置信息的密钥 | 无 | 是 |
| `SMTP_SERVER` | 邮件服务器地址 | 无 | 邮件通知时需要 |
| `SMTP_PORT` | 邮件服务器端口 | 无 | 邮件通知时需要 |
| `SMTP_USERNAME` | 邮件服务器用户名 | 无 | 邮件通知时需要 |
| `SMTP_PASSWORD` | 邮件服务器密码 | 无 | 邮件通知时需要 |
| `SMTP_SENDER` | 发件人邮箱 | 无 | 邮件通知时需要 |
| `SMS_API_KEY` | 短信 API 密钥 | 无 | 短信通知时需要 |
| `SMS_API_URL` | 短信 API 地址 | 无 | 短信通知时需要 |
| `SMS_SIGNATURE` | 短信签名 | 无 | 短信通知时需要 |

## 安全说明

- 使用 AES-256-GCM 加密算法保护配置信息
- 密钥存储在环境变量中，不硬编码
- 不存储任何车主信息
- 通知内容加密传输

## 未来扩展

- 支持更多通知方式（如微信小程序、电话通知等）
- 增加通知历史记录功能
- 实现多语言支持
- 添加验证码防止滥用

## 许可证

MIT License
