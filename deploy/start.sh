#!/bin/bash
# 启动 Tiny Agent 容器

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  启动 Tiny Agent 服务${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 切换到部署目录
cd "$(dirname "$0")"

# 检测 docker-compose 命令
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo -e "${RED}错误: 未找到 docker-compose 或 docker compose 命令${NC}"
    echo -e "${YELLOW}请安装 Docker Compose:${NC}"
    echo "  Ubuntu/Debian: sudo apt install docker-compose-plugin"
    echo "  或访问: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}使用命令: $DOCKER_COMPOSE${NC}"
echo ""

# 检查配置文件
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}错误: 未找到 docker-compose.yml${NC}"
    exit 1
fi

# 创建必要的目录
echo -e "${YELLOW}创建数据和日志目录...${NC}"
mkdir -p ../data/uploads
mkdir -p ../logs

# 检查 .env 文件
if [ ! -f "../.env" ]; then
    echo -e "${YELLOW}警告: 未找到 .env 文件，将使用默认配置${NC}"
    echo -e "${YELLOW}建议创建 .env 文件并设置 SECRET_KEY${NC}"
fi

# 选择启动模式
echo "请选择启动模式:"
echo "  1) 生产环境 (Gunicorn + Nginx)"
echo "  2) 生产环境 (仅 Gunicorn)"
echo "  3) 开发环境 (Flask Debug)"
read -p "选择 [1-3]: " choice

case $choice in
    1)
        echo -e "${GREEN}启动生产环境（包含 Nginx）...${NC}"
        $DOCKER_COMPOSE up -d
        ;;
    2)
        echo -e "${GREEN}启动生产环境（仅应用）...${NC}"
        $DOCKER_COMPOSE up -d tiny_agent
        ;;
    3)
        echo -e "${GREEN}启动开发环境...${NC}"
        $DOCKER_COMPOSE -f docker-compose.dev.yml up -d
        ;;
    *)
        echo -e "${RED}无效选择${NC}"
        exit 1
        ;;
esac

# 等待容器启动
echo ""
echo -e "${YELLOW}等待容器启动...${NC}"
sleep 5

# 检查容器状态
echo ""
echo -e "${GREEN}容器状态:${NC}"
$DOCKER_COMPOSE ps

# 显示日志
echo ""
echo -e "${GREEN}查看实时日志（Ctrl+C 退出）:${NC}"
$DOCKER_COMPOSE logs -f
