# Tiny Agent 系统框架文档

## 1. 整体架构

### 1.1 系统概述
Tiny Agent 是一个基于 Flask + Bootstrap 的轻量级 AI 助手系统，提供文件管理、系统监控和命令执行功能。

```
┌─────────────────────────────────────────────────────────┐
│                    前端层 (Frontend)                     │
│  Bootstrap 5.3 + Vanilla JavaScript + SPA 架构          │
├─────────────────────────────────────────────────────────┤
│                     路由层 (Routes)                      │
│   /auth  │  /files  │  /logs  │  /commands             │
├─────────────────────────────────────────────────────────┤
│                   业务逻辑层 (Backend)                    │
│  Flask 3.0 + Flask-Login + Flask-SQLAlchemy            │
├─────────────────────────────────────────────────────────┤
│                   数据持久层 (Database)                   │
│            SQLite (app.db) + 文件系统存储                │
└─────────────────────────────────────────────────────────┘
```

### 1.2 功能模块划分

| 模块 | 功能 | 权限要求 | 说明 |
|------|------|----------|------|
| **文件管理** | 上传/下载/列表 | 所有人 | 支持多种文件格式，预留 AI 处理接口 |
| **日志监控** | 系统日志/流量信息 | 登录用户 | 查看应用运行日志和访问统计 |
| **命令执行** | 安全命令执行 | 管理员 | 7个预定义安全命令，防止恶意操作 |

### 1.3 技术栈

