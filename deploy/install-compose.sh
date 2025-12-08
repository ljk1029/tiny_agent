#!/bin/bash
# 安装或升级 Docker Compose

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Docker Compose 安装助手${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker 未安装${NC}"
    echo -e "${YELLOW}请先安装 Docker:${NC}"
    echo "  curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "  sudo sh get-docker.sh"
    exit 1
fi

echo -e "${GREEN}✓ Docker 已安装: $(docker --version)${NC}"
echo ""

# 检查现有的 Docker Compose
echo -e "${YELLOW}检查现有 Docker Compose...${NC}"
HAS_COMPOSE_V1=false
HAS_COMPOSE_V2=false

if command -v docker-compose &> /dev/null; then
    echo -e "${GREEN}✓ 找到 docker-compose (v1): $(docker-compose --version)${NC}"
    HAS_COMPOSE_V1=true
fi

if docker compose version &> /dev/null; then
    echo -e "${GREEN}✓ 找到 docker compose (v2): $(docker compose version)${NC}"
    HAS_COMPOSE_V2=true
fi

if $HAS_COMPOSE_V1 || $HAS_COMPOSE_V2; then
    echo ""
    echo -e "${GREEN}✓ Docker Compose 已安装${NC}"
    echo ""
    echo "如需升级，请选择安装方式："
else
    echo -e "${YELLOW}未找到 Docker Compose${NC}"
    echo ""
    echo "请选择安装方式："
fi

echo "  1) Docker Compose Plugin (推荐，v2)"
echo "  2) Docker Compose Standalone (v1)"
echo "  3) 跳过安装"
read -p "选择 [1-3]: " choice

case $choice in
    1)
        echo ""
        echo -e "${YELLOW}安装 Docker Compose Plugin (v2)...${NC}"
        
        # 检测系统类型
        if [ -f /etc/debian_version ]; then
            # Debian/Ubuntu
            echo "检测到 Debian/Ubuntu 系统"
            sudo apt-get update
            sudo apt-get install -y docker-compose-plugin
        elif [ -f /etc/redhat-release ]; then
            # RHEL/CentOS/Fedora
            echo "检测到 RHEL/CentOS/Fedora 系统"
            sudo yum install -y docker-compose-plugin
        else
            echo -e "${RED}未识别的系统，请手动安装${NC}"
            echo "访问: https://docs.docker.com/compose/install/"
            exit 1
        fi
        
        if docker compose version &> /dev/null; then
            echo -e "${GREEN}✓ 安装成功: $(docker compose version)${NC}"
        else
            echo -e "${RED}✗ 安装失败${NC}"
            exit 1
        fi
        ;;
        
    2)
        echo ""
        echo -e "${YELLOW}安装 Docker Compose Standalone (v1)...${NC}"
        
        # 获取最新版本
        COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
        
        if [ -z "$COMPOSE_VERSION" ]; then
            COMPOSE_VERSION="v2.23.3"
            echo -e "${YELLOW}无法获取最新版本，使用默认版本: $COMPOSE_VERSION${NC}"
        else
            echo "最新版本: $COMPOSE_VERSION"
        fi
        
        # 下载并安装
        sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
            -o /usr/local/bin/docker-compose
        
        sudo chmod +x /usr/local/bin/docker-compose
        
        # 验证
        if command -v docker-compose &> /dev/null; then
            echo -e "${GREEN}✓ 安装成功: $(docker-compose --version)${NC}"
        else
            echo -e "${RED}✗ 安装失败${NC}"
            exit 1
        fi
        ;;
        
    3)
        echo -e "${YELLOW}跳过安装${NC}"
        exit 0
        ;;
        
    *)
        echo -e "${RED}无效选择${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  安装完成${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "现在可以使用 Docker Compose 部署应用："
echo "  cd /path/to/tiny_agent/deploy"
echo "  ./start.sh"
