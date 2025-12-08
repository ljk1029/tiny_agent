#!/bin/bash
# 迁移脚本：将 backend 中的数据文件移动到根目录

echo "开始迁移数据和日志文件..."

# 创建新的目录结构
mkdir -p data/uploads
mkdir -p logs

# 迁移数据库文件
if [ -f "backend/app.db" ]; then
    echo "迁移数据库文件..."
    mv backend/app.db data/app.db
    echo "✓ 数据库已移动到 data/app.db"
fi

# 迁移上传文件
if [ -d "backend/uploads" ]; then
    echo "迁移上传文件..."
    if [ "$(ls -A backend/uploads)" ]; then
        mv backend/uploads/* data/uploads/
        echo "✓ 上传文件已移动到 data/uploads/"
    fi
    rmdir backend/uploads 2>/dev/null
fi

# 迁移日志文件
if [ -d "backend/logs" ]; then
    echo "迁移日志文件..."
    if [ "$(ls -A backend/logs)" ]; then
        mv backend/logs/* logs/
        echo "✓ 日志文件已移动到 logs/"
    fi
    rmdir backend/logs 2>/dev/null
fi

# 检查根目录的旧 logs（如果存在）
if [ -d "logs_old" ]; then
    echo "发现旧的 logs 目录，合并..."
    if [ "$(ls -A logs_old)" ]; then
        mv logs_old/* logs/
    fi
    rmdir logs_old 2>/dev/null
fi

echo ""
echo "迁移完成！新的目录结构："
echo "data/"
echo "├── app.db          # 数据库文件"
echo "└── uploads/        # 上传文件"
echo "logs/"
echo "└── system.log      # 系统日志"
echo ""
echo "请重启应用以使用新的配置"
