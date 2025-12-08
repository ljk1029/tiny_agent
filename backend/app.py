from flask import Flask, render_template, request, jsonify, send_file, session
from flask_login import LoginManager, login_user, login_required, current_user, logout_user
import os
from datetime import datetime
import logging
from config import Config
from database import db, User

# 配置 Flask 应用，指定前端目录
app = Flask(__name__, 
            template_folder='../frontend',  # 模板目录
            static_folder='../frontend/static')  # 静态文件目录
app.config.from_object(Config)

# 配置 session
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
app.config['SESSION_COOKIE_SECURE'] = False  # 开发环境设为 False
app.config['SESSION_COOKIE_HTTPONLY'] = True

# 初始化扩展
db.init_app(app)
login_manager = LoginManager(app)
login_manager.login_view = 'auth.login'

# 初始化配置（创建必要的目录）
Config.init_app(app)

# 配置日志（使用 Config 中定义的 LOG_FOLDER）
log_file = os.path.join(app.config['LOG_FOLDER'], 'system.log')
logging.basicConfig(
    filename=log_file,
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# 路由注册
from routes.auth import auth_bp
from routes.files import files_bp
from routes.logs import logs_bp
from routes.commands import commands_bp

app.register_blueprint(auth_bp, url_prefix='/auth')
app.register_blueprint(files_bp, url_prefix='/files')
app.register_blueprint(logs_bp, url_prefix='/logs')
app.register_blueprint(commands_bp, url_prefix='/commands')

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# 主页路由
@app.route('/')
def index():
    return render_template('index.html')

# 初始化数据库
def init_db():
    """初始化数据库和默认数据"""
    with app.app_context():
        db.create_all()
        
        # 创建默认管理员账户（仅当不存在时）
        if not User.query.filter_by(username='admin').first():
            admin = User(username='admin', role='admin')
            admin.set_password('admin_pw_123')  # 实际部署时应修改
            db.session.add(admin)
            db.session.commit()
            logging.info("Default admin account created")

if __name__ == '__main__':
    init_db()  # 启动前初始化数据库
    app.run(host='0.0.0.0', port=5000, debug=True)