#!/bin/bash
# 恢复数据和日志

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

BACKUP_FILE="$1"

if [ -z "$BACKUP_FILE" ]; then
    echo -e "${RED}用法: ./restore.sh <backup_file>${NC}"
    echo ""
    echo "可用的备份文件:"
    ls -lh backups/tiny_agent_backup_*.tar.gz 2>/dev/null || echo "  无备份文件"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}错误: 备份文件不存在: $BACKUP_FILE${NC}"
    exit 1
fi

cd "$(dirname "$0")/.."

echo -e "${YELLOW}警告: 此操作将覆盖当前数据!${NC}"
read -p "确认恢复？[y/N]: " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "操作已取消"
    exit 0
fi

echo -e "${YELLOW}恢复备份: $BACKUP_FILE${NC}"

# 解压备份
tar -xzf "$BACKUP_FILE"

echo -e "${GREEN}✓ 恢复完成${NC}"
echo ""
echo -e "${YELLOW}请重启服务以应用更改:${NC}"
echo "  cd deploy && ./restart.sh"
