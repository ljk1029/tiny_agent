#!/bin/bash
# 清理 Docker 资源

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Docker 资源清理${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检测 docker-compose 命令
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE=""
fi

echo "选择清理选项:"
echo "  1) 停止并删除容器（保留镜像和数据）"
echo "  2) 删除 Tiny Agent 相关镜像"
echo "  3) 删除重复的镜像 (deploy-tiny_agent)"
echo "  4) 清理所有未使用的 Docker 资源"
echo "  5) 完全清理（容器 + 镜像 + 数据卷）"
echo "  6) 退出"
read -p "选择 [1-6]: " choice

cd "$(dirname "$0")"

case $choice in
    1)
        echo -e "${YELLOW}停止并删除容器...${NC}"
        if [ -n "$DOCKER_COMPOSE" ]; then
            $DOCKER_COMPOSE down
        fi
        docker stop tiny_agent tiny_agent_nginx 2>/dev/null || true
        docker rm tiny_agent tiny_agent_nginx 2>/dev/null || true
        echo -e "${GREEN}✓ 容器已删除${NC}"
        ;;
        
    2)
        echo -e "${YELLOW}删除 Tiny Agent 镜像...${NC}"
        docker rmi tiny_agent:latest 2>/dev/null || echo "镜像不存在"
        docker rmi deploy-tiny_agent:latest 2>/dev/null || echo "镜像不存在"
        echo -e "${GREEN}✓ 镜像已删除${NC}"
        ;;
        
    3)
        echo -e "${YELLOW}删除重复镜像 deploy-tiny_agent...${NC}"
        docker rmi deploy-tiny_agent:latest 2>/dev/null || echo "镜像不存在"
        echo -e "${GREEN}✓ 重复镜像已删除${NC}"
        ;;
        
    4)
        echo -e "${YELLOW}清理未使用的 Docker 资源...${NC}"
        docker system prune -a --volumes
        echo -e "${GREEN}✓ 清理完成${NC}"
        ;;
        
    5)
        echo -e "${RED}警告: 此操作将删除所有容器、镜像和数据卷！${NC}"
        read -p "确认？[y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            if [ -n "$DOCKER_COMPOSE" ]; then
                $DOCKER_COMPOSE down -v
            fi
            docker stop tiny_agent tiny_agent_nginx 2>/dev/null || true
            docker rm tiny_agent tiny_agent_nginx 2>/dev/null || true
            docker rmi tiny_agent:latest deploy-tiny_agent:latest 2>/dev/null || true
            echo -e "${GREEN}✓ 完全清理完成${NC}"
        else
            echo "操作已取消"
        fi
        ;;
        
    6)
        echo "退出"
        exit 0
        ;;
        
    *)
        echo -e "${RED}无效选择${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}当前 Docker 状态:${NC}"
echo ""
echo -e "${YELLOW}容器:${NC}"
docker ps -a --filter name=tiny_agent

echo ""
echo -e "${YELLOW}镜像:${NC}"
docker images | grep -E "(REPOSITORY|tiny_agent|deploy)" || echo "无相关镜像"

echo ""
echo -e "${GREEN}清理完成！${NC}"
