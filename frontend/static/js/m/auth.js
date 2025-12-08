// 认证相关的 JavaScript 代码

// 显示提示信息
function showAlert(message, type = 'error') {
    const alertDiv = document.getElementById('alert');
    if (alertDiv) {
        alertDiv.textContent = message;
        alertDiv.className = `alert alert-${type} show`;
        
        // 3秒后自动隐藏
        setTimeout(() => {
            alertDiv.classList.remove('show');
        }, 3000);
    }
}

// 更新用户界面显示
function updateUserUI(userData) {
    const userName = document.getElementById('userName');
    const loginBtn = document.getElementById('loginBtn');
    const logoutBtn = document.getElementById('logoutBtn');
    
    if (userData.authenticated) {
        if (userName) {
            // 根据角色显示不同图标和文本
            if (userData.role === 'admin') {
                userName.innerHTML = '<i class="bi bi-person-badge me-1"></i>' + userData.username + ' <span class="badge bg-danger">管理员</span>';
            } else {
                userName.innerHTML = '<i class="bi bi-person-circle me-1"></i>' + userData.username;
            }
        }
        // 显示登出按钮，隐藏登录按钮
        if (loginBtn) loginBtn.style.display = 'none';
        if (logoutBtn) logoutBtn.style.display = 'block';
    } else {
        if (userName) {
            userName.innerHTML = '<i class="bi bi-person me-1"></i>游客';
        }
        // 显示登录按钮，隐藏登出按钮
        if (loginBtn) loginBtn.style.display = 'block';
        if (logoutBtn) logoutBtn.style.display = 'none';
    }
}

// 登录表单处理
document.addEventListener('DOMContentLoaded', function() {
    // 检查登录状态
    checkLoginStatus();
    const loginForm = document.getElementById('loginForm');
    const loginBtn = document.getElementById('loginBtn');
    
    if (loginForm) {
        loginForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const username = document.getElementById('username').value.trim();
            const password = document.getElementById('password').value;
            
            // 验证输入
            if (!username || !password) {
                showAlert('请输入用户名和密码', 'error');
                return;
            }
            
            // 禁用按钮，防止重复提交
            loginBtn.disabled = true;
            loginBtn.textContent = '登录中...';
            
            try {
                const response = await fetch('/auth/login', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        username: username,
                        password: password
                    })
                });
                
                const data = await response.json();
                
                if (response.ok && data.success) {
                    showAlert('登录成功！正在跳转...', 'success');
                    // 延迟跳转，让用户看到成功消息
                    setTimeout(() => {
                        window.location.href = '/';
                    }, 1000);
                } else {
                    showAlert(data.error || '登录失败，请检查用户名和密码', 'error');
                    loginBtn.disabled = false;
                    loginBtn.textContent = '登录';
                }
            } catch (error) {
                console.error('登录错误:', error);
                showAlert('网络错误，请稍后重试', 'error');
                loginBtn.disabled = false;
                loginBtn.textContent = '登录';
            }
        });
    }
    
    // 注册链接处理
    const registerLink = document.getElementById('registerLink');
    if (registerLink) {
        registerLink.addEventListener('click', function(e) {
            e.preventDefault();
            showRegisterModal();
        });
    }
    
    // 登出按钮处理
    const logoutBtn = document.getElementById('logoutBtn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', function(e) {
            e.preventDefault();
            logout();
        });
    }
});

// 显示注册模态框（简易版）
function showRegisterModal() {
    const username = prompt('请输入用户名（3-20个字符）:');
    if (!username || username.length < 3 || username.length > 20) {
        if (username !== null) {
            alert('用户名长度必须在3-20个字符之间');
        }
        return;
    }
    
    const password = prompt('请输入密码（至少6个字符）:');
    if (!password || password.length < 6) {
        if (password !== null) {
            alert('密码长度至少为6个字符');
        }
        return;
    }
    
    const confirmPassword = prompt('请再次输入密码:');
    if (password !== confirmPassword) {
        alert('两次输入的密码不一致');
        return;
    }
    
    // 发送注册请求
    registerUser(username, password);
}

// 注册用户
async function registerUser(username, password) {
    try {
        const response = await fetch('/auth/register', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                username: username,
                password: password
            })
        });
        
        const data = await response.json();
        
        if (response.ok && data.success) {
            alert('注册成功！请使用新账户登录');
            // 可以自动填充用户名
            const usernameInput = document.getElementById('username');
            if (usernameInput) {
                usernameInput.value = username;
            }
        } else {
            alert(data.error || '注册失败，请稍后重试');
        }
    } catch (error) {
        console.error('注册错误:', error);
        alert('网络错误，请稍后重试');
    }
}

// 检查登录状态
async function checkLoginStatus() {
    try {
        const response = await fetch('/auth/status');
        const data = await response.json();
        
        // 更新用户界面
        updateUserUI(data);
        
        return data.authenticated;
    } catch (error) {
        console.error('检查登录状态错误:', error);
        updateUserUI({ authenticated: false });
        return false;
    }
}

// 登出
async function logout() {
    try {
        const response = await fetch('/auth/logout', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        const data = await response.json();
        
        if (data.success) {
            // 更新UI为游客状态
            updateUserUI({ authenticated: false });
            // 显示提示
            alert('已登出');
            // 刷新页面内容
            window.location.reload();
        }
    } catch (error) {
        console.error('登出错误:', error);
        alert('登出失败，请稍后重试');
    }
}