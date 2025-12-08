# Tiny Agent Docker 部署文档

## 📋 目录结构

```
deploy/
├── Dockerfile              # Docker 镜像定义
├── docker-compose.yml      # 生产环境配置
├── docker-compose.dev.yml  # 开发环境配置
├── nginx.conf              # Nginx 配置
├── .dockerignore           # Docker 构建忽略文件
├── build.sh                # 构建镜像脚本
├── start.sh                # 启动服务脚本
├── stop.sh                 # 停止服务脚本
├── restart.sh              # 重启服务脚本
├── logs.sh                 # 查看日志脚本
├── backup.sh               # 备份数据脚本
├── restore.sh              # 恢复数据脚本
└── README.md               # 本文档
```

## 🚀 快速开始

### 方式一：使用脚本（推荐）

```bash
# 1. 构建镜像
cd deploy
./build.sh

# 2. 启动服务（使用已构建的镜像）
./start.sh

# 3. 查看日志
./logs.sh

# 4. 访问应用
浏览器打开: http://localhost:5000
```

**注意**: `build.sh` 构建名为 `tiny_agent:latest` 的镜像，`start.sh` 会使用这个镜像启动容器，不会重复构建。

### 方式二：使用 Docker Compose 直接构建并启动

如果想让 Docker Compose 自动构建镜像，编辑 `docker-compose.yml`：

```yaml
services:
  tiny_agent:
    # 注释掉 image 行
    # image: tiny_agent:latest
    # 取消注释 build 配置
    build:
      context: ..
      dockerfile: deploy/Dockerfile
```

然后运行：

```bash
# 1. 进入部署目录
cd deploy

# 2. 构建并启动
docker compose up -d --build

# 3. 查看日志
docker compose logs -f

# 4. 停止服务
docker compose down
```

## 📦 部署模式

### 1. 生产环境（Gunicorn + Nginx）

**特点：**
- ✅ 使用 Gunicorn 作为 WSGI 服务器（4 workers）
- ✅ Nginx 反向代理和静态文件服务
- ✅ 自动重启
- ✅ 健康检查
- ✅ 日志持久化

**启动命令：**
```bash
docker-compose up -d
```

**访问地址：**
- HTTP: http://localhost:80
- 应用直连: http://localhost:5000

### 2. 生产环境（仅应用）

**特点：**
- ✅ 使用 Gunicorn
- ✅ 无需 Nginx（适合已有反向代理的场景）

**启动命令：**
```bash
docker-compose up -d tiny_agent
```

### 3. 开发环境

**特点：**
- ✅ 代码热重载（挂载本地目录）
- ✅ Flask Debug 模式
- ✅ 详细错误信息

**启动命令：**
```bash
docker-compose -f docker-compose.dev.yml up -d
```

## ⚙️ 配置说明

### 环境变量

在项目根目录创建 `.env` 文件：

```bash
# Flask 配置
SECRET_KEY=your-super-secret-key-change-this
FLASK_ENV=production

# AI 配置（可选）
OPENAI_API_KEY=sk-xxxxxxxxxxxxx
CLAUDE_API_KEY=sk-ant-xxxxxxxxxxxxx
```

### 端口配置

在 `docker-compose.yml` 中修改端口映射：

```yaml
services:
  tiny_agent:
    ports:
      - "8080:5000"  # 改为其他端口
```

### 数据持久化

数据和日志通过卷挂载持久化：

```yaml
volumes:
  - ../data:/app/data       # 数据库和上传文件
  - ../logs:/app/logs       # 应用日志
```

## 🔧 常用操作

### 构建镜像

```bash
# 基本构建
./build.sh

# 指定标签
./build.sh v1.0.0

# 构建并推送到仓库
./build.sh latest registry.example.com
```

### 启动服务

```bash
# 交互式选择模式
./start.sh

# 或直接使用 docker-compose
docker-compose up -d
```

### 停止服务

```bash
# 停止但保留数据
./stop.sh

# 停止并删除数据卷
docker-compose down -v
```

### 重启服务

```bash
# 重启所有服务
./restart.sh

# 重启单个服务
docker-compose restart tiny_agent
```

