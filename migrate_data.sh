#!/bin/bash

# Tiny Agent 数据迁移脚本
# 用途：将数据文件从 backend/ 目录迁移到项目根目录
# 适用于：从旧版本升级到新版本的用户

set -e  # 遇到错误立即退出

echo "======================================"
echo "  Tiny Agent 数据迁移工具"
echo "======================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

echo "📂 项目目录: $PROJECT_ROOT"
echo ""

# 检查旧数据是否存在
OLD_DB="backend/app.db"
OLD_UPLOADS="backend/uploads"
OLD_LOGS="backend/logs"

NEW_DATA_DIR="data"
NEW_LOGS_DIR="logs"

HAS_OLD_DATA=false

if [ -f "$OLD_DB" ]; then
    echo -e "${YELLOW}✓${NC} 发现旧数据库: $OLD_DB"
    HAS_OLD_DATA=true
fi

if [ -d "$OLD_UPLOADS" ]; then
    echo -e "${YELLOW}✓${NC} 发现旧上传目录: $OLD_UPLOADS"
    HAS_OLD_DATA=true
fi

if [ -d "$OLD_LOGS" ]; then
    echo -e "${YELLOW}✓${NC} 发现旧日志目录: $OLD_LOGS"
    HAS_OLD_DATA=true
fi

if [ "$HAS_OLD_DATA" = false ]; then
    echo -e "${GREEN}✓${NC} 未发现需要迁移的旧数据"
    echo ""
    echo "说明："
    echo "  - 如果是全新安装，请运行: cd backend && python init_db.py"
    echo "  - 如果已经迁移过，则无需再次执行"
    exit 0
fi

echo ""
echo "======================================"
echo "  开始迁移数据"
echo "======================================"
echo ""

# 创建新目录
echo "📁 创建新目录结构..."
mkdir -p "$NEW_DATA_DIR"
mkdir -p "$NEW_DATA_DIR/uploads"
mkdir -p "$NEW_LOGS_DIR"
echo -e "${GREEN}✓${NC} 目录创建完成"
echo ""

# 迁移数据库
if [ -f "$OLD_DB" ]; then
    echo "📦 迁移数据库文件..."
    if [ -f "$NEW_DATA_DIR/app.db" ]; then
        echo -e "${YELLOW}⚠${NC}  目标位置已存在数据库文件"
        read -p "是否覆盖? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "$OLD_DB" "$NEW_DATA_DIR/app.db.backup.$(date +%Y%m%d_%H%M%S)"
            echo -e "${GREEN}✓${NC} 已备份现有数据库"
            cp "$OLD_DB" "$NEW_DATA_DIR/app.db"
            echo -e "${GREEN}✓${NC} 数据库迁移完成: $NEW_DATA_DIR/app.db"
        else
            echo -e "${YELLOW}⊘${NC} 跳过数据库迁移"
        fi
    else
        cp "$OLD_DB" "$NEW_DATA_DIR/app.db"
        echo -e "${GREEN}✓${NC} 数据库迁移完成: $NEW_DATA_DIR/app.db"
    fi
    echo ""
fi

# 迁移上传文件
if [ -d "$OLD_UPLOADS" ] && [ "$(ls -A $OLD_UPLOADS 2>/dev/null)" ]; then
    echo "📤 迁移上传文件..."
    FILE_COUNT=$(find "$OLD_UPLOADS" -type f | wc -l)
    echo "   发现 $FILE_COUNT 个文件"
    
    cp -r "$OLD_UPLOADS"/* "$NEW_DATA_DIR/uploads/" 2>/dev/null || true
    echo -e "${GREEN}✓${NC} 上传文件迁移完成: $NEW_DATA_DIR/uploads/"
    echo ""
else
    echo -e "${YELLOW}⊘${NC} 上传目录为空，跳过"
    echo ""
fi

# 迁移日志
if [ -d "$OLD_LOGS" ] && [ "$(ls -A $OLD_LOGS 2>/dev/null)" ]; then
    echo "📋 迁移日志文件..."
    LOG_COUNT=$(find "$OLD_LOGS" -type f | wc -l)
    echo "   发现 $LOG_COUNT 个日志文件"
    
    cp -r "$OLD_LOGS"/* "$NEW_LOGS_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✓${NC} 日志文件迁移完成: $NEW_LOGS_DIR/"
    echo ""
else
    echo -e "${YELLOW}⊘${NC} 日志目录为空，跳过"
    echo ""
fi

# 询问是否删除旧文件
echo "======================================"
echo "  迁移完成"
echo "======================================"
echo ""
echo "新的文件位置："
echo "  - 数据库: $NEW_DATA_DIR/app.db"
echo "  - 上传文件: $NEW_DATA_DIR/uploads/"
echo "  - 日志文件: $NEW_LOGS_DIR/"
echo ""

read -p "是否删除旧数据文件? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🗑️  删除旧文件..."
    
    [ -f "$OLD_DB" ] && rm "$OLD_DB" && echo -e "${GREEN}✓${NC} 已删除: $OLD_DB"
    [ -d "$OLD_UPLOADS" ] && rm -rf "$OLD_UPLOADS" && echo -e "${GREEN}✓${NC} 已删除: $OLD_UPLOADS"
    [ -d "$OLD_LOGS" ] && rm -rf "$OLD_LOGS" && echo -e "${GREEN}✓${NC} 已删除: $OLD_LOGS"
    
    echo ""
    echo -e "${GREEN}✓${NC} 清理完成！"
else
    echo ""
    echo -e "${YELLOW}⊘${NC} 保留旧文件（可手动删除）"
    echo ""
    echo "手动删除命令："
    echo "  rm -f $OLD_DB"
    echo "  rm -rf $OLD_UPLOADS"
    echo "  rm -rf $OLD_LOGS"
fi

echo ""
echo "======================================"
echo -e "${GREEN}✓ 迁移流程全部完成！${NC}"
echo "======================================"
echo ""
echo "下一步："
echo "  1. 启动应用: cd backend && python app.py"
echo "  2. 或使用: ./run.sh"
echo ""
