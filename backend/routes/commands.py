from flask import Blueprint, request, jsonify, current_app
from flask_login import login_required, current_user
import subprocess
import json
import re
import logging
import os

commands_bp = Blueprint('commands', __name__)

# 安全命令白名单（会在执行时动态获取上传目录路径）
def get_safe_commands():
    upload_folder = current_app.config.get('UPLOAD_FOLDER', 'uploads')
    return {
        'system_info': 'uname -a',
        'disk_usage': 'df -h /',
        'memory_usage': 'free -h',
        'cpu_load': "top -bn1 | grep 'Cpu(s)'",
        'list_services': 'systemctl list-units --type=service --state=running',
        'check_network': 'netstat -tulpn',
        'list_files': f'ls -lah "{upload_folder}"'
    }

@commands_bp.route('/execute', methods=['POST'])
@login_required
def execute_command():
    # 仅管理员可以执行命令
    if current_user.role != 'admin':
        return jsonify({'error': '权限不足'}), 403
    
    data = request.json
    command_key = data.get('command')
    
    SAFE_COMMANDS = get_safe_commands()
    if not command_key or command_key not in SAFE_COMMANDS:
        return jsonify({'error': '无效的命令'}), 400
    
    command = SAFE_COMMANDS[command_key]
    
    try:
        # 记录命令执行
        log_message = f"命令执行: {command_key} (用户: {current_user.username})"
        logging.info(log_message)
        
        # 执行命令
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            timeout=10  # 10秒超时
        )
        
        # 清理输出（移除ANSI转义码）
        clean_stdout = re.sub(r'\x1b$$[0-9;]*m', '', result.stdout)
        clean_stderr = re.sub(r'\x1b$$[0-9;]*m', '', result.stderr)
        
        return jsonify({
            'success': True,
            'command': command_key,
            'stdout': clean_stdout,
            'stderr': clean_stderr,
            'returncode': result.returncode
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@commands_bp.route('/available', methods=['GET'])
@login_required
def get_available_commands():
    # 确保命令列表可用（检查上传目录是否存在）
    SAFE_COMMANDS = get_safe_commands()
    
    return jsonify({
        'commands': [
            {'key': 'system_info', 'name': '系统信息', 'description': '显示操作系统内核信息'},
            {'key': 'disk_usage', 'name': '磁盘使用', 'description': '显示根分区磁盘使用情况'},
            {'key': 'memory_usage', 'name': '内存使用', 'description': '显示内存使用情况'},
            {'key': 'cpu_load', 'name': 'CPU负载', 'description': '显示当前CPU负载'},
            {'key': 'list_services', 'name': '运行服务', 'description': '列出所有运行中的系统服务'},
            {'key': 'check_network', 'name': '网络连接', 'description': '显示活动网络连接'},
            {'key': 'list_files', 'name': '上传文件列表', 'description': '列出最近上传的文件'}
        ]
    })