### 查看日志

```bash
# 实时日志
./logs.sh

# 查看最近日志
./logs.sh tiny_agent n

# 查看 Nginx 日志
./logs.sh nginx
```

### 进入容器

```bash
# 进入应用容器
docker exec -it tiny_agent bash

# 执行命令
docker exec tiny_agent python backend/init_db.py
```

### 备份数据

```bash
# 创建备份
./backup.sh

# 备份文件保存在 backups/ 目录
ls backups/
```

### 恢复数据

```bash
# 列出可用备份
./restore.sh

# 恢复指定备份
./restore.sh backups/tiny_agent_backup_20251208_120000.tar.gz
```

## 🔍 故障排查

### 1. 容器无法启动

```bash
# 查看详细错误
docker-compose logs tiny_agent

# 检查容器状态
docker-compose ps

# 检查镜像
docker images tiny_agent
```

### 2. 端口被占用

```bash
# 检查端口占用
sudo netstat -tlnp | grep 5000

# 修改 docker-compose.yml 中的端口映射
ports:
  - "8080:5000"
```

### 3. 权限问题

```bash
# 确保数据目录权限正确
chmod -R 755 ../data ../logs

# 或在容器内修复
docker exec tiny_agent chmod -R 755 /app/data /app/logs
```

### 4. 数据库初始化失败

```bash
# 手动初始化数据库
docker exec tiny_agent python /app/backend/init_db.py

# 查看数据库文件
docker exec tiny_agent ls -la /app/data/
```

### 5. 健康检查失败

```bash
# 检查健康状态
docker inspect tiny_agent | grep Health -A 10

# 手动测试端点
curl http://localhost:5000/auth/status
```

## 🔒 安全建议

### 1. 修改默认密码

首次部署后立即修改管理员密码（默认：admin/admin_pw_123）

### 2. 设置 SECRET_KEY

在 `.env` 文件中设置强密码：

```bash
SECRET_KEY=$(openssl rand -hex 32)
```

### 3. 使用 HTTPS

取消 `nginx.conf` 中 HTTPS 配置的注释，并配置 SSL 证书：

```bash
# 生成自签名证书（测试用）
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/key.pem -out ssl/cert.pem
```

### 4. 限制文件权限

```bash
chmod 600 .env
chmod 700 data/ logs/
```

### 5. 定期更新

```bash
# 更新基础镜像
docker pull python:3.10-slim

# 重新构建
./build.sh latest
```

## 📊 性能优化

### 1. 调整 Gunicorn Workers

在 `Dockerfile` 中修改：

```dockerfile
CMD ["gunicorn", "--workers", "8", ...]  # 根据 CPU 核心数调整
```

经验公式：`workers = (2 × CPU核心数) + 1`

### 2. 启用 Nginx 缓存

在 `nginx.conf` 中添加：

```nginx
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m max_size=1g;
```

### 3. 限制日志大小

使用 Docker 日志驱动：

```yaml
services:
  tiny_agent:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## 🌐 生产部署清单

- [ ] 修改默认管理员密码
- [ ] 设置强 SECRET_KEY
- [ ] 配置 HTTPS（SSL 证书）
- [ ] 设置防火墙规则
- [ ] 配置日志轮转
- [ ] 设置定期备份（cron）
- [ ] 配置监控告警
- [ ] 限制上传文件大小
- [ ] 配置域名解析
- [ ] 测试健康检查

## 📝 更新日志

### v1.0.0 (2025-12-08)
- 初始 Docker 部署配置
- 支持 Gunicorn + Nginx
- 添加开发和生产环境配置
- 提供完整的部署脚本

## 🔗 相关链接

- [项目主页](https://github.com/ljk1029/tiny_agent)
- [Flask 文档](https://flask.palletsprojects.com/)
- [Docker 文档](https://docs.docker.com/)
- [Gunicorn 文档](https://docs.gunicorn.org/)
- [Nginx 文档](https://nginx.org/en/docs/)

## 📧 技术支持

如有问题，请提交 Issue 或联系维护团队。
