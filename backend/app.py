from flask import Flask, render_template, request, jsonify, send_file, session
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, login_user, login_required, current_user, logout_user
from werkzeug.security import generate_password_hash, check_password_hash
import os
from datetime import datetime
import logging
from config import Config

app = Flask(__name__)
app.config.from_object(Config)

# 初始化扩展
db = SQLAlchemy(app)
login_manager = LoginManager(app)
login_manager.login_view = 'auth.login'

# 配置日志
logging.basicConfig(
    filename='system.log',
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

# 用户模型
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    role = db.Column(db.String(20), default='user')  # user, admin
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# 主页路由
@app.route('/')
def index():
    return render_template('index.html')

# 初始化数据库
@app.before_first_request
def create_tables():
    db.create_all()
    
    # 创建默认管理员账户（仅当不存在时）
    if not User.query.filter_by(username='admin').first():
        admin = User(username='admin', role='admin')
        admin.set_password('secure_admin_password_123')  # 实际部署时应修改
        db.session.add(admin)
        db.session.commit()
        logging.info("Default admin account created")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)