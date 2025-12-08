#!/bin/bash
# Docker 镜像构建脚本

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置
IMAGE_NAME="tiny_agent"
IMAGE_TAG="${1:-latest}"
REGISTRY="${2:-}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Tiny Agent Docker 镜像构建${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 切换到项目根目录（如果在 deploy 目录）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ "$(basename "$SCRIPT_DIR")" = "deploy" ]; then
    cd "$SCRIPT_DIR/.."
    echo -e "${YELLOW}切换到项目根目录: $(pwd)${NC}"
    echo ""
fi

# 检查是否在正确的目录
if [ ! -f "backend/app.py" ]; then
    echo -e "${RED}错误: 未找到 backend/app.py，请确认目录结构${NC}"
    exit 1
fi

# 检查 requirements.txt
if [ ! -f "requirements.txt" ]; then
    echo -e "${RED}错误: 未找到 requirements.txt${NC}"
    exit 1
fi

# 添加 gunicorn 到 requirements.txt（如果不存在）
if ! grep -q "gunicorn" requirements.txt; then
    echo -e "${YELLOW}添加 gunicorn 到 requirements.txt...${NC}"
    echo "gunicorn==21.2.0" >> requirements.txt
fi

# 构建镜像
echo -e "${GREEN}开始构建镜像: ${IMAGE_NAME}:${IMAGE_TAG}${NC}"
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" -f deploy/Dockerfile .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 镜像构建成功!${NC}"
    echo ""
    echo "镜像信息:"
    docker images "${IMAGE_NAME}:${IMAGE_TAG}"
    echo ""
    
    # 如果指定了仓库地址，则推送
    if [ -n "$REGISTRY" ]; then
        echo -e "${GREEN}推送镜像到仓库: ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}${NC}"
        docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        docker push "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ 镜像推送成功!${NC}"
        else
            echo -e "${RED}✗ 镜像推送失败${NC}"
            exit 1
        fi
    fi
    
    echo ""
    echo -e "${GREEN}下一步:${NC}"
    echo "  1. 启动容器: cd deploy && ./start.sh"
    echo "  2. 或使用 docker-compose: docker-compose up -d"
else
    echo -e "${RED}✗ 镜像构建失败${NC}"
    exit 1
fi