**前端技术：**
- Bootstrap 5.3.0 - UI 框架
- Vanilla JavaScript - 无框架依赖
- SPA 架构 - 锚点导航 (#file-section, #log-section, #command-section)

**后端技术：**
- Flask 3.0.0 - Web 框架
- Flask-Login 0.6.3 - 用户认证
- Flask-SQLAlchemy 3.1.1 - ORM
- Werkzeug 3.0.1 - 密码加密
- Python-dotenv 1.0.0 - 环境配置

**数据存储：**
- SQLite - 用户数据
- 文件系统 - 上传文件、日志文件

---

## 2. 前端部分

### 2.1 页面结构

```
frontend/
├── index.html              # 主应用页面（SPA）
├── login.html              # 登录/注册页面
└── static/
    ├── css/
    │   └── custom.css      # 自定义样式
    └── js/m/
        ├── auth.js         # 认证模块
        ├── file.js         # 文件管理模块
        ├── commands.js     # 命令执行模块
        └── logs.js         # (待实现) 日志查看模块
```

### 2.2 核心功能模块

#### 2.2.1 认证模块 (auth.js)
```javascript
功能：
- checkLoginStatus()      // 检查登录状态
- updateUserUI(userData)   // 更新用户界面（显示角色徽章）
- login(username, password) // 用户登录
- register(formData)       // 用户注册
- logout()                 // 用户登出

UI 组件：
- 用户状态显示（游客/用户/管理员）
- 登录/注册表单
- 动态权限显示
```

#### 2.2.2 文件管理模块 (file.js)
```javascript
功能：
- uploadFile()            // 上传文件（支持多文件）
- loadFileList()          // 加载文件列表
- downloadFile(filename)  // 下载文件
- displayFileResult()     // 显示上传结果（10秒自动关闭）
- formatFileSize(bytes)   // 格式化文件大小

支持格式：
- 文档：pdf, docx, txt, csv, xlsx
- 图片：png, jpg, jpeg
- 日志：log

特性：
- 自动消息提示（成功/失败）
- 文件大小限制（16MB）
- AI 处理预留接口
```

#### 2.2.3 命令执行模块 (commands.js)
```javascript
功能：
- checkCommandAccess()           // 检查管理员权限
- displayCommandInterface()      // 显示命令界面
- loadAvailableCommands()        // 加载可用命令列表
- executeCommand(commandKey)     // 执行命令
- displayCommandList(commands)   // 显示命令按钮

安全机制：
- 权限验证（仅管理员）
- 白名单命令（不支持自定义命令）
- 超时控制（10秒）
- ANSI 转义码清理
```

### 2.3 UI/UX 设计

**导航方式：**
- 锚点导航（#file-section, #log-section, #command-section）
- 平滑滚动效果
- 响应式设计（移动端友好）

**用户反馈：**
- Bootstrap Alert 自动消息（10秒自动关闭）
- 加载动画（Spinner）
- 角色徽章（游客/用户/管理员）

---

## 3. 后端部分

### 3.1 应用架构

```python
backend/
├── app.py                  # Flask 主应用
├── config.py               # 配置管理
├── database.py             # 数据库模型
├── init_db.py              # 数据库初始化脚本
├── view_db.py              # 数据库查看工具
├── routes/                 # 路由模块（Blueprint）
│   ├── auth.py             # 认证路由
│   ├── files.py            # 文件路由
│   ├── logs.py             # 日志路由
│   └── commands.py         # 命令路由
└── utils/                  # 工具模块
    ├── ai_providers.py     # AI 接口（预留）
    └── security.py         # 安全工具
```

### 3.2 核心模块详解

#### 3.2.1 应用主入口 (app.py)
```python
主要功能：
1. Flask 应用初始化
   - 配置模板和静态文件目录
   - 加载配置（Config）
   - 初始化 SQLAlchemy 和 Flask-Login

2. Blueprint 注册
   - /auth       # 认证接口
   - /files      # 文件接口
   - /logs       # 日志接口
   - /commands   # 命令接口

3. 数据库初始化
   - 创建表结构
   - 创建默认管理员账户（admin/admin_pw_123）

4. 日志配置
   - 文件日志（logs/system.log）
   - 格式：时间-模块-级别-消息
```

#### 3.2.2 配置管理 (config.py)
```python
class Config:
    # Flask 配置
    SECRET_KEY                    # 会话密钥
    SQLALCHEMY_DATABASE_URI       # 数据库路径
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # 文件上传配置
    UPLOAD_FOLDER                 # backend/uploads
    MAX_CONTENT_LENGTH = 16MB     # 最大文件大小
    ALLOWED_EXTENSIONS            # 允许的文件类型
    
    # 日志配置
    LOG_FOLDER                    # backend/logs
    
    # AI 配置（预留）
    OPENAI_API_KEY               # OpenAI API 密钥
    CLAUDE_API_KEY               # Claude API 密钥
    
    # 会话配置
    PERMANENT_SESSION_LIFETIME = 30分钟
```

#### 3.2.3 数据库模型 (database.py)
```python
User 模型：
- id: Integer (主键)
- username: String(80) (唯一)
- password_hash: String(200)
- role: String(20) (admin/user, 默认 user)
- created_at: DateTime (自动生成)

方法：
- set_password(password)        # 密码加密（scrypt）
- check_password(password)      # 密码验证
- is_authenticated              # Flask-Login 必需
- is_active                     # Flask-Login 必需
- is_anonymous                  # Flask-Login 必需
- get_id()                      # Flask-Login 必需
```

### 3.3 路由接口详解

#### 3.3.1 认证路由 (/auth)
```python
POST   /auth/login           # 用户登录
POST   /auth/register        # 用户注册
POST   /auth/logout          # 用户登出
GET    /auth/status          # 获取当前用户状态
POST   /auth/change-password # 修改密码
```

**响应格式：**
```json
{
  "success": true/false,
  "message": "操作结果",
  "authenticated": true/false,
  "username": "用户名",
  "role": "admin/user"
}
```

#### 3.3.2 文件路由 (/files)
```python
POST   /files/upload         # 上传文件（支持多文件）
GET    /files/download/<filename>  # 下载文件
GET    /files/list           # 获取文件列表
```

**文件处理流程：**
1. 验证文件类型（ALLOWED_EXTENSIONS）
2. 安全文件名处理（secure_filename）
3. 保存到 UPLOAD_FOLDER
4. 调用 AI 处理接口（预留）
5. 返回处理结果

**响应格式：**
```json
{
  "success": true,
  "filename": "xxx.pdf",
  "ai_result": {
    "summary": "AI 分析结果（预留）"
  }
}
```

#### 3.3.3 命令路由 (/commands)
```python
POST   /commands/execute     # 执行命令（仅管理员）
GET    /commands/available   # 获取可用命令列表
```

**安全命令白名单：**
```python
SAFE_COMMANDS = {
    'system_info': 'uname -a',
    'disk_usage': 'df -h /',
    'memory_usage': 'free -h',
    'cpu_load': "top -bn1 | grep 'Cpu(s)'",
    'list_services': 'systemctl list-units --type=service --state=running',
    'check_network': 'netstat -tulpn',
    'list_files': f'ls -lah "{UPLOAD_FOLDER}"'  # 动态获取上传目录路径
}
```

**执行流程：**
1. 验证管理员权限
2. 检查命令是否在白名单
3. 动态获取上传目录路径（避免硬编码）
4. 使用 subprocess.run 执行
5. 10秒超时限制
6. 清理 ANSI 转义码
7. 记录执行日志

**响应格式：**
```json
{
  "success": true,
  "command": "system_info",
  "stdout": "命令输出",
  "stderr": "错误输出",
  "returncode": 0
}
```

#### 3.3.4 日志路由 (/logs)
```python
GET    /logs/system          # 获取系统日志（需要登录）
GET    /logs/traffic         # 获取流量统计（需要登录）
```

---

## 4. AI 部分

### 4.1 当前状态
AI 功能目前处于**预留接口**状态，返回模拟数据用于测试。

### 4.2 接口定义 (utils/ai_providers.py)
```python
def process_file_with_ai(file_path, ai_provider='openai'):
    """
    使用 AI 处理文件
    
    参数：
        file_path: 文件路径
        ai_provider: AI 提供商 ('openai', 'claude')
    
    返回：
        {
            'summary': 'AI 生成的摘要',
            'key_points': ['要点1', '要点2'],
            'categories': ['分类1', '分类2']
        }
    """
    # 当前返回模拟数据
    return {
        'summary': f'这是对文件 {os.path.basename(file_path)} 的AI分析结果（演示）',
        'key_points': ['关键点1', '关键点2', '关键点3'],
        'categories': ['文档', '分析']
    }
```

### 4.3 扩展计划

**OpenAI 集成：**
```python
import openai

def process_with_openai(file_path):
    openai.api_key = Config.OPENAI_API_KEY
    
    # 读取文件内容
    content = read_file_content(file_path)
    
    # 调用 OpenAI API
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": "你是一个文档分析助手"},
            {"role": "user", "content": f"请分析以下文档：\n{content}"}
        ]
    )
    
    return response.choices[0].message.content
```

**Claude 集成：**
```python
import anthropic

def process_with_claude(file_path):
    client = anthropic.Anthropic(api_key=Config.CLAUDE_API_KEY)
    
    content = read_file_content(file_path)
    
    message = client.messages.create(
        model="claude-3-sonnet-20240229",
        max_tokens=1024,
        messages=[
            {"role": "user", "content": f"请分析以下文档：\n{content}"}
        ]
    )
    
    return message.content
```

---

## 5. 扩展部分

### 5.1 已实现功能清单

✅ **用户认证系统**
- 登录/注册/登出
- 会话管理（30分钟过期）
- 密码加密（Werkzeug scrypt）
- 角色管理（admin/user）

✅ **文件管理系统**
- 多文件上传
- 文件下载
- 文件列表显示（名称、大小、时间）
- 文件类型验证
- 文件大小限制（16MB）

✅ **命令执行系统**
- 7个安全命令
- 权限控制（仅管理员）
- 超时控制（10秒）
- 输出清理（移除 ANSI 码）
- 执行日志记录

✅ **UI/UX 改进**
- 响应式设计
- 自动消息提示
- 角色徽章显示
- 平滑滚动导航

### 5.2 待实现功能

⚠️ **AI 功能实现**
- [ ] OpenAI GPT-4 集成
- [ ] Claude 3 集成
- [ ] 文档智能分析
- [ ] 多语言支持
- [ ] 文件内容提取（PDF/DOCX）

⚠️ **日志系统增强**
- [ ] 实时日志查看
- [ ] 日志搜索过滤
- [ ] 流量统计图表
- [ ] 访问分析报告

⚠️ **文件管理增强**
- [ ] 文件删除功能
- [ ] 文件重命名
- [ ] 文件分类管理
- [ ] 文件搜索

⚠️ **用户管理功能**
- [ ] 管理员管理用户（创建/删除/修改角色）
- [ ] 用户列表查看
- [ ] 用户活动日志
- [ ] 密码重置（邮件）

⚠️ **安全增强**
- [ ] HTTPS 支持
- [ ] CSRF 保护
- [ ] 速率限制
- [ ] IP 黑名单
- [ ] 文件病毒扫描

### 5.3 性能优化建议

**数据库优化：**
- 添加索引（username, created_at）
- 考虑迁移到 PostgreSQL（生产环境）
- 实现数据库连接池

**缓存策略：**
- Redis 缓存用户会话
- 文件列表缓存
- 命令输出缓存

**前端优化：**
- 代码压缩（Minify）
- 资源懒加载
- Service Worker（离线支持）
- WebSocket（实时日志）

**部署优化：**
- Gunicorn + Nginx
- Docker 容器化
- 负载均衡
- CDN 静态资源

### 5.4 安全最佳实践

**当前实现：**
- ✅ 密码加密存储
- ✅ 会话管理
- ✅ 命令白名单
- ✅ 文件类型验证
- ✅ 文件名安全处理

**建议增强：**
- HTTPS 强制
- 双因素认证（2FA）
- API 速率限制
- SQL 注入防护（已通过 ORM）
- XSS 防护
- CSRF Token

---

## 6. 部署指南

### 6.1 开发环境

```bash
# 1. 克隆项目
git clone <repository-url>
cd tiny_agent

# 2. 创建虚拟环境
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 3. 安装依赖
pip install -r requirements.txt

# 4. 初始化数据库
cd backend
python init_db.py

# 5. 启动应用
python app.py
# 或使用启动脚本：cd .. && ./run.sh

# 6. 访问应用
# 浏览器打开：http://localhost:5000
# 默认管理员：admin / admin_pw_123
```

### 6.2 生产环境

```bash
# 使用 Gunicorn + Nginx

# 1. 安装 Gunicorn
pip install gunicorn

# 2. 启动应用
gunicorn -w 4 -b 0.0.0.0:5000 app:app

# 3. Nginx 配置
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /static {
        alias /path/to/tiny_agent/frontend/static;
    }
}
```

### 6.3 Docker 部署

```dockerfile
# Dockerfile
FROM python:3.10-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
WORKDIR /app/backend

CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
```

```yaml
# docker-compose.yml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "5000:5000"
    volumes:
      - ./uploads:/app/backend/uploads
      - ./logs:/app/logs
    environment:
      - SECRET_KEY=your-secret-key
      - OPENAI_API_KEY=your-openai-key
```

---

## 7. 故障排查

### 7.1 常见问题

**问题 1：登录后无法跳转**
```
原因：User 模型缺少 Flask-Login 必需方法
解决：确保实现 is_authenticated, is_active, is_anonymous, get_id()
```

**问题 2：命令执行报错 "logging not defined"**
```
原因：commands.py 缺少 logging 导入
解决：添加 import logging
```

**问题 3：文件上传目录不存在**
```
原因：UPLOAD_FOLDER 路径硬编码或未创建
解决：使用 Config.init_app() 自动创建目录
```

**问题 4：命令 "list_files" 找不到目录**
```
原因：使用硬编码路径 /app/uploads 而非实际路径
解决：使用 get_safe_commands() 动态获取 UPLOAD_FOLDER
```

**问题 5：循环导入错误**
```
原因：app.py 和 routes 相互导入 db 或 User
解决：创建独立的 database.py 集中管理
```

### 7.2 日志查看

```bash
# 系统日志
tail -f logs/system.log

# 应用输出
# 如果使用 run.sh，查看：
tail -f /tmp/tiny_agent.log

# 查看数据库
sqlitebrowser backend/app.db
```

---

## 8. 版本历史

### v1.0.0 (当前版本)
- ✅ 基础认证系统
- ✅ 文件上传下载
- ✅ 命令执行（7个安全命令）
- ✅ 响应式 UI
- ⚠️ AI 接口预留

### v1.1.0 (计划中)
- [ ] 实现 AI 文档分析
- [ ] 日志实时查看
- [ ] 文件删除功能
- [ ] 用户管理界面

---

## 9. 贡献指南

### 9.1 代码规范
- Python: PEP 8
- JavaScript: ESLint Standard
- 提交信息：[类型] 简短描述

### 9.2 开发流程
1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m '[Feature] Add some AmazingFeature'`)
4. 推送分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

---

## 10. 许可证

MIT License - 详见 LICENSE 文件

---

## 附录：技术选型理由

**为什么选择 Flask？**
- 轻量级，易于学习
- 灵活的扩展机制
- 丰富的社区支持

**为什么使用 Bootstrap？**
- 快速原型开发
- 响应式设计开箱即用
- 丰富的组件库

**为什么选择 SQLite？**
- 零配置，文件数据库
- 适合中小型应用
- 易于备份和迁移

**为什么不使用前端框架（React/Vue）？**
- 降低复杂度
- 减少依赖
- 更快的加载速度
- 适合简单应用