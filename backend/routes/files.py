from flask import Blueprint, request, jsonify, send_from_directory, current_app
from flask_login import current_user
import os
import logging
from datetime import datetime
from werkzeug.utils import secure_filename
from utils.ai_providers import process_with_ai

files_bp = Blueprint('files', __name__)

@files_bp.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': '没有文件上传'}), 400
    
    file = request.files['file']
    ai_provider = request.form.get('ai_provider', 'openai')
    task_type = request.form.get('task_type', 'summarize')
    
    if file.filename == '':
        return jsonify({'error': '没有选择文件'}), 400
    
    # 验证文件扩展名
    if not allowed_file(file.filename):
        return jsonify({'error': '不支持的文件类型'}), 400
    
    # 保存文件
    filename = secure_filename(file.filename)
    filepath = os.path.join(current_app.config['UPLOAD_FOLDER'], filename)
    file.save(filepath)
    
    # 记录操作
    log_message = f"文件上传: {filename} (用户: {current_user.username if current_user.is_authenticated else '匿名'})"
    logging.info(log_message)
    
    # 使用AI处理文件
    try:
        result = process_with_ai(filepath, ai_provider, task_type)
        return jsonify({
            'success': True,
            'result': result,
            'filename': filename
        })
    except Exception as e:
        logging.error(f"AI处理失败: {str(e)}")
        return jsonify({'error': f'处理失败: {str(e)}'}), 500

@files_bp.route('/list', methods=['GET'])
def list_files():
    """列出所有已上传的文件"""
    try:
        upload_folder = current_app.config['UPLOAD_FOLDER']
        if not os.path.exists(upload_folder):
            return jsonify({'files': []})
        
        files = []
        for filename in os.listdir(upload_folder):
            file_path = os.path.join(upload_folder, filename)
            if os.path.isfile(file_path):
                # 获取文件信息
                stat = os.stat(file_path)
                files.append({
                    'name': filename,
                    'size': stat.st_size,
                    'modified': datetime.fromtimestamp(stat.st_mtime).strftime('%Y-%m-%d %H:%M:%S')
                })
        
        # 按修改时间排序，最新的在前
        files.sort(key=lambda x: x['modified'], reverse=True)
        
        return jsonify({'files': files, 'total': len(files)})
    except Exception as e:
        logging.error(f"列出文件失败: {str(e)}")
        return jsonify({'error': str(e)}), 500

@files_bp.route('/download/<filename>')
def download_file(filename):
    # 验证文件是否存在
    file_path = os.path.join(current_app.config['UPLOAD_FOLDER'], secure_filename(filename))
    if not os.path.exists(file_path):
        return jsonify({'error': '文件不存在'}), 404
    
    # 记录下载
    log_message = f"文件下载: {filename} (用户: {current_user.username if current_user.is_authenticated else '匿名'})"
    logging.info(log_message)
    
    return send_from_directory(current_app.config['UPLOAD_FOLDER'], filename, as_attachment=True)

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in current_app.config['ALLOWED_EXTENSIONS']