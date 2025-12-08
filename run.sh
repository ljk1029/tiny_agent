#!/bin/bash
# 启动 Tiny Agent 应用

cd "$(dirname "$0")"

# 激活虚拟环境（如果存在）
if [ -d "venv" ]; then
    source venv/bin/activate
    echo "✓ 虚拟环境已激活"
else
    echo "⚠ 虚拟环境不存在，使用系统 Python"
fi

# 进入 backend 目录
cd backend

# 启动应用
echo "🚀 正在启动 Tiny Agent..."
python3 app.py
