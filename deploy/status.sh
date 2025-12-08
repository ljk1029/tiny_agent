#!/bin/bash
# 检查部署状态和健康

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

cd "$(dirname "$0")"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Tiny Agent 状态检查${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查 Docker
echo -e "${YELLOW}[1/7] 检查 Docker...${NC}"
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓ Docker 已安装: $(docker --version)${NC}"
else
    echo -e "${RED}✗ Docker 未安装${NC}"
    exit 1
fi

# 检查 Docker Compose
echo -e "${YELLOW}[2/7] 检查 Docker Compose...${NC}"
if command -v docker-compose &> /dev/null; then
    echo -e "${GREEN}✓ Docker Compose 已安装: $(docker-compose --version)${NC}"
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    echo -e "${GREEN}✓ Docker Compose 已安装: $(docker compose version)${NC}"
    DOCKER_COMPOSE="docker compose"
else
    echo -e "${RED}✗ Docker Compose 未安装${NC}"
    echo -e "${YELLOW}提示: 安装命令 - sudo apt install docker-compose-plugin${NC}"
    exit 1
fi

# 检查容器状态
echo -e "${YELLOW}[3/7] 检查容器状态...${NC}"
if docker ps | grep -q "tiny_agent"; then
    echo -e "${GREEN}✓ 容器正在运行${NC}"
    docker ps --filter name=tiny_agent --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    echo -e "${RED}✗ 容器未运行${NC}"
fi

# 检查端口
echo -e "${YELLOW}[4/7] 检查端口占用...${NC}"
if netstat -tlnp 2>/dev/null | grep -q ":5000"; then
    echo -e "${GREEN}✓ 端口 5000 已占用（应用可能在运行）${NC}"
else
    echo -e "${YELLOW}⚠ 端口 5000 未占用${NC}"
fi

# 检查数据目录
echo -e "${YELLOW}[5/7] 检查数据目录...${NC}"
if [ -d "../data" ]; then
    DATA_SIZE=$(du -sh ../data 2>/dev/null | cut -f1)
    echo -e "${GREEN}✓ 数据目录存在: $DATA_SIZE${NC}"
    if [ -f "../data/app.db" ]; then
        echo -e "${GREEN}  └─ 数据库文件存在${NC}"
    else
        echo -e "${YELLOW}  └─ 数据库文件不存在${NC}"
    fi
else
    echo -e "${RED}✗ 数据目录不存在${NC}"
fi

# 检查日志目录
echo -e "${YELLOW}[6/7] 检查日志目录...${NC}"
if [ -d "../logs" ]; then
    LOG_SIZE=$(du -sh ../logs 2>/dev/null | cut -f1)
    echo -e "${GREEN}✓ 日志目录存在: $LOG_SIZE${NC}"
    if [ -f "../logs/system.log" ]; then
        LOG_LINES=$(wc -l < ../logs/system.log)
        echo -e "${GREEN}  └─ 系统日志: $LOG_LINES 行${NC}"
    fi
else
    echo -e "${RED}✗ 日志目录不存在${NC}"
fi

# 健康检查
echo -e "${YELLOW}[7/7] 健康检查...${NC}"
if curl -s http://localhost:5000/auth/status > /dev/null 2>&1; then
    echo -e "${GREEN}✓ 应用响应正常${NC}"
    RESPONSE=$(curl -s http://localhost:5000/auth/status)
    echo -e "${GREEN}  └─ 响应: $RESPONSE${NC}"
else
    echo -e "${RED}✗ 应用无响应${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  检查完成${NC}"
echo -e "${BLUE}========================================${NC}"

# 总结
echo ""
echo -e "${GREEN}可用命令:${NC}"
echo "  ./start.sh    - 启动服务"
echo "  ./stop.sh     - 停止服务"
echo "  ./restart.sh  - 重启服务"
echo "  ./logs.sh     - 查看日志"
echo "  ./backup.sh   - 备份数据"
