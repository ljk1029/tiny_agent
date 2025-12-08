#!/bin/bash
# 重启 Tiny Agent 服务

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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

echo -e "${YELLOW}重启 Tiny Agent 服务...${NC}"

$DOCKER_COMPOSE restart

echo -e "${GREEN}✓ 服务已重启${NC}"
echo ""
echo "容器状态:"
$DOCKER_COMPOSE ps
