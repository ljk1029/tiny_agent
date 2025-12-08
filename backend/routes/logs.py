from flask import Blueprint, jsonify, current_app
from flask_login import login_required, current_user
import os
import json
import random
from datetime import datetime, timedelta
import logging

logs_bp = Blueprint('logs', __name__)

@logs_bp.route('/system', methods=['GET'])
@login_required
def get_system_logs():
    # 仅管理员可以访问完整日志
    if current_user.role != 'admin':
        return jsonify({'error': '权限不足'}), 403
    
    # 日志文件在 logs 目录下
    log_file = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), 'logs', 'system.log')
    logs = []
    
    if os.path.exists(log_file):
        with open(log_file, 'r') as f:
            for line in f.readlines()[-100:]:  # 只读取最后100行
                try:
                    # 解析日志行
                    parts = line.split(' - ', 3)
                    if len(parts) == 4:
                        timestamp_str = parts[0].strip()
                        level = parts[2].strip()
                        message = parts[3].strip()
                        
                        # 转换时间戳
                        timestamp = datetime.strptime(timestamp_str, '%Y-%m-%d %H:%M:%S,%f')
                        
                        logs.append({
                            'timestamp': timestamp.isoformat(),
                            'level': level,
                            'message': message
                        })
                except Exception as e:
                    continue
    
    return jsonify({
        'logs': logs[::-1],  # 倒序显示，最新的在前
        'total': len(logs),
        'access_level': current_user.role
    })

@logs_bp.route('/traffic', methods=['GET'])
@login_required
def get_traffic_data():
    # 模拟流量数据
    now = datetime.now()
    traffic_data = {
        'labels': [(now - timedelta(hours=i)).strftime('%H:%M') for i in range(24, 0, -1)],
        'datasets': [
            {
                'label': 'API请求',
                'data': [random.randint(50, 300) for _ in range(24)],
                'borderColor': 'rgb(75, 192, 192)',
                'tension': 0.1
            },
            {
                'label': '文件处理',
                'data': [random.randint(10, 100) for _ in range(24)],
                'borderColor': 'rgb(255, 99, 132)',
                'tension': 0.1
            }
        ]
    }
    
    return jsonify(traffic_data)