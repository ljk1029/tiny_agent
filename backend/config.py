import os
from datetime import timedelta

class Config:
    # 项目根目录（backend 的上一级）
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-key-please-change-in-production'
    
    # 数据库文件放在根目录的 data 文件夹
    SQLALCHEMY_DATABASE_URI = f"sqlite:///{os.path.join(BASE_DIR, 'data', 'app.db')}"
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # 上传文件放在根目录的 data/uploads 文件夹
    UPLOAD_FOLDER = os.path.join(BASE_DIR, 'data', 'uploads')
    
    # 日志文件放在根目录的 logs 文件夹
    LOG_FOLDER = os.path.join(BASE_DIR, 'logs')
    
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB 最大文件大小
    
    # 允许的文件扩展名
    ALLOWED_EXTENSIONS = {'pdf', 'docx', 'txt', 'log', 'csv', 'xlsx', 'png', 'jpg', 'jpeg'}
    
    # AI服务配置
    OPENAI_API_KEY = os.environ.get('OPENAI_API_KEY')
    CLAUDE_API_KEY = os.environ.get('CLAUDE_API_KEY')
    
    # 登录配置
    PERMANENT_SESSION_LIFETIME = timedelta(minutes=30)
    
    @staticmethod
    def init_app(app):
        # 确保上传和日志目录存在
        os.makedirs(Config.UPLOAD_FOLDER, exist_ok=True)
        os.makedirs(Config.LOG_FOLDER, exist_ok=True)