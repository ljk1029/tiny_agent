from flask import Blueprint, request, jsonify, render_template, redirect, url_for
from flask_login import login_user, logout_user, login_required, current_user
import logging
from database import db, User

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    """用户登录"""
    if request.method == 'GET':
        return render_template('login.html')
    
    # POST 请求处理
    data = request.json if request.is_json else request.form
    username = data.get('username')
    password = data.get('password')
    
    if not username or not password:
        return jsonify({'error': '用户名和密码不能为空'}), 400
    
    # 查询用户
    user = User.query.filter_by(username=username).first()
    
    if user and user.check_password(password):
        login_user(user)
        logging.info(f"用户登录成功: {username}")
        
        if request.is_json:
            return jsonify({
                'success': True,
                'username': user.username,
                'role': user.role
            })
        else:
            return redirect(url_for('index'))
    else:
        logging.warning(f"登录失败: {username}")
        if request.is_json:
            return jsonify({'error': '用户名或密码错误'}), 401
        else:
            return render_template('login.html', error='用户名或密码错误')

@auth_bp.route('/register', methods=['POST'])
def register():
    """用户注册"""
    data = request.json if request.is_json else request.form
    username = data.get('username')
    password = data.get('password')
    
    if not username or not password:
        return jsonify({'error': '用户名和密码不能为空'}), 400
    
    # 验证用户名长度
    if len(username) < 3 or len(username) > 20:
        return jsonify({'error': '用户名长度必须在3-20个字符之间'}), 400
    
    # 验证密码强度
    if len(password) < 6:
        return jsonify({'error': '密码长度至少为6个字符'}), 400
    
    # 检查用户是否已存在
    if User.query.filter_by(username=username).first():
        return jsonify({'error': '用户名已存在'}), 409
    
    # 创建新用户
    try:
        new_user = User(username=username, role='user')
        new_user.set_password(password)
        db.session.add(new_user)
        db.session.commit()
        
        logging.info(f"新用户注册: {username}")
        return jsonify({
            'success': True,
            'message': '注册成功',
            'username': username
        }), 201
    except Exception as e:
        db.session.rollback()
        logging.error(f"注册失败: {str(e)}")
        return jsonify({'error': '注册失败，请稍后重试'}), 500

@auth_bp.route('/logout', methods=['POST', 'GET'])
@login_required
def logout():
    """用户登出"""
    username = current_user.username
    logout_user()
    logging.info(f"用户登出: {username}")
    
    if request.is_json:
        return jsonify({'success': True, 'message': '登出成功'})
    else:
        return redirect(url_for('auth.login'))

@auth_bp.route('/status', methods=['GET'])
def status():
    """检查登录状态"""
    if current_user.is_authenticated:
        return jsonify({
            'authenticated': True,
            'username': current_user.username,
            'role': current_user.role
        })
    else:
        return jsonify({
            'authenticated': False
        })

@auth_bp.route('/change-password', methods=['POST'])
@login_required
def change_password():
    """修改密码"""
    data = request.json
    old_password = data.get('old_password')
    new_password = data.get('new_password')
    
    if not old_password or not new_password:
        return jsonify({'error': '旧密码和新密码不能为空'}), 400
    
    if len(new_password) < 6:
        return jsonify({'error': '新密码长度至少为6个字符'}), 400
    
    # 验证旧密码
    if not current_user.check_password(old_password):
        return jsonify({'error': '旧密码错误'}), 401
    
    # 更新密码
    try:
        current_user.set_password(new_password)
        db.session.commit()
        
        logging.info(f"用户修改密码: {current_user.username}")
        return jsonify({'success': True, 'message': '密码修改成功'})
    except Exception as e:
        db.session.rollback()
        logging.error(f"修改密码失败: {str(e)}")
        return jsonify({'error': '修改密码失败'}), 500
