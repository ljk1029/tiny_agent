#!/bin/bash
# 停止 Tiny Agent 容器

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}停止 Tiny Agent 服务...${NC}"

cd "$(dirname "$0")"

# 检测 docker-compose 命令
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo -e "${RED}错误: 未找到 docker-compose 命令${NC}"
    exit 1
fi

# 停止所有服务
$DOCKER_COMPOSE down

# 可选：同时停止开发环境
if docker ps -a | grep -q "tiny_agent_dev"; then
    $DOCKER_COMPOSE -f docker-compose.dev.yml down
fi

echo -e "${GREEN}✓ 服务已停止${NC}"

# 询问是否清理
read -p "是否删除数据卷？[y/N]: " remove_volumes
if [[ "$remove_volumes" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}删除数据卷...${NC}"
    $DOCKER_COMPOSE down -v
    echo -e "${GREEN}✓ 数据卷已删除${NC}"
fi
