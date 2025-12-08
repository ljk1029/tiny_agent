# 📦 Tiny Agent 部署文件夹完整指南

## 🎯 概述

`deploy/` 文件夹包含了将 Tiny Agent 部署到 Docker 环境所需的所有配置文件和脚本。

## 📁 文件清单

### 核心配置文件

| 文件 | 说明 | 用途 |
|------|------|------|
| `Dockerfile` | Docker 镜像定义 | 定义应用容器的构建步骤 |
| `docker-compose.yml` | 生产环境配置 | 使用 Gunicorn + Nginx 的完整部署 |
| `docker-compose.dev.yml` | 开发环境配置 | 支持热重载的开发模式 |
| `nginx.conf` | Nginx 配置 | 反向代理、静态文件、缓存配置 |
| `.dockerignore` | Docker 忽略文件 | 排除不需要打包的文件 |

### 操作脚本

| 脚本 | 功能 | 使用场景 |
|------|------|----------|
| `build.sh` | 构建 Docker 镜像 | 首次部署或代码更新后 |
| `start.sh` | 启动服务（交互式） | 启动应用，可选择模式 |
| `stop.sh` | 停止服务 | 维护或关闭应用 |
| `restart.sh` | 重启服务 | 配置更改后快速重启 |
| `logs.sh` | 查看日志 | 调试和监控 |
| `backup.sh` | 备份数据 | 定期备份或更新前 |
| `restore.sh` | 恢复数据 | 数据恢复或迁移 |

### 文档文件

| 文档 | 内容 | 适用对象 |
|------|------|----------|
| `README.md` | 完整部署文档 | 运维人员、高级用户 |
| `QUICKSTART.md` | 5分钟快速开始 | 新用户、快速部署 |
| `CHECKLIST.md` | 部署检查清单 | 生产环境部署 |
| `INDEX.md` | 本文档 | 了解文件夹结构 |

## 🚀 使用流程

### 首次部署

```bash
1. 阅读文档
   └─> QUICKSTART.md          # 快速了解流程
   
2. 检查环境
   └─> CHECKLIST.md           # 对照检查清单
   
3. 配置环境
   └─> 创建 .env 文件          # 从 .env.example 复制
   
4. 构建镜像
   └─> ./build.sh             # 构建 Docker 镜像
   
5. 启动服务
   └─> ./start.sh             # 选择部署模式
   
6. 验证部署
   └─> ./logs.sh              # 检查日志
   └─> 访问 http://localhost:5000
```

### 日常运维

```bash
# 查看运行状态
docker-compose ps

# 实时查看日志
./logs.sh

# 重启服务
./restart.sh

# 停止服务
./stop.sh
```

### 数据维护

```bash
# 备份数据
./backup.sh

# 恢复数据
./restore.sh backups/tiny_agent_backup_YYYYMMDD_HHMMSS.tar.gz
```

## 🎨 部署模式详解

### 模式 1: 生产环境（完整）

**文件**: `docker-compose.yml`

**组件**:
- Tiny Agent 应用（Gunicorn）
- Nginx 反向代理

**特点**:
- ✅ 高性能（多 worker）
- ✅ 静态文件缓存
- ✅ 负载均衡
- ✅ HTTPS 支持

**启动**:
```bash
./start.sh
选择: 1) 生产环境 (Gunicorn + Nginx)
```

### 模式 2: 生产环境（精简）

**文件**: `docker-compose.yml`

**组件**:
- Tiny Agent 应用（仅 Gunicorn）

**特点**:
- ✅ 适合已有反向代理的场景
- ✅ 资源占用更少
- ✅ 配置简单

**启动**:
```bash
./start.sh
选择: 2) 生产环境 (仅 Gunicorn)
```

### 模式 3: 开发环境

**文件**: `docker-compose.dev.yml`

**组件**:
- Tiny Agent 应用（Flask Debug）

**特点**:
- ✅ 代码热重载
- ✅ 详细错误信息
- ✅ 便于调试

**启动**:
```bash
./start.sh
选择: 3) 开发环境 (Flask Debug)
```

## 🔧 配置定制

### 修改端口

编辑 `docker-compose.yml`:
```yaml
services:
  tiny_agent:
    ports:
      - "8080:5000"  # 改为自定义端口
```

### 调整性能

编辑 `Dockerfile`:
```dockerfile
# 修改 worker 数量（CPU核心数 × 2 + 1）
CMD ["gunicorn", "--workers", "8", ...]
```

### 配置 HTTPS

1. 获取 SSL 证书
2. 将证书放入 `ssl/` 目录
3. 取消 `nginx.conf` 中 HTTPS 配置的注释
4. 重启服务

### 资源限制

编辑 `docker-compose.yml`:
```yaml
services:
  tiny_agent:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
```

## 📊 监控和日志

### 容器状态
```bash
docker-compose ps
```

### 实时日志
```bash
./logs.sh                    # 应用日志
./logs.sh nginx              # Nginx 日志
```

### 资源使用
```bash
docker stats tiny_agent
```

### 磁盘使用
```bash
du -sh ../data ../logs
```

## 🔒 安全最佳实践

### 必做项

1. **修改默认密码**
   ```bash
   # 登录后立即修改 admin 密码
   ```

2. **设置强密钥**
   ```bash
   # 在 .env 中设置
   SECRET_KEY=$(openssl rand -hex 32)
   ```

3. **启用 HTTPS**
   ```bash
   # 使用 Let's Encrypt
   sudo certbot certonly --standalone -d your-domain.com
   ```

4. **限制资源**
   ```yaml
   # 在 docker-compose.yml 中设置资源限制
   ```

5. **定期备份**
   ```bash
   # 添加到 crontab
   0 2 * * * cd /path/to/tiny_agent/deploy && ./backup.sh
   ```

### 推荐项

- 配置防火墙规则
- 启用速率限制
- 设置日志轮转
- 配置监控告警
- 定期安全扫描

## 🆘 故障排查

### 容器无法启动

```bash
# 1. 查看详细错误
docker-compose logs --tail=50 tiny_agent

# 2. 检查配置
docker-compose config

# 3. 重新构建
./build.sh
```

### 端口冲突

```bash
# 查看端口占用
sudo netstat -tlnp | grep :5000

# 修改端口或停止占用程序
```

### 权限问题

```bash
# 修复目录权限
sudo chown -R $USER:$USER ../data ../logs
chmod -R 755 ../data ../logs
```

### 网络问题

```bash
# 检查容器网络
docker network inspect deploy_tiny_agent_network

# 重建网络
docker-compose down
docker network prune
docker-compose up -d
```

## 📚 学习资源

### 官方文档

- [Docker 文档](https://docs.docker.com/)
- [Docker Compose 文档](https://docs.docker.com/compose/)
- [Gunicorn 文档](https://docs.gunicorn.org/)
- [Nginx 文档](https://nginx.org/en/docs/)

### 本项目文档

- [项目 README](../README.md)
- [框架文档](../framework.md)
- [快速开始](QUICKSTART.md)
- [完整部署](README.md)
- [检查清单](CHECKLIST.md)

## 🤝 贡献

如果你发现部署过程中的问题或有改进建议：

1. 提交 Issue: https://github.com/ljk1029/tiny_agent/issues
2. 提交 Pull Request
3. 完善文档

## 📞 支持

- GitHub Issues: [提交问题](https://github.com/ljk1029/tiny_agent/issues)
- 邮件: your-email@example.com
- 文档: 查看 `deploy/README.md`

---

**最后更新**: 2025-12-08  
**版本**: 1.0.0
