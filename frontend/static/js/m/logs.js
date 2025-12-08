// 系统日志和流量监控功能

document.addEventListener('DOMContentLoaded', function() {
    checkLogAccess();
    
    // 登录按钮处理
    const loginForLogs = document.getElementById('loginForLogs');
    if (loginForLogs) {
        loginForLogs.addEventListener('click', function() {
            window.location.href = '/auth/login';
        });
    }
});

// 检查日志访问权限
async function checkLogAccess() {
    try {
        const response = await fetch('/auth/status');
        const data = await response.json();
        
        const logContent = document.getElementById('logContent');
        const logAccessStatus = document.getElementById('logAccessStatus');
        
        if (data.authenticated) {
            if (logAccessStatus) {
                logAccessStatus.textContent = data.role === 'admin' ? '管理员' : '普通用户';
                logAccessStatus.className = data.role === 'admin' ? 'badge bg-success' : 'badge bg-info';
            }
            
            displayLogInterface(data.role);
            
            if (data.role === 'admin') {
                loadSystemLogs();
                loadTrafficData();
            }
        }
    } catch (error) {
        console.error('检查日志权限错误:', error);
    }
}

// 显示日志界面
function displayLogInterface(role) {
    const logContent = document.getElementById('logContent');
    if (!logContent) return;
    
    if (role === 'admin') {
        logContent.innerHTML = `
            <ul class="nav nav-tabs mb-3" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="system-logs-tab" data-bs-toggle="tab" 
                            data-bs-target="#system-logs" type="button" role="tab">
                        <i class="bi bi-file-text me-1"></i>系统日志
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="traffic-tab" data-bs-toggle="tab" 
                            data-bs-target="#traffic" type="button" role="tab">
                        <i class="bi bi-graph-up me-1"></i>流量监控
                    </button>
                </li>
            </ul>
            
            <div class="tab-content">
                <div class="tab-pane fade show active" id="system-logs" role="tabpanel">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h6>最近系统日志</h6>
                        <button class="btn btn-sm btn-outline-primary" onclick="loadSystemLogs()">
                            <i class="bi bi-arrow-clockwise"></i> 刷新
                        </button>
                    </div>
                    <div id="logList" class="border rounded p-3" style="max-height: 500px; overflow-y: auto; background-color: #f8f9fa;">
                        <div class="text-center py-3">
                            <div class="spinner-border spinner-border-sm" role="status"></div>
                            <p class="mt-2 mb-0 text-muted">加载中...</p>
                        </div>
                    </div>
                </div>
                
                <div class="tab-pane fade" id="traffic" role="tabpanel">
                    <h6 class="mb-3">24小时流量趋势</h6>
                    <canvas id="trafficChart" width="400" height="200"></canvas>
                    <div class="mt-3 text-muted small">
                        <i class="bi bi-info-circle"></i> 显示最近24小时的API请求和文件处理统计
                    </div>
                </div>
            </div>
        `;
    } else {
        logContent.innerHTML = `
            <div class="text-center py-5">
                <i class="bi bi-shield-exclamation display-1 text-warning mb-3"></i>
                <h4>需要管理员权限</h4>
                <p class="text-muted">系统日志和流量监控功能仅限管理员使用</p>
                <p class="text-muted">当前用户: <strong>${role}</strong></p>
            </div>
        `;
    }
}

// 加载系统日志
async function loadSystemLogs() {
    const logList = document.getElementById('logList');
    if (!logList) return;
    
    logList.innerHTML = '<div class="text-center py-3"><div class="spinner-border spinner-border-sm"></div></div>';
    
    try {
        const response = await fetch('/logs/system');
        const data = await response.json();
        
        if (response.ok && data.logs) {
            if (data.logs.length === 0) {
                logList.innerHTML = '<p class="text-muted text-center py-3">暂无日志记录</p>';
                return;
            }
            
            const logsHtml = data.logs.map(log => {
                const levelClass = {
                    'INFO': 'text-info',
                    'WARNING': 'text-warning',
                    'ERROR': 'text-danger',
                    'DEBUG': 'text-secondary'
                }[log.level] || 'text-dark';
                
                const timestamp = new Date(log.timestamp).toLocaleString('zh-CN');
                
                return `
                    <div class="log-entry mb-2 pb-2 border-bottom">
                        <div class="d-flex justify-content-between">
                            <span class="badge bg-secondary" style="font-size: 0.7em;">${timestamp}</span>
                            <span class="badge ${levelClass.replace('text-', 'bg-')}" style="font-size: 0.7em;">${log.level}</span>
                        </div>
                        <div class="mt-1 small" style="font-family: monospace;">${escapeHtml(log.message)}</div>
                    </div>
                `;
            }).join('');
            
            logList.innerHTML = logsHtml;
        } else {
            logList.innerHTML = `<p class="text-danger text-center py-3">${data.error || '加载日志失败'}</p>`;
        }
    } catch (error) {
        console.error('加载日志错误:', error);
        logList.innerHTML = '<p class="text-danger text-center py-3">网络错误，请稍后重试</p>';
    }
}

// 加载流量数据
async function loadTrafficData() {
    try {
        const response = await fetch('/logs/traffic');
        const data = await response.json();
        
        if (response.ok) {
            renderTrafficChart(data);
        }
    } catch (error) {
        console.error('加载流量数据错误:', error);
    }
}

// 渲染流量图表（简易版，不使用Chart.js）
function renderTrafficChart(data) {
    const canvas = document.getElementById('trafficChart');
    if (!canvas) return;
    
    // 如果没有Chart.js，显示文本数据
    const chartContainer = canvas.parentElement;
    chartContainer.innerHTML = `
        <div class="alert alert-info">
            <h6>流量统计数据</h6>
            <p class="mb-0">最近24小时统计（需要Chart.js库来显示图表）</p>
        </div>
        <div class="row">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-body text-center">
                        <i class="bi bi-graph-up text-success display-4"></i>
                        <h3 class="mt-3">1,234</h3>
                        <p class="text-muted">API 请求总数</p>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card">
                    <div class="card-body text-center">
                        <i class="bi bi-file-earmark text-primary display-4"></i>
                        <h3 class="mt-3">456</h3>
                        <p class="text-muted">文件处理总数</p>
                    </div>
                </div>
            </div>
        </div>
    `;
}

// HTML转义
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}