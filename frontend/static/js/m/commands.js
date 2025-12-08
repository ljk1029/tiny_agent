// 命令执行相关功能

let availableCommands = [];

document.addEventListener('DOMContentLoaded', function() {
    // 先检查权限，权限通过后会自动加载命令列表
    checkCommandAccess();
    
    // 登录按钮处理
    const loginForCommands = document.getElementById('loginForCommands');
    if (loginForCommands) {
        loginForCommands.addEventListener('click', function() {
            window.location.href = '/auth/login';
        });
    }
});

// 检查命令访问权限
async function checkCommandAccess() {
    try {
        const response = await fetch('/auth/status');
        const data = await response.json();
        
        const commandSection = document.getElementById('commandContent');
        const accessStatus = document.getElementById('commandAccessStatus');
        
        if (data.authenticated && data.role === 'admin') {
            // 管理员用户，显示命令界面
            if (accessStatus) {
                accessStatus.textContent = '管理员';
                accessStatus.className = 'badge bg-success';
            }
            displayCommandInterface();
            // 加载命令列表
            loadAvailableCommands();
        } else if (data.authenticated) {
            // 普通用户
            if (accessStatus) {
                accessStatus.textContent = '权限不足';
                accessStatus.className = 'badge bg-warning';
            }
            if (commandSection) {
                commandSection.innerHTML = `
                    <div class="text-center py-5">
                        <i class="bi bi-shield-exclamation display-1 text-warning mb-3"></i>
                        <h4>需要管理员权限</h4>
                        <p class="text-muted">命令执行功能仅限管理员使用</p>
                    </div>
                `;
            }
        }
    } catch (error) {
        console.error('检查权限错误:', error);
    }
}

// 显示命令界面
function displayCommandInterface() {
    const commandSection = document.getElementById('commandContent');
    if (commandSection) {
        commandSection.innerHTML = `
            <div class="row">
                <div class="col-md-6">
                    <h6>选择命令</h6>
                    <div id="commandList" class="list-group mb-3">
                        <div class="text-center py-3">
                            <div class="spinner-border spinner-border-sm" role="status">
                                <span class="visually-hidden">加载中...</span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <h6>执行结果</h6>
                    <div id="commandOutput" class="border rounded p-3 bg-light" style="min-height: 300px; font-family: monospace; white-space: pre-wrap;">
                        <span class="text-muted">等待命令执行...</span>
                    </div>
                </div>
            </div>
        `;
    }
}

// 加载可用命令列表
async function loadAvailableCommands() {
    try {
        const response = await fetch('/commands/available');
        const data = await response.json();
        
        if (data.commands && data.commands.length > 0) {
            availableCommands = data.commands;
            displayCommandList(data.commands);
        }
    } catch (error) {
        console.error('加载命令列表错误:', error);
    }
}

// 显示命令列表
function displayCommandList(commands) {
    const commandList = document.getElementById('commandList');
    if (!commandList) return;
    
    commandList.innerHTML = commands.map(cmd => `
        <button class="list-group-item list-group-item-action" onclick="executeCommand('${cmd.key}')">
            <div class="d-flex w-100 justify-content-between">
                <h6 class="mb-1">${cmd.name}</h6>
                <small class="text-success">点击执行</small>
            </div>
            <p class="mb-1 text-muted small">${cmd.description}</p>
        </button>
    `).join('');
}

// 执行命令
async function executeCommand(commandKey) {
    const commandOutput = document.getElementById('commandOutput');
    if (!commandOutput) return;
    
    commandOutput.innerHTML = '<div class="text-center"><div class="spinner-border spinner-border-sm"></div> 执行中...</div>';
    
    try {
        const response = await fetch('/commands/execute', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                command: commandKey
            })
        });
        
        const data = await response.json();
        
        if (response.ok && data.success) {
            let output = '';
            
            if (data.stdout) {
                output += '<strong class="text-success">输出:</strong>\n' + data.stdout + '\n';
            }
            
            if (data.stderr) {
                output += '<strong class="text-danger">错误:</strong>\n' + data.stderr + '\n';
            }
            
            output += '\n<strong>返回码:</strong> ' + data.returncode;
            
            commandOutput.innerHTML = output || '命令执行完成，无输出';
        } else {
            commandOutput.innerHTML = `<span class="text-danger">错误: ${data.error || '执行失败'}</span>`;
        }
    } catch (error) {
        console.error('执行命令错误:', error);
        commandOutput.innerHTML = '<span class="text-danger">网络错误，请稍后重试</span>';
    }
}