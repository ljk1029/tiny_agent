// 文件处理相关功能

document.addEventListener('DOMContentLoaded', function() {
    const fileUploadForm = document.getElementById('fileUploadForm');
    const fileInput = document.getElementById('fileInput');
    const uploadBtn = document.getElementById('uploadBtn');
    const fileResult = document.getElementById('fileResult');
    
    // 加载已上传的文件列表
    loadFileList();
    
    if (fileUploadForm) {
        fileUploadForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            
            if (!fileInput.files || !fileInput.files[0]) {
                showFileMessage('请选择要上传的文件', 'warning');
                return;
            }
            
            const file = fileInput.files[0];
            const aiProvider = document.getElementById('aiProvider')?.value || 'openai';
            const taskType = document.getElementById('taskType')?.value || 'summarize';
            
            // 创建 FormData
            const formData = new FormData();
            formData.append('file', file);
            formData.append('ai_provider', aiProvider);
            formData.append('task_type', taskType);
            
            // 禁用按钮
            uploadBtn.disabled = true;
            uploadBtn.textContent = '上传中...';
            
            try {
                const response = await fetch('/files/upload', {
                    method: 'POST',
                    body: formData
                });
                
                const data = await response.json();
                
                if (response.ok && data.success) {
                    showFileMessage('文件上传成功！', 'success');
                    displayFileResult(data);
                    // 重新加载文件列表
                    loadFileList();
                    // 清空文件选择
                    fileInput.value = '';
                } else {
                    showFileMessage(data.error || '上传失败', 'danger');
                }
            } catch (error) {
                console.error('上传错误:', error);
                showFileMessage('网络错误，请稍后重试', 'danger');
            } finally {
                uploadBtn.disabled = false;
                uploadBtn.textContent = '上传并处理';
            }
        });
    }
});

// 加载文件列表
async function loadFileList() {
    try {
        const response = await fetch('/files/list');
        const data = await response.json();
        
        if (response.ok && data.files) {
            displayFileList(data.files);
        }
    } catch (error) {
        console.error('加载文件列表错误:', error);
    }
}

// 显示文件列表
function displayFileList(files) {
    const fileListSection = document.getElementById('fileListSection');
    if (!fileListSection) return;
    
    if (files.length === 0) {
        fileListSection.innerHTML = `
            <div class="alert alert-info">
                <i class="bi bi-info-circle me-2"></i>暂无上传的文件
            </div>
        `;
        return;
    }
    
    const fileListHtml = `
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>文件名</th>
                        <th>大小</th>
                        <th>上传时间</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    ${files.map(file => `
                        <tr>
                            <td><i class="bi bi-file-earmark me-2"></i>${escapeHtml(file.name)}</td>
                            <td>${formatFileSize(file.size)}</td>
                            <td>${file.modified}</td>
                            <td>
                                <a href="/files/download/${encodeURIComponent(file.name)}" 
                                   class="btn btn-sm btn-primary" 
                                   download>
                                    <i class="bi bi-download me-1"></i>下载
                                </a>
                            </td>
                        </tr>
                    `).join('')}
                </tbody>
            </table>
        </div>
        <p class="text-muted mt-2">共 ${files.length} 个文件</p>
    `;
    
    fileListSection.innerHTML = fileListHtml;
}

// 格式化文件大小
function formatFileSize(bytes) {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
}

// HTML转义
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function showFileMessage(message, type) {
    const fileResult = document.getElementById('fileResult');
    if (fileResult) {
        fileResult.innerHTML = `
            <div class="alert alert-${type} alert-dismissible fade show" role="alert">
                ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        `;
        
        // 成功消息5秒后自动消失，错误消息保持显示
        if (type === 'success') {
            setTimeout(() => {
                const alert = fileResult.querySelector('.alert');
                if (alert) {
                    const bsAlert = new bootstrap.Alert(alert);
                    bsAlert.close();
                }
            }, 5000);
        }
    }
}

function displayFileResult(data) {
    const fileResult = document.getElementById('fileResult');
    if (fileResult && data.result) {
        fileResult.innerHTML = `
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <h6>处理完成</h6>
                <p><strong>文件名:</strong> ${escapeHtml(data.filename)}</p>
                <p><strong>状态:</strong> ${data.result.status || '完成'}</p>
                <p class="mb-0"><strong>消息:</strong> ${data.result.message || '处理成功'}</p>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        `;
        
        // 10秒后自动隐藏
        setTimeout(() => {
            const alert = fileResult.querySelector('.alert');
            if (alert) {
                const bsAlert = new bootstrap.Alert(alert);
                bsAlert.close();
            }
        }, 10000);
    }
}