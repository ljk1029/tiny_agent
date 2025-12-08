# 🚀 Tiny Agent Docker 快速开始指南

## 📦 前置要求

- Docker 20.10+
- Docker Compose 2.0+
- 2GB+ 可用内存
- 5GB+ 可用磁盘空间

### 安装 Docker（如果未安装）

**Ubuntu/Debian:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

**验证安装:**
```bash
docker --version
docker-compose --version
```

## ⚡ 5分钟快速部署

### 步骤 1: 克隆项目（如果需要）

```bash
git clone https://github.com/ljk1029/tiny_agent.git
cd tiny_agent
```

### 步骤 2: 配置环境变量

```bash
# 复制示例配置
cp .env.example .env

# 编辑配置文件
nano .env
```

**最小配置（必改）:**
```bash
SECRET_KEY=$(openssl rand -hex 32)
```

### 步骤 3: 构建镜像

```bash
cd deploy
./build.sh
```

### 步骤 4: 启动服务

```bash
./start.sh
```

选择启动模式：
- **选项 1**: 生产环境（推荐，包含 Nginx）
- **选项 2**: 生产环境（仅应用）
- **选项 3**: 开发环境

### 步骤 5: 访问应用

**浏览器打开:**
- 主应用: http://localhost:5000
- Nginx代理（如选择选项1）: http://localhost:80

**默认账号:**
- 用户名: `admin`
- 密码: `admin_pw_123`

⚠️ **首次登录后立即修改密码！**

## 🎯 常用命令

```bash
# 查看运行状态
docker-compose ps

# 查看实时日志
./logs.sh

# 重启服务
./restart.sh

# 停止服务
./stop.sh

# 备份数据
./backup.sh

# 恢复数据
./restore.sh backups/tiny_agent_backup_*.tar.gz
```

## 🔍 验证部署

### 1. 检查容器状态
```bash
docker-compose ps
```

应该显示所有容器为 `Up` 状态。

### 2. 测试健康检查
```bash
curl http://localhost:5000/auth/status
```

应该返回 JSON 响应。

### 3. 检查日志
```bash
./logs.sh
```

不应该有 ERROR 级别的日志。

## 🛠️ 故障排查

### 问题 1: 端口被占用
```bash
# 检查占用进程
sudo netstat -tlnp | grep :5000

# 修改端口（编辑 docker-compose.yml）
ports:
  - "8080:5000"
```

### 问题 2: 权限错误
```bash
# 修复数据目录权限
sudo chown -R $USER:$USER ../data ../logs
chmod -R 755 ../data ../logs
```

### 问题 3: 容器启动失败
```bash
# 查看详细错误
docker-compose logs --tail=50 tiny_agent

# 重新构建
./build.sh
```

### 问题 4: 无法访问网页
```bash
# 检查防火墙
sudo ufw allow 5000/tcp

# 检查容器网络
docker network inspect deploy_tiny_agent_network
```

## 📊 性能建议

### 小型部署（< 100 用户）
```yaml
# docker-compose.yml
environment:
  - GUNICORN_WORKERS=2
resources:
  limits:
    memory: 512M
```

### 中型部署（100-1000 用户）
```yaml
environment:
  - GUNICORN_WORKERS=4
resources:
  limits:
    memory: 1G
```

### 大型部署（> 1000 用户）
```yaml
environment:
  - GUNICORN_WORKERS=8
resources:
  limits:
    memory: 2G
```

## 🔒 安全配置清单

启动后务必完成：

- [ ] 修改默认管理员密码
- [ ] 设置强 SECRET_KEY
- [ ] 限制文件上传大小
- [ ] 配置 HTTPS（生产环境）
- [ ] 设置防火墙规则
- [ ] 启用日志监控
- [ ] 定期备份数据

## 📈 监控

### 查看资源使用
```bash
docker stats tiny_agent
```

### 查看磁盘使用
```bash
du -sh ../data ../logs
```

### 查看日志大小
```bash
ls -lh ../logs/
```

## 🔄 更新应用

```bash
# 1. 备份数据
./backup.sh

# 2. 拉取最新代码
cd ..
git pull

# 3. 重新构建
cd deploy
./build.sh

# 4. 重启服务
./restart.sh
```

## 🌐 生产环境建议

### 1. 使用 HTTPS

```bash
# 安装 certbot
sudo apt install certbot

# 获取证书
sudo certbot certonly --standalone -d your-domain.com

# 配置 nginx.conf（取消 HTTPS 部分注释）
```

### 2. 设置反向代理

如果已有 Nginx，添加配置：

```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 3. 配置自动重启

```bash
# 编辑 docker-compose.yml
restart: always  # 或 unless-stopped
```

### 4. 定期备份

```bash
# 添加到 crontab
crontab -e

# 每天凌晨2点备份
0 2 * * * cd /path/to/tiny_agent/deploy && ./backup.sh
```

## 📞 获取帮助

- 查看完整文档: [deploy/README.md](README.md)
- 提交问题: [GitHub Issues](https://github.com/ljk1029/tiny_agent/issues)
- 查看日志: `./logs.sh`

## 🎉 成功！

如果一切顺利，你现在应该可以访问 Tiny Agent 了！

访问: http://localhost:5000

祝使用愉快！🚀
