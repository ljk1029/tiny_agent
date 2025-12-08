"""
查看数据库内容的工具脚本
"""
from app import app
from database import db, User

def view_database():
    with app.app_context():
        # 查询所有用户
        users = User.query.all()
        
        if not users:
            print("数据库中没有用户")
            return
        
        # 打印表格
        print("\n" + "="*70)
        print(" "*25 + "数据库用户列表")
        print("="*70)
        print(f"{'ID':<5} {'用户名':<15} {'角色':<10} {'密码哈希(前30字符)':<30}")
        print("-"*70)
        
        for user in users:
            print(f"{user.id:<5} {user.username:<15} {user.role:<10} {user.password_hash[:30]}...")
        
        print("-"*70)
        print(f"\n总计: {len(users)} 个用户\n")

if __name__ == '__main__':
    view_database()
