# tiny_agent
ai agent

frontend/
├── index.html           # 主页面（含三个功能区）
├── login.html           # 登录页面
├── static/
│   ├── css/
│   │   └── custom.css   # 自定义样式
│   ├── js/m
│   │   ├── auth.js      # 认证逻辑
│   │   ├── file.js      # 文件处理
│   │   └── commands.js  # 命令执行
│   └── docs/            # 文档资源
backend/
├── app.py               # Flask主应用
├── config.py            # 配置文件
├── models.py            # 数据库模型
├── routes/
│   ├── auth.py          # 认证路由
│   ├── files.py         # 文件处理路由
│   ├── logs.py          # 日志路由
│   └── commands.py      # 命令执行路由
├── utils/
│   ├── ai_providers.py  # AI提供者集成
│   └── security.py      # 安全工具
uploads/                 # 上传文件存储
logs/                    # 日志存储
.env                     # 环境变量
requirements.txt         # 依赖列表
