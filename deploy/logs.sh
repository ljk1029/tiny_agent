#!/bin/bash
# 查看容器日志

cd "$(dirname "$0")"

# 检测 docker-compose 命令
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo "错误: 未找到 docker-compose 命令"
    exit 1
fi

# 默认查看主应用日志
SERVICE="${1:-tiny_agent}"
FOLLOW="${2:-f}"

if [ "$FOLLOW" = "f" ]; then
    echo "实时查看 $SERVICE 日志（Ctrl+C 退出）:"
    $DOCKER_COMPOSE logs -f "$SERVICE"
else
    echo "查看 $SERVICE 最近日志:"
    $DOCKER_COMPOSE logs --tail=100 "$SERVICE"
fi
