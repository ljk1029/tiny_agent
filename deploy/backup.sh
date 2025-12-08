#!/bin/bash
# 备份数据和日志

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 备份目录
BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/tiny_agent_backup_${TIMESTAMP}.tar.gz"

cd "$(dirname "$0")/.."

echo -e "${YELLOW}开始备份...${NC}"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 备份数据和日志
tar -czf "$BACKUP_FILE" data/ logs/ .env 2>/dev/null || true

if [ -f "$BACKUP_FILE" ]; then
    echo -e "${GREEN}✓ 备份成功: $BACKUP_FILE${NC}"
    echo ""
    echo "备份文件大小: $(du -h "$BACKUP_FILE" | cut -f1)"
    
    # 清理旧备份（保留最近 7 个）
    echo -e "${YELLOW}清理旧备份...${NC}"
    ls -t "$BACKUP_DIR"/tiny_agent_backup_*.tar.gz | tail -n +8 | xargs -r rm
    echo -e "${GREEN}✓ 完成${NC}"
else
    echo -e "${RED}✗ 备份失败${NC}"
    exit 1
fi
