#Requires -Version 7.0
<#
.SYNOPSIS
    Picot Desktop GUI 汉化脚本（完整版）
.DESCRIPTION
    将 Picot Desktop GUI 的英文界面全面汉化为中文，不影响功能正常使用。
    - HTML 文件：全文替换（安全）
    - JS 文件：仅替换长字符串（避免与代码标识符冲突）
    幂等设计——已汉化的不会被二次修改。
.USAGE
    .\picot-han.ps1          # 执行汉化
    .\picot-han.ps1 -Check  # 预览
    .\picot-han.ps1 -Reset  # 从备份还原
#>

param([switch]$Check, [switch]$Reset)

$ErrorActionPreference = "Stop"
$publicDir = Join-Path $env:LOCALAPPDATA "Picot\public"
$backupDir = Join-Path $env:LOCALAPPDATA "Picot\.public-backup"

if (-not (Test-Path $publicDir)) { Write-Error "目录不存在: $publicDir"; exit 1 }

function Clear-DirectoryContents {
    param([Parameter(Mandatory)][string]$Path)
    Get-ChildItem -LiteralPath $Path -Force | Remove-Item -Recurse -Force
}

function Copy-DirectoryContents {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Destination
    )
    Get-ChildItem -LiteralPath $Source -Force | Copy-Item -Destination $Destination -Recurse -Force
}

# ── 备份/还原 ──
if ($Reset) {
    if (-not (Test-Path $backupDir)) { Write-Error "无备份"; exit 1 }
    Write-Host "还原备份..." -ForegroundColor Yellow
    # 清除当前内容，再把备份目录的内容铺回 public 根目录。
    # 不能直接 Copy-Item "$backupDir\" "$publicDir\" -Container，否则会生成 public\.public-backup。
    Clear-DirectoryContents -Path $publicDir
    Copy-DirectoryContents -Source $backupDir -Destination $publicDir
    Write-Host "已还原" -ForegroundColor Green; exit 0
}
if (-not (Test-Path $backupDir) -and -not $Check) {
    Write-Host "→ 创建备份..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Copy-DirectoryContents -Source $publicDir -Destination $backupDir
    Write-Host "备份: $backupDir`n" -ForegroundColor Green
}

# ── 完整翻译表（HTML + 安全场景适用） ──
$fullDict = @{
    # ── 原有翻译（保留不动） ──
    "Type a message, or use / to call a skill"                = "输入消息，或使用 / 调用技能"
    "Viewing historical session (read-only)"                   = "正在查看历史会话（只读）"
    "Waiting for current session to finish"                    = "等待当前会话完成"
    "Failed to load sessions. Pi runtime may be unavailable."  = "无法加载会话，Pi 运行时可能不可用。"
    "Disconnect Telegram from Picot?"                          = "从 Picot 断开 Telegram？"
    "Edit ~/.pi/agent/models.json to add"                      = "编辑 ~/.pi/agent/models.json 以添加"
    "Only the detected DM user is authorized."                 = "仅检测到的私信用户被授权。"
    "Failed to open session in its workspace process."         = "在工作区进程中打开会话失败。"
    "Delete all archived sessions"                             = "删除所有已归档的会话"
    "Export session as HTML file"                              = "将会话导出为 HTML 文件"
    "Open workspace in app"                                    = "在应用中打开工作区"
    "Choose app to open workspace"                             = "选择打开工作区的应用"
    "Open updates in settings"                                 = "在设置中打开更新"
    "No packages match your filters."                          = "没有符合条件的包。"
    "New session was cancelled"                                = "新会话已取消"
    "Starting new session"                                     = "正在创建新会话..."
    "No matching skills"                                       = "没有匹配的技能"
    "No saved sessions"                                        = "没有已保存的会话"
    "Conversation navigator"                                   = "对话导航器"
    "Save Raw Config"                                          = "保存原始配置"
    "Saved raw config."                                        = "原始配置已保存。"
    "Failed to load skills"                                    = "加载技能失败"
    "Failed to load packages"                                  = "加载包失败"
    "Failed to switch session"                                 = "切换会话失败"
    "Agent Configuration"                                      = "Agent 配置"
    "Agent config file"                                        = "Agent 配置文件"
    "Providers file"                                           = "提供商配置文件"
    "Unavailable (empty version)"                              = "不可用（版本为空）"
    "QR code unavailable"                                      = "二维码不可用"
    "Health check failed"                                      = "健康检查失败"
    "Key cannot be empty."                                     = "密钥不能为空。"
    "Install failed"                                           = "安装失败"
    "Uninstall failed"                                         = "卸载失败"
    "Delete archived sessions"                                 = "删除已归档的会话"
    "Telegram setup canceled."                                 = "取消 Telegram 设置。"
    "Checking health..."                                       = "正在检查健康状态..."
    "Copied!"                                                  = "已复制！"
    "Click to copy"                                            = "点击复制"
    "Download & install"                                       = "下载并安装"
    "Download &amp; install"                                   = "下载并安装"
    "Check for updates"                                        = "检查更新"
    "Show mobile QR code"                                      = "显示手机二维码"
    "Waiting for your Telegram DM"                             = "等待您的 Telegram 私信..."
    "Connect Telegram"                                         = "连接 Telegram"
    "Reconnect Telegram"                                       = "重新连接 Telegram"
    "Disconnect Telegram"                                      = "断开 Telegram"
    "Connected via Tailscale"                                  = "已连接（Tailscale）"
    "Connected via LAN"                                        = "已连接（局域网）"
    "Opening workspace..."                                     = "正在打开工作区..."
    "Unarchive session"                                        = "取消归档会话"
    "Archive session"                                          = "归档会话"
    "Parent directory"                                         = "上级目录"
    "Open in file manager"                                     = "在文件管理器中打开"
    "Search packages..."                                       = "搜索包..."
    "models.json docs"                                         = "models.json 文档"
    "Session cost"                                             = "会话费用"
    "Context usage"                                            = "上下文使用量"
    "Context Window"                                           = "上下文窗口"
    "Switch model"                                             = "切换模型"
    "Open on Mobile"                                           = "在手机上打开"
    "Mobile QR code"                                           = "手机二维码"
    "Loading packages..."                                      = "正在加载包..."
    "Loading sessions..."                                      = "正在加载会话..."
    "Checking Telegram"                                        = "正在检查 Telegram..."
    "Telegram connected."                                      = "Telegram 已连接。"
    "Telegram disconnected."                                   = "Telegram 已断开。"
    "Telegram doctor failed"                                   = "Telegram 诊断失败"
    "Show more"                                                = "显示更多"
    "Show less"                                                = "显示更少"
    "Agent Inbox"                                              = "Agent 收件箱"
    "Force Cancel"                                             = "强制取消"
    "Export HTML"                                              = "导出 HTML"
    "Welcome to Picot"                                         = "欢迎使用 Picot"
    "Auto-compaction"                                          = "自动压缩"
    "Thinking effort"                                          = "思考力度"
    "Reasoning depth"                                          = "推理深度"
    "Show thinking"                                            = "显示思考过程"
    "Require login"                                            = "需要登录"
    "Installed only"                                           = "仅显示已安装"
    "Sort packages"                                            = "排序包"
    "Health unknown"                                           = "健康状态未知"
    "Search..."                                                = "搜索..."
    "Search models"                                            = "搜索模型"
    "Connecting..."                                            = "正在连接..."
    "Checking..."                                              = "正在检查..."
    "Downloading..."                                           = "正在下载..."
    "Installing..."                                            = "正在安装..."
    "Loading..."                                               = "加载中..."
    "Aborted by user"                                          = "用户已中止"
    "Save failed"                                              = "保存失败"
    "Disconnect failed"                                        = "断开连接失败"
    "Unarchive"                                                = "取消归档"
    "New Chat"                                                 = "新建会话"
    "Super Agent"                                              = "超级 Agent"
    "Export"                                                   = "导出"
    "Compact"                                                  = "压缩"
    "Open folder as workspace"                                 = "打开文件夹作为工作区"
    "Settings"                                                 = "设置"
    "Appearance"                                               = "外观"
    "Protection"                                               = "保护"
    "Updates"                                                  = "更新"
    "Commands"                                                 = "命令"
    "Skills"                                                   = "技能"
    "Status"                                                   = "状态"
    "Files"                                                    = "文件"
    "Chat"                                                     = "聊天"
    "Agent"                                                    = "Agent"
    "Model"                                                    = "模型"
    "Faster"                                                   = "更快"
    "Smarter"                                                  = "更聪明"
    "Untitled"                                                 = "无标题"
    "Editor"                                                   = "编辑器"
    "Input"                                                    = "输入"
    "Save"                                                     = "保存"
    "Cancel"                                                   = "取消"
    "Close"                                                    = "关闭"
    "Open"                                                     = "打开"
    "Delete"                                                   = "删除"
    "Remove"                                                   = "移除"
    "Copy"                                                     = "复制"
    "Done"                                                     = "完成"
    "Error"                                                    = "错误"
    "Failed"                                                   = "失败"
    "Retry"                                                    = "重试"
    "Update"                                                   = "更新"
    "Install"                                                  = "安装"
    "Uninstall"                                                = "卸载"
    "Connected"                                                = "已连接"
    "Disconnected"                                             = "已断开"
    "Check now"                                                = "立即检查"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - HTML 界面元素（index.html）
    # ═══════════════════════════════════════════════════════════════
    "Clear search"                                                                  = "清除搜索"
    "Refresh sessions"                                                              = "刷新会话"
    "Toggle sidebar"                                                                = "切换侧边栏"
    "Choose app"                                                                    = "选择应用"
    "Toggle file browser"                                                           = "切换文件浏览器"
    "Attach image"                                                                  = "附加图片"
    "Voice input"                                                                   = "语音输入"
    "Send message"                                                                  = "发送消息"
    "Abort (Esc)"                                                                   = "中止（Esc）"
    "Type a message below to start chatting with Pi, or select a session from the sidebar." = "在下方输入消息开始与 Pi 聊天，或从侧边栏选择一个会话。"
    "/ Focus input"                                                                 = "/ 聚焦输入框"
    "Esc Abort"                                                                     = "Esc 中止"
    "New ↓"                                                                         = "新消息 ↓"
    "General"                                                                       = "通用"
    "Extensions"                                                                    = "扩展"
    "Usage"                                                                         = "使用统计"
    "Configuration"                                                                 = "配置"
    "Back to chat"                                                                  = "返回聊天"
    "Pi version"                                                                    = "Pi 版本"
    "Picot version"                                                                 = "Picot 版本"
    "更新 available"                                                               = "更新可用"
    "Update available"                                                              = "更新可用"
    "Browse Community Packages"                                                     = "浏览社区包"
    "Discover extensions, skills, themes, and prompts from the Pi ecosystem. 安装 with one click." = "发现来自 Pi 生态的扩展、技能、主题和提示词。一键安装。"
    "Discover extensions, skills, themes, and prompts from the Pi ecosystem. Install with one click." = "发现来自 Pi 生态的扩展、技能、主题和提示词。一键安装。"
    "Discover extensions, skills, themes, and prompts"                              = "发现扩展、技能、主题和提示词"
    "from the Pi ecosystem. 安装 with one click."                                   = "来自 Pi 生态。一键安装。"
    "from the Pi ecosystem. Install with one click."                                 = "来自 Pi 生态。一键安装。"
    "All"                                                                           = "全部"
    "Most downloads"                                                                = "最多下载"
    "Name (A–Z)"                                                                    = "名称（A–Z）"
    "Recently updated"                                                              = "最近更新"
    "Authentication"                                                                = "身份验证"
    "Keys are stored locally in"                                                    = "密钥本地存储在"
    "Insert example"                                                                = "插入示例"
    "Think off"                                                                     = "关闭思考"
    "Scan with your phone to open Picot on the same network"                        = "用手机扫描以在相同网络打开 Picot"
    "Generating QR code…"                                                          = "正在生成二维码…"
    "Generating QR code..."                                                         = "正在生成二维码..."
    "打开 Link"                                                                    = "打开链接"
    "LLM providers"                                                                 = "LLM 提供商"
    "Edit <code>~/.pi/agent/models.json</code> to add"                              = "编辑 <code>~/.pi/agent/models.json</code> 以添加"
    "custom providers (Ollama, vLLM, LM Studio, 打开AI-compatible proxies, 打开Router routing overrides, etc). See the" = "自定义提供商（Ollama、vLLM、LM Studio、与 OpenAI 兼容的代理、OpenRouter 路由覆盖等）。请参阅"
    "for the full schema. Changes are picked up immediately — no restart needed."    = "了解完整架构。更改会立即生效 — 无需重启。"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - settings/editors.js
    # ═══════════════════════════════════════════════════════════════
    "Loading providers…"                                                            = "正在加载提供商…"
    "Loading providers..."                                                          = "正在加载提供商..."
    "Failed to load providers."                                                     = "加载提供商失败。"
    "No providers known."                                                           = "没有已知的提供商。"
    "Failed to save config"                                                         = "保存配置失败"
    "Failed to save models.json"                                                    = "保存 models.json 失败"
    "Check health"                                                                  = "检查健康状态"
    "Set key"                                                                       = "设置密钥"
    "Select"                                                                        = "选择"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - app-updater.js
    # ═══════════════════════════════════════════════════════════════
    "Checking for updates..."                                                       = "正在检查更新…"
    "You're on the latest version."                                                 = "已是最新版本。"
    "Update installed. Restarting..."                                               = "更新已安装。正在重启…"
    "Dev build — updates are checked only in packaged releases."                    = "开发版 — 仅在打包版本中检查更新。"
    "Auto-updates are only available in the desktop app."                           = "自动更新仅在桌面应用中可用。"
    "Updater public key is missing or the bundle signature is invalid."             = "更新程序公钥缺失或包签名无效。"
    "Could not fetch a valid release JSON."                                         = "无法获取有效的发布 JSON。"
    "Unknown updater error"                                                        = "未知更新程序错误"
    "Pre-release build"                                                             = "预发布版本"
    "auto-update is disabled for this build."                                        = "此版本已禁用自动更新。"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - actions.js / workspace/actions.js
    # ═══════════════════════════════════════════════════════════════
    "Open project"                                                                  = "打开项目"
    "Open Folder"                                                                   = "打开文件夹"
    "Starting new chat…"                                                            = "正在创建新聊天…"
    "Starting new chat..."                                                          = "正在创建新聊天..."
    "Starting session…"                                                             = "正在启动会话…"
    "Starting session..."                                                           = "正在启动会话..."
    "Project new chat is only supported with a native host."                        = "项目新聊天仅支持原生宿主。"
    "Failed to start new chat: project path is unavailable"                         = "启动新聊天失败：项目路径不可用"
    "Failed to open project: project path is unavailable"                           = "打开项目失败：项目路径不可用"
    "Failed to start new chat: navigation is unavailable"                           = "启动新聊天失败：导航不可用"
    "Open project is only supported with a native host."                            = "打开项目仅支持原生宿主。"
    "Open folder is only supported with a native host."                             = "打开文件夹仅支持原生宿主。"
    "Failed to open folder"                                                         = "打开文件夹失败"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - dialogs.js
    # ═══════════════════════════════════════════════════════════════
    "Select an option"                                                              = "选择一个选项"
    "Confirm"                                                                       = "确认"
    "Submit"                                                                        = "提交"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - sidebar / session-sidebar.js
    # ═══════════════════════════════════════════════════════════════
    "Favourites"                                                                    = "收藏"
    "Archived"                                                                      = "已归档"
    "Archive"                                                                       = "归档"
    "Pinned"                                                                        = "已置顶"
    "Message matches"                                                               = "消息匹配"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - cost/infobar.js
    # ═══════════════════════════════════════════════════════════════
    "Session"                                                                       = "会话"
    "Tokens"                                                                        = "令牌"
    "Tools"                                                                         = "工具"
    "Cost"                                                                          = "费用"
    "Date"                                                                          = "日期"
    "Less"                                                                          = "更少"
    "More"                                                                          = "更多"
    "Current streak"                                                                = "当前连续"
    "Longest streak"                                                                = "最长连续"
    "Total tokens"                                                                  = "总令牌数"
    "Active days"                                                                   = "活跃天数"
    "Cache Write"                                                                   = "缓存写入"
    "Cache Read"                                                                    = "缓存读取"
    "Tool Calls"                                                                    = "工具调用"
    "Peak hour"                                                                     = "高峰时段"
    "Messages"                                                                      = "消息数"
    "Sessions"                                                                      = "会话数"
    "Output"                                                                        = "输出"
    "No tool usage in selected range."                                              = "所选范围内无工具使用。"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - message-renderer.js
    # ═══════════════════════════════════════════════════════════════
    "Copy message"                                                                  = "复制消息"
    "Current workspace:"                                                            = "当前工作区："
    "Thinking"                                                                      = "思考中"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - super-agent-runtime.js
    # ═══════════════════════════════════════════════════════════════
    "Choose a project when creating this task."                                     = "创建此任务时选择一个项目。"
    "Manually cancelled from Runtime panel."                                        = "已从运行时面板手动取消。"
    "Selected in Picot Runtime panel."                                              = "已在 Picot 运行时面板中选择。"
    "Choose a project…"                                                             = "选择一个项目…"
    "Choose a project..."                                                           = "选择一个项目..."
    "View Session →"                                                                = "查看会话 →"
    "Prompt AI"                                                                     = "提示 AI"
    "Approve"                                                                       = "批准"
    "Dismiss"                                                                       = "忽略"
    "History"                                                                       = "历史"
    "Pending"                                                                       = "待处理"
    "Running"                                                                       = "运行中"
    "Target:"                                                                       = "目标："
    "Project:"                                                                      = "项目："
    "Connecting…"                                                                   = "正在连接…"
    "Source:"                                                                       = "来源："
    "Waiting for input."                                                            = "等待输入。"
    "Clear Done"                                                                    = "清除已完成"
    "Tasks"                                                                         = "任务"
    "Clear"                                                                         = "清除"
    "No tasks"                                                                      = "没有任务"
    # "Approve ${ready}"  — 包含 JS 模板语法，跳过
    "Approve "                                                                     = "批准 "
    " with status "                                                                 = " 状态为 "
    "Source: "                                                                      = "来源："

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - task-state.js
    # ═══════════════════════════════════════════════════════════════
    "Task draft edited in Picot Runtime panel."                                     = "任务草稿已在 Picot 运行时面板中编辑。"
    "Marked ready for project-agent dispatch."                                      = "已标记为准备进行项目 Agent 调度。"
    "(untitled)"                                                                    = "（无标题）"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - themes.js
    # ═══════════════════════════════════════════════════════════════
    "Dusk"                                                                          = "黄昏"
    "Dawn"                                                                          = "黎明"
    "Midnight"                                                                      = "午夜"
    "Clean"                                                                         = "纯净"
    "Terracotta"                                                                    = "陶土"
    "Sage"                                                                          = "鼠尾草"
    "Theme"                                                                         = "主题"
    "Themes"                                                                         = "主题"	
    "主题s"                                                                         = "主题"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - context-viz.js
    # ═══════════════════════════════════════════════════════════════
    "Available"                                                                     = "可用"
    "Cached"                                                                        = "已缓存"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - file-browser.js
    # ═══════════════════════════════════════════════════════════════
    "Empty directory"                                                               = "空目录"
    "Failed to load"                                                                = "加载失败"
    "Loading…"                                                                      = "加载中…"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - folder-picker.js
    # ═══════════════════════════════════════════════════════════════
    "Failed to load directory"                                                      = "加载目录失败"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - cost/dashboard.js
    # ═══════════════════════════════════════════════════════════════
    "Overview"                                                                      = "概览"
    "Projects"                                                                      = "项目"
    "Models"                                                                        = "模型"
    "Total cost"                                                                    = "总费用"
    "Tool Cost"                                                                     = "工具费用"
    "Mon"                                                                           = "周一"
    "Wed"                                                                           = "周三"
    "Fri"                                                                           = "周五"
    "7d"                                                                            = "7天"
    "30d"                                                                           = "30天"
    "90d"                                                                           = "90天"
    "in ·"                                                                          = "输入 ·"
    "You've used ~"                                                                 = "你已使用约 "
    "x more tokens than War and Peace."                                              = " 倍于《战争与和平》的令牌量。"
    "You've used ~${ratio}x more tokens than War and Peace."                         = "你已使用约 ${ratio} 倍于《战争与和平》的令牌量。"
    "Quick range"                                                                   = "快速范围"
    "Recent sessions in range"                                                      = "范围内的最近会话"
    "Picot - Usage"                                                                 = "Picot - 使用统计"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - onboarding-state.js
    # ═══════════════════════════════════════════════════════════════
    "Configure an API key or provider to start chatting."                           = "配置 API 密钥或提供商以开始聊天。"
    "Open a project to start chatting."                                             = "打开一个项目以开始聊天。"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - app.js
    # ═══════════════════════════════════════════════════════════════
    "Open session tree"                                                             = "打开会话树"
    "Show Picot help"                                                               = "显示 Picot 帮助"
    "Open settings"                                                                 = "打开设置"
    "Cannot fork while a response is streaming."                                    = "响应流式传输时无法分支。"
    "Fork requires the desktop app."                                                = "分支需要桌面应用。"
    "Model request failed"                                                          = "模型请求失败"
    "Project agent ended. Review the child session for details."                    = "项目 Agent 已结束。查看子会话了解详情。"
    "Project agent reported a failure."                                             = "项目 Agent 报告失败。"
    "Session Stats"                                                                 = "会话统计"
    "Show session statistics"                                                       = "显示会话统计"
    "Compact context to save tokens"                                                = "压缩上下文以节省令牌"
    "Collapse All Tools"                                                            = "折叠所有工具"
    "Expand All Tools"                                                              = "展开所有工具"
    "Collapse all tool cards"                                                       = "折叠所有工具卡片"
    "Expand all tool cards"                                                         = "展开所有工具卡片"
    "Desktop only"                                                                  = "仅桌面端"
    "Current git branch"                                                            = "当前 Git 分支"
    "Failed to read file"                                                           = "读取文件失败"
    "Failed to encode image"                                                        = "编码图片失败"
    "Failed to decode image"                                                        = "解码图片失败"
    "Connection lost. Please refresh the page."                                     = "连接断开。请刷新页面。"
    "Fork from here"                                                                = "从此处分支"
    "Fork failed:"                                                                  = "分支失败："
    "Ready"                                                                         = "就绪"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - chat-settings-panel.js（Agent 收件箱/Telegram 设置）
    # ═══════════════════════════════════════════════════════════════
    "Start automatically"                                                           = "自动启动"
    "Launch Agent 收件箱 when Picot opens"                                          = "Picot 打开时启动 Agent 收件箱"
    "Paste a Telegram bot token from"                                               = "从"
    "to the bot."                                                                   = "到机器人。"
    "Picot will detect your"                                                        = "Picot 将自动检测您的"
    "Telegram DM automatically after you send"                                      = "发送后自动检测您的 Telegram 私信"
    "Telegram messages enter Agent 收件箱 first."                                   = "Telegram 消息先进入 Agent 收件箱。"
    "Picot keeps project-agent dispatch behind local approval."                     = "Picot 将项目 Agent 调度置于本地审批之后。"
    "Bot token"                                                                     = "Bot 令牌"
    "Not checked yet."                                                              = "尚未检查。"
    "Advanced Raw Config"                                                           = "高级原始配置"
    "Internal config stored in"                                                     = "内部配置存储在"
    "You normally do not need to edit this manually."                               = "通常无需手动编辑。"
    "Authorized DM: "                                                               = "已授权的私信："
    "Open Telegram"                                                                 = "打开 Telegram"
    "Internal ID:"                                                                  = "内部 ID："
    "Telegram is not connected."                                                    = "Telegram 未连接。"
    "Paste your Telegram bot token first."                                          = "请先粘贴您的 Telegram bot 令牌。"
    "Validating Telegram bot token…"                                                = "正在验证 Telegram bot 令牌…"
    "Validating Telegram bot token..."                                              = "正在验证 Telegram bot 令牌..."
    "Bot connected. Send /start to the bot in Telegram to finish setup."            = "Bot 已连接。在 Telegram 中向机器人发送 /start 以完成设置。"
    "Not ready"                                                                     = "未就绪"
    "Request failed"                                                                = "请求失败"
    "Needs attention"                                                               = "需要注意"
    "Telegram Doctor"                                                               = "Telegram 诊断"
    "Run Doctor"                                                                    = "运行诊断"
    "Disconnect"                                                                    = "断开连接"
    # "Open ${username ? `"  — 包含 JS 模板语法，跳过
    "the bot"                                                                       = "机器人"
    "Send"                                                                          = "发送"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - sa-chat-header.js
    # ═══════════════════════════════════════════════════════════════
    "Listening"                                                                     = "监听中"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - super-agent-entry.js
    # ═══════════════════════════════════════════════════════════════
    "Incoming work · Telegram"                                                      = "传入工作 · Telegram"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - package-install-status.js / install-status.js
    # ═══════════════════════════════════════════════════════════════
    "Permission denied in ~/.pi/agent/npm (check owner/permissions)."               = "~/.pi/agent/npm 权限被拒绝（请检查所有者/权限）。"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - resizable-panel.js
    # ═══════════════════════════════════════════════════════════════
    "Resize panel"                                                                  = "调整面板大小"

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - skill-slash-command.js
    # ═══════════════════════════════════════════════════════════════
    "[Skills] Failed to load slash commands:"                                       = "[技能] 加载斜杠命令失败："

    # ═══════════════════════════════════════════════════════════════
    # 新增翻译 - 杂项 UI 字符串
    # ═══════════════════════════════════════════════════════════════
    "Last update check failed. Open settings to retry."                            = "上次更新检查失败。打开设置重试。"
    "Update failed:"                                                                = "更新失败："
    "Downloading "                                                                  = "正在下载 "
    "Failed to save key."                                                           = "保存密钥失败。"
    "Remove stored API key for "                                                    = "移除已保存的 API 密钥："
    "Failed to load config"                                                         = "加载配置失败"
    "Invalid JSON:"                                                                 = "JSON 无效："
    "Invalid JSON"                                                                  = "JSON 无效"
    "models.json must be a JSON object."                                            = "models.json 必须是一个 JSON 对象。"
    "'providers' must be an object."                                                = "'providers' 必须是一个对象。"
    "Replace current content with the Ollama example?"                              = "是否用 Ollama 示例替换当前内容？"
    "open failed"                                                                   = "打开失败"
    "Go up"                                                                         = "上一级"
    "Go to path"                                                                    = "跳转到路径"
    "/path/to/folder"                                                               = "/路径/到/文件夹"
    "No subdirectories"                                                             = "没有子目录"
    "New chat in "                                                                  = "在此新建会话："
    "Fork session from here"                                                        = "从此处创建分支会话"
    "Copy output"                                                                   = "复制输出"
    "Pi Stats"                                                                      = "Pi 统计"
    "No data"                                                                       = "无数据"
    "Compacting context…"                                                           = "正在压缩上下文…"
    "Retrying…"                                                                     = "正在重试…"
    "Working…"                                                                      = "工作中…"
    "Connected • TS"                                                                = "已连接 • TS"
    "Connected • LAN"                                                               = "已连接 • LAN"
    "New session is only supported with a native host."                             = "新建会话仅支持原生宿主。"
    "Failed to start new session: current workspace path is unavailable"            = "启动新会话失败：当前工作区路径不可用"
    "Failed to start new session: navigation is unavailable"                        = "启动新会话失败：导航不可用"
    "Failed to attach to workspace:"                                                = "附加到工作区失败："
    "Failed to parse message:"                                                       = "解析消息失败："
    "Failed to open workspace in app:"                                               = "在应用中打开工作区失败："
    "Failed to load installed apps:"                                                 = "加载已安装应用失败："
    "Failed to start new session:"                                                   = "启动新会话失败："
    "Failed to start new chat:"                                                     = "启动新聊天失败："
    "Failed to open inspector:"                                                      = "打开检查器失败："
    "Failed to open project:"                                                       = "打开项目失败："
    "Failed to open folder:"                                                        = "打开文件夹失败："
    "Failed to load sessions."                                                       = "加载会话失败。"
    "Failed to load sessions:"                                                       = "加载会话失败："
    "Failed to load session:"                                                        = "加载会话失败："
    "Failed to load models.json"                                                     = "加载 models.json 失败"
    "Failed to load dashboard:"                                                      = "加载仪表盘失败："
    "Failed to load usage data"                                                      = "加载使用数据失败"
    "This Picot runtime is stopped or unavailable"                                  = "此 Picot 运行时已停止或不可用"
    "Native Picot requires a session route"                                         = "原生 Picot 需要会话路由"
    "Snapshot target does not belong to the current runtime"                        = "快照目标不属于当前运行时"
    "This task has not been dispatched yet."                                        = "此任务尚未调度。"
    "No incoming tasks."                                                            = "没有传入任务。"
    "No tasks match this filter."                                                   = "没有符合此筛选条件的任务。"
    "Ready for dispatch"                                                            = "准备调度"
    "Awaiting approval"                                                             = "等待批准"
    "Dispatch"                                                                      = "调度"
    "Mark ready"                                                                    = "标记为就绪"
    "Prompt"                                                                        = "提示词"
    "Prompts"                                                                        = "提示词"	
    "提示词s"                                                                       = "提示词"
    "Target project"                                                                = "目标项目"
    "Created"                                                                       = "创建时间"
    "No project selected"                                                           = "未选择项目"
    "No prompt provided"                                                            = "未提供提示词"
    "Thinking effort controls reasoning depth. Click to cycle."                     = "思考力度控制推理深度。点击循环切换。"
    "Thinking effort: off. Click to cycle reasoning depth."                         = "思考力度：关闭。点击循环切换推理深度。"
    "Thinking effort:"                                                              = "思考力度："
    "Click to cycle reasoning depth."                                               = "点击循环切换推理深度。"
    "No models available"                                                           = "没有可用模型"
    'aria-label="off"'                                                              = 'aria-label="关闭"'
    'title="off"'                                                                   = 'title="关闭"'
    'aria-label="minimal"'                                                          = 'aria-label="极低"'
    'title="minimal"'                                                               = 'title="极低"'
    'aria-label="low"'                                                              = 'aria-label="低"'
    'title="low"'                                                                   = 'title="低"'
    'aria-label="medium"'                                                           = 'aria-label="中"'
    'title="medium"'                                                                = 'title="中"'
    'aria-label="high"'                                                             = 'aria-label="高"'
    'title="high"'                                                                  = 'title="高"'
    # "model" — 已在上方 "Model" 条目中覆盖
    "textContent"                                                                    = "textContent"
    "picot-logo-alt"                                                                 = "picot-logo-alt"
}

# ── JS 安全翻译表（仅长字符串，避免与代码冲突） ──
$jsSafeKeys = @(
    # ── 原有 JS 安全键 ──
    "Type a message, or use / to call a skill"
    "Viewing historical session (read-only)"
    "Waiting for current session to finish"
    "Failed to load sessions. Pi runtime may be unavailable."
    "Disconnect Telegram from Picot?"
    "Edit ~/.pi/agent/models.json to add"
    "Only the detected DM user is authorized."
    "Failed to open session in its workspace process."
    "Delete all archived sessions"
    "Export session as HTML file"
    "Open workspace in app"
    "Choose app to open workspace"
    "Open updates in settings"
    "No packages match your filters."
    "New session was cancelled"
    "Starting new session"
    "No matching skills"
    "No saved sessions"
    "Conversation navigator"
    "Save Raw Config"
    "Saved raw config."
    "Failed to load skills"
    "Failed to load packages"
    "Failed to switch session"
    "Agent Configuration"
    "Agent config file"
    "Providers file"
    "Unavailable (empty version)"
    "QR code unavailable"
    "Health check failed"
    "Key cannot be empty."
    "Install failed"
    "Uninstall failed"
    "Delete archived sessions"
    "Telegram setup canceled."
    "Checking health..."
    "Click to copy"
    "Download & install"
    "Check for updates"
    "Show mobile QR code"
    "Waiting for your Telegram DM"
    "Connect Telegram"
    "Reconnect Telegram"
    "Disconnect Telegram"
    "Connected"
    "Disconnected"
    "Connected via Tailscale"
    "Connected via LAN"
    "Opening workspace..."
    "Unarchive session"
    "Archive session"
    "Parent directory"
    "Open in file manager"
    "Search packages..."
    "models.json docs"
    "Session cost"
    "Context usage"
    "Context Window"
    "Switch model"
    "Open on Mobile"
    "Mobile QR code"
    "Loading packages..."
    "Loading sessions..."
    "Checking Telegram"
    "Telegram connected."
    "Telegram disconnected."
    "Telegram doctor failed"
    "Show more"
    "Show less"
    "Agent Inbox"
    "Force Cancel"
    "Export HTML"
    "Welcome to Picot"
    "Auto-compaction"
    "Thinking effort"
    "Reasoning depth"
    "Show thinking"
    "Require login"
    "Installed only"
    "Sort packages"
    "Health unknown"
    "Search models"
    "Aborted by user"
    "Save failed"
    "Disconnect failed"
    "Super Agent"
    "Open folder as workspace"
    "Check now"

    # ── 新增 JS 安全键（仅添加明确是 UI 文本的长字符串） ──
    "Clear search"
    "Refresh sessions"
    "Toggle sidebar"
    "Choose app"
    "Toggle file browser"
    "Attach image"
    "Voice input"
    "Send message"
    "Abort (Esc)"
    "Type a message below to start chatting with Pi, or select a session from the sidebar."
    "Esc Abort"
    "New ↓"
    "Back to chat"
    "Browse Community Packages"
    "Change language"
    "Insert example"
    "Think off"
    "Scan with your phone to open Picot on the same network"
    "Generating QR code…"
    "Generating QR code..."
    "LLM providers"
    "Loading providers…"
    "Loading providers..."
    "Failed to load providers."
    "No providers known."
    "Failed to save config"
    "Failed to save models.json"
    "Check health"
    "Set key"
    "Checking for updates..."
    "You're on the latest version."
    "Update installed. Restarting..."
    "Dev build — updates are checked only in packaged releases."
    "Auto-updates are only available in the desktop app."
    "Updater public key is missing or the bundle signature is invalid."
    "Could not fetch a valid release JSON."
    "Unknown updater error"
    "Open project"
    "Open Folder"
    "Starting new chat…"
    "Starting new chat..."
    "Starting session…"
    "Starting session..."
    "Project new chat is only supported with a native host."
    "Failed to start new chat: project path is unavailable"
    "Failed to open project: project path is unavailable"
    "Failed to start new chat: navigation is unavailable"
    "Open project is only supported with a native host."
    "Open folder is only supported with a native host."
    "Failed to open folder"
    "Select an option"
    "Confirm"
    "Message matches"
    "No tool usage in selected range."
    "Copy message"
    "Current workspace:"
    "Choose a project when creating this task."
    "Manually cancelled from Runtime panel."
    "Selected in Picot Runtime panel."
    "Choose a project…"
    "Choose a project..."
    "View Session →"
    "Prompt AI"
    "Waiting for input."
    "Clear Done"
    "Task draft edited in Picot Runtime panel."
    "Marked ready for project-agent dispatch."
    "(untitled)"
    "Empty directory"
    "Loading…"
    "Loading..."
    "Failed to load directory"
    "Tool Cost"
    "Quick range"
    "Recent sessions in range"
    "Picot - Usage"
    "Configure an API key or provider to start chatting."
    "Open a project to start chatting."
    "Open session tree"
    "Show Picot help"
    "Open settings"
    "Update available"
    "Discover extensions, skills, themes, and prompts from the Pi ecosystem. Install with one click."
    "Cannot fork while a response is streaming."
    "Fork requires the desktop app."
    "Model request failed"
    "Project agent ended. Review the child session for details."
    "Project agent reported a failure."
    "Session Stats"
    "Show session statistics"
    "Compact context to save tokens"
    "Collapse All Tools"
    "Expand All Tools"
    "Collapse all tool cards"
    "Expand all tool cards"
    "Desktop only"
    "Current git branch"
    "Failed to read file"
    "Failed to encode image"
    "Failed to decode image"
    "Connection lost. Please refresh the page."
    "Fork from here"
    "Start automatically"
    "Launch Agent 收件箱 when Picot opens"
    "Bot token"
    "Not checked yet."
    "Advanced Raw Config"
    "Internal config stored in"
    "You normally do not need to edit this manually."
    "Authorized DM: "
    "Open Telegram"
    "Internal ID:"
    "Telegram is not connected."
    "Paste your Telegram bot token first."
    "Validating Telegram bot token…"
    "Validating Telegram bot token..."
    "Bot connected. Send /start to the bot in Telegram to finish setup."
    "Request failed"
    "Needs attention"
    "Telegram Doctor"
    "Run Doctor"
    "Incoming work · Telegram"
    "Permission denied in ~/.pi/agent/npm (check owner/permissions)."
    "Resize panel"
    "[Skills] Failed to load slash commands:"
    "Paste a Telegram bot token from"
    "to the bot."
    "Picot will detect your"
    "Telegram DM automatically after you send"
    "Telegram messages enter Agent 收件箱 first."
    "Picot keeps project-agent dispatch behind local approval."
    "Last update check failed. Open settings to retry."
    "Update failed:"
    "Downloading "
    "Failed to save key."
    "Remove stored API key for "
    "Failed to load config"
    "Invalid JSON:"
    "Invalid JSON"
    "models.json must be a JSON object."
    "'providers' must be an object."
    "Replace current content with the Ollama example?"
    "open failed"
    "Go up"
    "Go to path"
    "/path/to/folder"
    "No subdirectories"
    "New chat in "
    "Favourites"
    "Archived"
    "Fork session from here"
    "Copy output"
    "Pi Stats"
    "No data"
    "Compacting context…"
    "Retrying…"
    "Working…"
    "Connected • TS"
    "Connected • LAN"
    "New session is only supported with a native host."
    "Failed to start new session: current workspace path is unavailable"
    "Failed to start new session: navigation is unavailable"
    "Failed to attach to workspace:"
    "Failed to parse message:"
    "Failed to open workspace in app:"
    "Failed to load installed apps:"
    "Failed to start new session:"
    "Failed to start new chat:"
    "Failed to open inspector:"
    "Failed to open project:"
    "Failed to open folder:"
    "Failed to load sessions."
    "Failed to load sessions:"
    "Failed to load session:"
    "Failed to load models.json"
    "Failed to load dashboard:"
    "Failed to load usage data"
    "This Picot runtime is stopped or unavailable"
    "Native Picot requires a session route"
    "Snapshot target does not belong to the current runtime"
    "This task has not been dispatched yet."
    "No incoming tasks."
    "No tasks match this filter."
    "Ready for dispatch"
    "Awaiting approval"
    "Dispatch"
    "Mark ready"
    "Target project"
    "Created"
    "No project selected"
    "No prompt provided"
    "Overview"
    "Total cost"
    "Total Cost"
    "Total Tokens"
    "in ·"
    "You've used ~"
    "x more tokens than War and Peace."
    "You've used ~${ratio}x more tokens than War and Peace."
    "Thinking effort controls reasoning depth. Click to cycle."
    "Thinking effort: off. Click to cycle reasoning depth."
    "Thinking effort:"
    "Click to cycle reasoning depth."
    "No models available"
)

# ── 大小写敏感额外替换（哈希表键不区分大小写，但源文件需要精确匹配的补充） ──
$caseSensitivePairs = @(
    @{ Old = "Open Project"; New = "打开项目" }
    @{ Old = "The bot"; New = "机器人" }
    @{ Old = "Total Cost"; New = "总费用" }
    @{ Old = "Total Tokens"; New = "总令牌数" }
    # 不要全局替换小写 model；JS 中大量变量/属性名依赖它，替换后会导致界面脚本崩溃。
)

$jsRiskyKeys = @(
    # 短单词和状态值很可能同时作为枚举、类名、数据 key 或逻辑分支值出现，不能在 JS 中改。
    "Connected"
    "Disconnected"
    "Ready"
)

$jsShortAllowedKeys = @(
    "in ·"
)

# ── 文件筛选 ──
$files = Get-ChildItem $publicDir -Recurse -Include '*.js','*.html' -Exclude '*test*','*bootstrap*' |
         Where-Object { $_.FullName -notmatch '\\icons\\|\\vendor\\' } |
         Sort-Object Extension, FullName

# ── 翻译函数 ──
function Test-SafeJsTextKey {
    param([Parameter(Mandatory)][string]$Text)

    if ($jsRiskyKeys -contains $Text) { return $false }
    if ($jsShortAllowedKeys -contains $Text) { return $true }
    if ($Text.Length -lt 6 -and $Text -notmatch '[\s\.\?\!\:\(\)/&…→↓·\[\]~-]') { return $false }
    return $true
}

function Convert-JsStringLiteralText {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][hashtable]$Dict,
        [Parameter(Mandatory)][string[]]$Keys,
        [Parameter(Mandatory)][hashtable]$Stats
    )

    $safeKeys = $Keys |
        Where-Object { $Dict.ContainsKey($_) -and (Test-SafeJsTextKey -Text $_) } |
        Sort-Object Length -Descending

    $sb = [System.Text.StringBuilder]::new($Text.Length)
    $i = 0
    while ($i -lt $Text.Length) {
        $ch = $Text[$i]
        if ($ch -eq '/' -and ($i + 1) -lt $Text.Length) {
            $next = $Text[$i + 1]
            if ($next -eq '/') {
                while ($i -lt $Text.Length) {
                    [void]$sb.Append($Text[$i])
                    if ($Text[$i] -eq "`n") {
                        $i++
                        break
                    }
                    $i++
                }
                continue
            }
            if ($next -eq '*') {
                [void]$sb.Append($ch)
                [void]$sb.Append($next)
                $i += 2
                while ($i -lt $Text.Length) {
                    $cur = $Text[$i]
                    [void]$sb.Append($cur)
                    if ($cur -eq '*' -and ($i + 1) -lt $Text.Length -and $Text[$i + 1] -eq '/') {
                        [void]$sb.Append('/')
                        $i += 2
                        break
                    }
                    $i++
                }
                continue
            }
        }

        if ($ch -ne "'" -and $ch -ne '"' -and $ch -ne '`') {
            [void]$sb.Append($ch)
            $i++
            continue
        }

        $quote = $ch
        $start = $i
        $i++
        $escaped = $false
        while ($i -lt $Text.Length) {
            $cur = $Text[$i]
            if ($escaped) {
                $escaped = $false
            } elseif ($cur -eq '\') {
                $escaped = $true
            } elseif ($cur -eq $quote) {
                break
            }
            $i++
        }

        if ($i -ge $Text.Length) {
            [void]$sb.Append($Text.Substring($start))
            break
        }

        $body = $Text.Substring($start + 1, $i - $start - 1)
        $newBody = $body

        # 模板字符串含 ${...} 时可能混有表达式，跳过，避免误改代码片段。
        if (-not ($quote -eq '`' -and $body.Contains('${'))) {
            foreach ($en in $safeKeys) {
                $cn = $Dict[$en]
                if ([string]::IsNullOrEmpty($cn) -or $en -eq $cn) { continue }
                if (-not $newBody.Contains($en)) { continue }

                $count = [regex]::Matches($newBody, [regex]::Escape($en)).Count
                $newBody = $newBody.Replace($en, $cn)
                if ($count -gt 0) {
                    if ($Stats.ContainsKey($en)) { $Stats[$en] += $count }
                    else { $Stats[$en] = $count }
                }
            }
        }

        [void]$sb.Append($quote)
        [void]$sb.Append($newBody)
        [void]$sb.Append($quote)
        $i++
    }

    return $sb.ToString()
}

function Invoke-Translation {
    param([string]$Path, [hashtable]$Dict, [string[]]$SafeOnlyKeys, [switch]$CheckOnly)

    $content = Get-Content $Path -Raw -Encoding UTF8
    if (-not $content) { return $false }

    $isHtml = $Path -like '*.html'
    $text = $content
    $stats = @{}

    if ($isHtml) {
        # HTML 可以按文本替换；HTML 内不存在 JS 标识符被改名的问题。
        $keys = $Dict.Keys |
            Where-Object { $text.Contains($_) -and $Dict.ContainsKey($_) } |
            Sort-Object Length -Descending

        foreach ($en in $keys) {
            $cn = $Dict[$en]
            if ([string]::IsNullOrEmpty($cn) -or $en -eq $cn) { continue }

            $old = $text
            $text = $text.Replace($en, $cn)
            if ($old -ne $text) {
                $stats[$en] = [regex]::Matches($old, [regex]::Escape($en)).Count
            }
        }

        # 大小写敏感额外替换（处理哈希表键不区分的配对）
        foreach ($pair in $caseSensitivePairs) {
            $old = $text
            $text = $text.Replace($pair.Old, $pair.New)
            if ($old -ne $text) {
                $stats[$pair.Old] = [regex]::Matches($old, [regex]::Escape($pair.Old)).Count
            }
        }
    } else {
        # JS 只改字符串字面量内部，避免替换变量名、属性名、函数名和其它代码结构。
        $text = Convert-JsStringLiteralText -Text $text -Dict $Dict -Keys $SafeOnlyKeys -Stats $stats

        foreach ($pair in $caseSensitivePairs) {
            if (-not (Test-SafeJsTextKey -Text $pair.Old)) { continue }
            $tempDict = @{ $pair.Old = $pair.New }
            $text = Convert-JsStringLiteralText -Text $text -Dict $tempDict -Keys @($pair.Old) -Stats $stats
        }
    }

    if ($stats.Count -eq 0) { return $false }

    if (-not $CheckOnly) {
        $Utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($Path, $text, $Utf8NoBom)
    }

    $total = ($stats.Values | Measure-Object -Sum).Sum
    Write-Host "  ✓ $($stats.Count) 项 → $total 处" -ForegroundColor Cyan
    return $true
}

function Invoke-CompatibilityFixes {
    param([string]$Root, [switch]$CheckOnly)

    $fixes = @(
        @{
            RelativePath = "sidebar\index.js"
            Old = 'project.path.split("/").filter(Boolean)'
            New = 'project.path.split(/[/\\]/).filter(Boolean)'
            Label = "sidebar render path split"
        }
        @{
            RelativePath = "sidebar\index.js"
            Old = 'path.split("/").filter(Boolean)'
            New = 'path.split(/[/\\]/).filter(Boolean)'
            Label = "sidebar search path split"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'Update available: ${pendingUpdate.version}'
            New = '更新可用：${pendingUpdate.version}'
            Label = "updater pending tooltip"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'Update available: ${update.version}'
            New = '更新可用：${update.version}'
            Label = "updater status"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'checkUpdatesBtn.textContent = "Checking...";'
            New = 'checkUpdatesBtn.textContent = "正在检查...";'
            Label = "updater check button busy label"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'Update available: ${update.version}'
            New = '更新可用：${update.version}'
            Label = "updater status"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'checkUpdatesBtn.textContent = "Checking...";'
            New = 'checkUpdatesBtn.textContent = "正在检查...";'
            Label = "updater check button busy label"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'sidebarUpdateBtn.textContent = "Update";'
            New = 'sidebarUpdateBtn.textContent = "更新";'
            Label = "updater sidebar update button"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'sidebarUpdateBtn.textContent = "Update";'
            New = 'sidebarUpdateBtn.textContent = "更新";'
            Label = "updater sidebar update button"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'sidebarUpdateBtn.title = "Open updates in settings";'
            New = 'sidebarUpdateBtn.title = "在设置中打开更新";'
            Label = "updater sidebar title"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'sidebarUpdateBtn.title = "Download and install update";'
            New = 'sidebarUpdateBtn.title = "下载并安装更新";'
            Label = "updater sidebar title"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'appVersionValue.textContent = "unknown";'
            New = 'appVersionValue.textContent = "未知";'
            Label = "updater unknown version"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'appVersionValue.textContent = "unknown";'
            New = 'appVersionValue.textContent = "未知";'
            Label = "updater unknown version"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'installUpdateBtn.textContent = "Downloading...";'
            New = 'installUpdateBtn.textContent = "正在下载...";'
            Label = "updater install downloading"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'installUpdateBtn.textContent = "Downloading...";'
            New = 'installUpdateBtn.textContent = "正在下载...";'
            Label = "updater install downloading"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'if (installUpdateBtn) installUpdateBtn.textContent = `Downloading ${pct}%`;'
            New = 'if (installUpdateBtn) installUpdateBtn.textContent = `正在下载 ${pct}%`;'
            Label = "updater install downloading percent"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'if (installUpdateBtn) installUpdateBtn.textContent = `Downloading ${pct}%`;'
            New = 'if (installUpdateBtn) installUpdateBtn.textContent = `正在下载 ${pct}%`;'
            Label = "updater install downloading percent"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'if (installUpdateBtn) installUpdateBtn.textContent = "Installing...";'
            New = 'if (installUpdateBtn) installUpdateBtn.textContent = "正在安装...";'
            Label = "updater install installing"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'if (installUpdateBtn) installUpdateBtn.textContent = "Installing...";'
            New = 'if (installUpdateBtn) installUpdateBtn.textContent = "正在安装...";'
            Label = "updater install installing"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'installUpdateBtn.textContent = "Retry";'
            New = 'installUpdateBtn.textContent = "重试";'
            Label = "updater install retry"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'installUpdateBtn.textContent = "Retry";'
            New = 'installUpdateBtn.textContent = "重试";'
            Label = "updater install retry"
        }
        @{
            RelativePath = "app-settings-editors.js"
            Old = 'retry.textContent = "Retry";'
            New = 'retry.textContent = "重试";'
            Label = "legacy settings retry button"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = 'retry.textContent = "Retry";'
            New = 'retry.textContent = "重试";'
            Label = "settings retry button"
        }
        @{
            RelativePath = "app-settings-editors.js"
            Old = 'setBtn.textContent = p.configured ? "Update" : "Set key";'
            New = 'setBtn.textContent = p.configured ? "更新" : "设置密钥";'
            Label = "legacy settings set key button"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = 'setBtn.textContent = p.configured ? "Update" : "Set key";'
            New = 'setBtn.textContent = p.configured ? "更新" : "设置密钥";'
            Label = "settings set key button"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = 'checkHealthBtn.textContent = "Check health";'
            New = 'checkHealthBtn.textContent = "检查健康状态";'
            Label = "settings check health button"
        }
        @{
            RelativePath = "app-settings-editors.js"
            Old = 'removeBtn.textContent = "Remove";'
            New = 'removeBtn.textContent = "移除";'
            Label = "legacy settings remove button"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = 'removeBtn.textContent = "Remove";'
            New = 'removeBtn.textContent = "移除";'
            Label = "settings remove button"
        }
        @{
            RelativePath = "app-settings-editors.js"
            Old = 'cancelBtn.textContent = "Cancel";'
            New = 'cancelBtn.textContent = "取消";'
            Label = "legacy settings cancel button"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = 'cancelBtn.textContent = "Cancel";'
            New = 'cancelBtn.textContent = "取消";'
            Label = "settings cancel button"
        }
        @{
            RelativePath = "app-settings-editors.js"
            Old = 'saveBtn.textContent = "Save";'
            New = 'saveBtn.textContent = "保存";'
            Label = "legacy settings save button"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = 'saveBtn.textContent = "Save";'
            New = 'saveBtn.textContent = "保存";'
            Label = "settings save button"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = 'modelColumn.textContent = "Model";'
            New = 'modelColumn.textContent = "模型";'
            Label = "settings model column"
        }
        @{
            RelativePath = "app-settings-editors.js"
            Old = 'err.textContent = "Key cannot be empty.";'
            New = 'err.textContent = "密钥不能为空。";'
            Label = "legacy settings key empty"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = 'err.textContent = "Key cannot be empty.";'
            New = 'err.textContent = "密钥不能为空。";'
            Label = "settings key empty"
        }
        @{
            RelativePath = "app-settings-editors.js"
            Old = 'err.textContent = resp?.error || "Failed to save key.";'
            New = 'err.textContent = resp?.error || "保存密钥失败。";'
            Label = "legacy settings save key error"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = 'err.textContent = resp?.error || "Failed to save key.";'
            New = 'err.textContent = settingsDisplayTextZh(resp?.error || "Failed to save key.");'
            Label = "settings save key error"
        }
        @{
            RelativePath = "app-settings-editors.js"
            Old = 'setBtn.textContent = p.configured ? "Update" : "设置密钥";'
            New = 'setBtn.textContent = p.configured ? "更新" : "设置密钥";'
            Label = "legacy settings update button partial"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'label = "Update",'
            New = 'label = "更新",'
            Label = "updater default label"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'label = "Update",'
            New = 'label = "更新",'
            Label = "updater default label"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'label: "Update",'
            New = 'label: "更新",'
            Label = "updater pending label"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'label: "Update",'
            New = 'label: "更新",'
            Label = "updater pending label"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'label: "Retry",'
            New = 'label: "重试",'
            Label = "updater retry label"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'label: "Retry",'
            New = 'label: "重试",'
            Label = "updater retry label"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'title: "Update is in progress",'
            New = 'title: "正在更新",'
            Label = "updater in progress title"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'title: "Update is in progress",'
            New = 'title: "正在更新",'
            Label = "updater in progress title"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'title: "Last update check failed. Retry update check.",'
            New = 'title: "上次更新检查失败。重试更新检查。",'
            Label = "updater retry title"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'title: "Last update check failed. Retry update check.",'
            New = 'title: "上次更新检查失败。重试更新检查。",'
            Label = "updater retry title"
        }
        @{
            RelativePath = "app-updater.js"
            Old = ': "Downloading...",'
            New = ': "正在下载...",'
            Label = "updater status downloading fallback"
        }
        @{
            RelativePath = "app\updater.js"
            Old = ': "Downloading...",'
            New = ': "正在下载...",'
            Label = "updater status downloading fallback"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'setUpdateStatus("Installing...", "info");'
            New = 'setUpdateStatus("正在安装...", "info");'
            Label = "updater status installing"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'setUpdateStatus("Installing...", "info");'
            New = 'setUpdateStatus("正在安装...", "info");'
            Label = "updater status installing"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'setUpdateStatus("Please restart Picot to finish updating.", "warn");'
            New = 'setUpdateStatus("请重启 Picot 以完成更新。", "warn");'
            Label = "updater restart required"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'setUpdateStatus("Please restart Picot to finish updating.", "warn");'
            New = 'setUpdateStatus("请重启 Picot 以完成更新。", "warn");'
            Label = "updater restart required"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'setUpdateStatus(`Update failed: ${msg}`, "error");'
            New = 'setUpdateStatus(`更新失败：${msg}`, "error");'
            Label = "updater failed status"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'setUpdateStatus(`Update failed: ${msg}`, "error");'
            New = 'setUpdateStatus(`更新失败：${msg}`, "error");'
            Label = "updater failed status"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'setUpdateStatus("You''re on the latest stable version.", "ok");'
            New = 'setUpdateStatus("已是最新稳定版本。", "ok");'
            Label = "updater latest stable"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'setUpdateStatus("You''re on the latest stable version.", "ok");'
            New = 'setUpdateStatus("已是最新稳定版本。", "ok");'
            Label = "updater latest stable"
        }
        @{
            RelativePath = "app-voice-input.js"
            Old = 'micBtn.title = "Stop recording";'
            New = 'micBtn.title = "停止录音";'
            Label = "voice stop title"
        }
        @{
            RelativePath = "app\voice-input.js"
            Old = 'micBtn.title = "Stop recording";'
            New = 'micBtn.title = "停止录音";'
            Label = "voice stop title"
        }
        @{
            RelativePath = "app\voice-input.js"
            Old = 'micBtn.setAttribute("aria-label", "Stop recording");'
            New = 'micBtn.setAttribute("aria-label", "停止录音");'
            Label = "voice stop aria"
        }
        @{
            RelativePath = "app.js"
            Old = 'statusText.textContent = "Done";'
            New = 'statusText.textContent = "完成";'
            Label = "lan status done"
        }
        @{
            RelativePath = "app.js"
            Old = 'statusText.textContent = "Connected";'
            New = 'statusText.textContent = "已连接";'
            Label = "status connected"
        }
        @{
            RelativePath = "app.js"
            Old = 'statusText.textContent = "Disconnected";'
            New = 'statusText.textContent = "已断开";'
            Label = "status disconnected"
        }
        @{
            RelativePath = "app.js"
            Old = 'statusText.textContent = "Error";'
            New = 'statusText.textContent = "错误";'
            Label = "status error"
        }
        @{
            RelativePath = "app.js"
            Old = 'btn.textContent = "Compact";'
            New = 'btn.textContent = "压缩";'
            Label = "compact button"
        }
        @{
            RelativePath = "app.js"
            Old = 'btn.title = "Context is over 80% — compact to save tokens";'
            New = 'btn.title = "上下文已超过 80% - 压缩以节省令牌";'
            Label = "compact button title"
        }
        @{
            RelativePath = "app.js"
            Old = '<button type="button" class="settings-value-btn" id="pkg-browse-retry">Retry</button>'
            New = '<button type="button" class="settings-value-btn" id="pkg-browse-retry">重试</button>'
            Label = "package browse retry button"
        }
        @{
            RelativePath = "markdown.js"
            Old = 'btn.textContent = "Copied!";'
            New = 'btn.textContent = "已复制！";'
            Label = "markdown copied button"
        }
        @{
            RelativePath = "ui\markdown.js"
            Old = 'btn.textContent = "Copied!";'
            New = 'btn.textContent = "已复制！";'
            Label = "markdown copied button"
        }
        @{
            RelativePath = "markdown.js"
            Old = 'btn.textContent = "Copy";'
            New = 'btn.textContent = "复制";'
            Label = "markdown copy button"
        }
        @{
            RelativePath = "ui\markdown.js"
            Old = 'btn.textContent = "Copy";'
            New = 'btn.textContent = "复制";'
            Label = "markdown copy button"
        }
        @{
            RelativePath = "session-sidebar.js"
            Old = '<button class="retry-link" id="retry-load-sessions">Retry</button>'
            New = '<button class="retry-link" id="retry-load-sessions">重试</button>'
            Label = "session sidebar retry"
        }
        @{
            RelativePath = "sidebar\index.js"
            Old = '<button class="retry-link" id="retry-load-sessions">Retry</button>'
            New = '<button class="retry-link" id="retry-load-sessions">重试</button>'
            Label = "session sidebar retry"
        }
        @{
            RelativePath = "session-sidebar.js"
            Old = '<span>Message matches</span>'
            New = '<span>消息匹配</span>'
            Label = "session sidebar matches"
        }
        @{
            RelativePath = "sidebar\index.js"
            Old = '<span>Message matches</span>'
            New = '<span>消息匹配</span>'
            Label = "session sidebar matches"
        }
        @{
            RelativePath = "session-sidebar.js"
            Old = '<span>Favourites</span>'
            New = '<span>收藏</span>'
            Label = "session sidebar favourites"
        }
        @{
            RelativePath = "sidebar\index.js"
            Old = '<span>Favourites</span>'
            New = '<span>收藏</span>'
            Label = "session sidebar favourites"
        }
        @{
            RelativePath = "ui\skill-slash-command.js"
            Old = 'container.setAttribute("aria-label", "Skills");'
            New = 'container.setAttribute("aria-label", "技能");'
            Label = "skills slash aria"
        }
        @{
            RelativePath = "ui\skill-slash-command.js"
            Old = 'heading.textContent = "Skills";'
            New = 'heading.textContent = "技能";'
            Label = "skills slash heading"
        }
        @{
            RelativePath = "tool-card.js"
            Old = 'status.textContent = "complete";'
            New = 'status.textContent = "完成";'
            Label = "tool card complete status"
        }
        @{
            RelativePath = "ui\tool-card.js"
            Old = 'status.textContent = "complete";'
            New = 'status.textContent = "完成";'
            Label = "tool card complete status"
        }
        @{
            RelativePath = "tool-card.js"
            Old = 'statusEl.textContent = "error";'
            New = 'statusEl.textContent = "错误";'
            Label = "tool card error status"
        }
        @{
            RelativePath = "ui\tool-card.js"
            Old = 'statusEl.textContent = "error";'
            New = 'statusEl.textContent = "错误";'
            Label = "tool card error status"
        }
        @{
            RelativePath = "bootstrap.html"
            Old = 'This usually means the installation is incomplete or corrupted. Reinstalling Picot normally fixes it. Click <b>Retry startup</b> after reinstalling or rebooting.'
            New = '这通常表示安装不完整或已损坏。重新安装 Picot 通常可以修复。重新安装或重启后点击 <b>重试启动</b>。'
            Label = "bootstrap startup failure help"
        }
        @{
            RelativePath = "bootstrap.html"
            Old = '<button id="retry-btn" type="button">Retry startup</button>'
            New = '<button id="retry-btn" type="button">重试启动</button>'
            Label = "bootstrap retry startup button"
        }
        @{
            RelativePath = "app.js"
            Old = 'statusText.textContent = `Retrying (${attempt}/${maxAttempts})...`;'
            New = 'statusText.textContent = `正在重试 (${attempt}/${maxAttempts})...`;'
            Label = "startup retry attempt status"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<button class="sa-btn sa-btn-approve" data-action="retry" data-task-id="${task.id}">Retry</button>'
            New = '<button class="sa-btn sa-btn-approve" data-action="retry" data-task-id="${task.id}">重试</button>'
            Label = "super agent retry button"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'title: `Download and install Picot ${pendingUpdate.version}`,'
            New = 'title: `下载并安装 Picot ${pendingUpdate.version}`,'
            Label = "updater pending install title"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'title: `Download and install Picot ${pendingUpdate.version}`,'
            New = 'title: `下载并安装 Picot ${pendingUpdate.version}`,'
            Label = "updater pending install title"
        }
        @{
            RelativePath = "app-settings-editors.js"
            Old = 'const ok = confirm(`Remove stored API key for ${p.displayName || p.provider}?`);'
            New = 'const ok = confirm(`移除已保存的 API 密钥：${p.displayName || p.provider}?`);'
            Label = "legacy settings remove key confirm"
        }
        @{
            RelativePath = "app-context-viz.js"
            Old = 'contextVizUsed.textContent = `${pct}% used`;'
            New = 'contextVizUsed.textContent = `已用 ${pct}%`;'
            Label = "context used percent"
        }
        @{
            RelativePath = "ui\context-viz.js"
            Old = 'contextVizUsed.textContent = `${pct}% used`;'
            New = 'contextVizUsed.textContent = `已用 ${pct}%`;'
            Label = "context used percent"
        }
        @{
            RelativePath = "app-settings-editors.js"
            Old = 'title.textContent = `${p.displayName || p.provider} API key`;'
            New = 'title.textContent = `${p.displayName || p.provider} API 密钥`;'
            Label = "legacy api key dialog title"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = 'title.textContent = `${p.displayName || p.provider} API key`;'
            New = 'title.textContent = `${p.displayName || p.provider} API 密钥`;'
            Label = "api key dialog title"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = 'toggle.setAttribute("aria-label", `Toggle ${p.displayName || p.provider} models`);'
            New = 'toggle.setAttribute("aria-label", `展开或收起 ${p.displayName || p.provider} 模型`);'
            Label = "provider models toggle aria"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = 'info.setAttribute("aria-label", `Toggle ${p.displayName || p.provider} models`);'
            New = 'info.setAttribute("aria-label", `展开或收起 ${p.displayName || p.provider} 模型`);'
            Label = "provider models info aria"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = 'visibility.setAttribute("aria-label", `Enable ${model.name || model.id}`);'
            New = 'visibility.setAttribute("aria-label", `启用 ${model.name || model.id}`);'
            Label = "model enable aria"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = 'if (inlineConfigPath) inlineConfigPath.textContent = "Loading…";'
            New = 'if (inlineConfigPath) inlineConfigPath.textContent = "正在加载…";'
            Label = "settings loading inline path"
        }
        @{
            RelativePath = "app.js"
            Old = 'gitBranchEl.title = `Branch: ${name}`;'
            New = 'gitBranchEl.title = `分支：${name}`;'
            Label = "git branch title dynamic"
        }
        @{
            RelativePath = "app.js"
            Old = 'headerOpenApp.btn.title = `Open ${path} in ${selected.label}`;'
            New = 'headerOpenApp.btn.title = `用 ${selected.label} 打开 ${path}`;'
            Label = "open app button title"
        }
        @{
            RelativePath = "app.js"
            Old = 'headerOpenApp.btn.setAttribute("aria-label", `Open workspace in ${selected.label}`);'
            New = 'headerOpenApp.btn.setAttribute("aria-label", `用 ${selected.label} 打开工作区`);'
            Label = "open app button aria"
        }
        @{
            RelativePath = "app.js"
            Old = 'row.title = `Open in ${app.label}`;'
            New = 'row.title = `用 ${app.label} 打开`;'
            Label = "open app row title"
        }
        @{
            RelativePath = "app.js"
            Old = 'row.setAttribute("aria-label", `Open in ${app.label}`);'
            New = 'row.setAttribute("aria-label", `用 ${app.label} 打开`);'
            Label = "open app row aria"
        }
        @{
            RelativePath = "app.js"
            Old = 'dot.setAttribute("aria-label", `Jump to conversation ${convNavTrack.children.length + 1}`);'
            New = 'dot.setAttribute("aria-label", `跳转到对话 ${convNavTrack.children.length + 1}`);'
            Label = "conversation jump aria append"
        }
        @{
            RelativePath = "app.js"
            Old = 'dot.setAttribute("aria-label", `Jump to conversation ${i + 1}`);'
            New = 'dot.setAttribute("aria-label", `跳转到对话 ${i + 1}`);'
            Label = "conversation jump aria render"
        }
        @{
            RelativePath = "app.js"
            Old = 'statusText.textContent = `Exported: ${data.data.path}`;'
            New = 'statusText.textContent = `已导出：${data.data.path}`;'
            Label = "exported status path"
        }
        @{
            RelativePath = "app.js"
            Old = 'tokenUsageEl.title = `Context: ${(lastInputTokens / 1000).toFixed(1)}k / ${(contextWindowSize / 1000).toFixed(0)}k tokens`;'
            New = 'tokenUsageEl.title = `上下文：${(lastInputTokens / 1000).toFixed(1)}k / ${(contextWindowSize / 1000).toFixed(0)}k 令牌`;'
            Label = "token usage title"
        }
        @{
            RelativePath = "app.js"
            Old = 'piVersionValue.textContent = `Unavailable (${reason})`;'
            New = 'piVersionValue.textContent = `不可用（${reason}）`;'
            Label = "pi version unavailable"
        }
        @{
            RelativePath = "app.js"
            Old = 'browseCountEl.textContent = `0 of ${results.length}`;'
            New = 'browseCountEl.textContent = `0 / ${results.length}`;'
            Label = "browse count empty"
        }
        @{
            RelativePath = "app.js"
            Old = 'browseCountEl.textContent = `${rangeStart}–${rangeEnd} of ${results.length}`;'
            New = 'browseCountEl.textContent = `${rangeStart}–${rangeEnd} / ${results.length}`;'
            Label = "browse count range"
        }
        @{
            RelativePath = "app.js"
            Old = 'downloads.textContent = `${(pkg.downloads || 0).toLocaleString()}/mo`;'
            New = 'downloads.textContent = `${(pkg.downloads || 0).toLocaleString()}/月`;'
            Label = "package downloads per month"
        }
        @{
            RelativePath = "bootstrap.html"
            Old = "hint.textContent = 'Tauri runtime is unavailable in this window.';"
            New = "hint.textContent = '此窗口中 Tauri 运行时不可用。';"
            Label = "bootstrap tauri unavailable"
        }
        @{
            RelativePath = "bootstrap.html"
            Old = "hint.textContent = 'Starting Pi runtime...';"
            New = "hint.textContent = '正在启动 Pi 运行时...';"
            Label = "bootstrap starting runtime"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = 'metaTarget.textContent = `${formatInt(tools.length)} tracked`;'
            New = 'metaTarget.textContent = `已跟踪 ${formatInt(tools.length)} 项`;'
            Label = "cost tracked tools"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = 'metaTarget.textContent = `${formatInt(tools.length)} tracked`;'
            New = 'metaTarget.textContent = `已跟踪 ${formatInt(tools.length)} 项`;'
            Label = "cost tracked tools"
        }
        @{
            RelativePath = "dialogs.js"
            Old = '<button id="dialog-cancel">Cancel</button>'
            New = '<button id="dialog-cancel">取消</button>'
            Label = "dialog cancel button"
        }
        @{
            RelativePath = "ui\dialogs.js"
            Old = '<button id="dialog-cancel">Cancel</button>'
            New = '<button id="dialog-cancel">取消</button>'
            Label = "dialog cancel button"
        }
        @{
            RelativePath = "dialogs.js"
            Old = '<button id="dialog-no">No</button>'
            New = '<button id="dialog-no">否</button>'
            Label = "dialog no button"
        }
        @{
            RelativePath = "ui\dialogs.js"
            Old = '<button id="dialog-no">No</button>'
            New = '<button id="dialog-no">否</button>'
            Label = "dialog no button"
        }
        @{
            RelativePath = "dialogs.js"
            Old = '<button id="dialog-yes">Yes</button>'
            New = '<button id="dialog-yes">是</button>'
            Label = "dialog yes button"
        }
        @{
            RelativePath = "ui\dialogs.js"
            Old = '<button id="dialog-yes">Yes</button>'
            New = '<button id="dialog-yes">是</button>'
            Label = "dialog yes button"
        }
        @{
            RelativePath = "dialogs.js"
            Old = '<button id="dialog-submit">Submit</button>'
            New = '<button id="dialog-submit">提交</button>'
            Label = "dialog submit button"
        }
        @{
            RelativePath = "ui\dialogs.js"
            Old = '<button id="dialog-submit">Submit</button>'
            New = '<button id="dialog-submit">提交</button>'
            Label = "dialog submit button"
        }
        @{
            RelativePath = "dialogs.js"
            Old = '<button id="dialog-save">Save</button>'
            New = '<button id="dialog-save">保存</button>'
            Label = "dialog save button"
        }
        @{
            RelativePath = "ui\dialogs.js"
            Old = '<button id="dialog-save">Save</button>'
            New = '<button id="dialog-save">保存</button>'
            Label = "dialog save button"
        }
        @{
            RelativePath = "folder-picker.js"
            Old = '<button class="folder-picker-cancel">Cancel</button>'
            New = '<button class="folder-picker-cancel">取消</button>'
            Label = "folder picker cancel"
        }
        @{
            RelativePath = "workspace\folder-picker.js"
            Old = '<button class="folder-picker-cancel">Cancel</button>'
            New = '<button class="folder-picker-cancel">取消</button>'
            Label = "folder picker cancel"
        }
        @{
            RelativePath = "folder-picker.js"
            Old = '<button class="folder-picker-open" disabled>Open</button>'
            New = '<button class="folder-picker-open" disabled>打开</button>'
            Label = "folder picker open"
        }
        @{
            RelativePath = "workspace\folder-picker.js"
            Old = '<button class="folder-picker-open" disabled>Open</button>'
            New = '<button class="folder-picker-open" disabled>打开</button>'
            Label = "folder picker open"
        }
        @{
            RelativePath = "markdown.js"
            Old = '<button class="copy-btn" onclick="copyCode(this)">Copy</button>'
            New = '<button class="copy-btn" onclick="copyCode(this)">复制</button>'
            Label = "markdown inline copy button"
        }
        @{
            RelativePath = "ui\markdown.js"
            Old = '<button class="copy-btn" data-copy-code>Copy</button>'
            New = '<button class="copy-btn" data-copy-code>复制</button>'
            Label = "markdown inline copy button"
        }
        @{
            RelativePath = "components\chat-settings-panel.js"
            Old = '<button class="ui-button ui-button--secondary" data-action="cancel-telegram" hidden>Cancel</button>'
            New = '<button class="ui-button ui-button--secondary" data-action="cancel-telegram" hidden>取消</button>'
            Label = "telegram cancel button"
        }
        @{
            RelativePath = "components\chat-settings-panel.js"
            Old = '<button class="ui-button ui-button--danger" data-action="disconnect-telegram">Disconnect</button>'
            New = '<button class="ui-button ui-button--danger" data-action="disconnect-telegram">断开连接</button>'
            Label = "telegram disconnect button"
        }
        @{
            RelativePath = "components\sa-chat-header.js"
            Old = '<span class="status-text" id="sa-status-text">Listening</span>'
            New = '<span class="status-text" id="sa-status-text">监听中</span>'
            Label = "sa listening status"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<span class="runtime-title">Tasks</span>'
            New = '<span class="runtime-title">任务</span>'
            Label = "super agent tasks title"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<button class="runtime-filter active" data-filter="all">All</button>'
            New = '<button class="runtime-filter active" data-filter="all">全部</button>'
            Label = "super agent all filter"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<button class="sa-btn sa-btn-approve" data-action="approve-all" type="button" ${ready === 0 ? "disabled" : ""}>Approve ${ready}</button>'
            New = '<button class="sa-btn sa-btn-approve" data-action="approve-all" type="button" ${ready === 0 ? "disabled" : ""}>批准 ${ready}</button>'
            Label = "super agent approve all"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<button class="sa-btn sa-btn-dismiss" data-action="clear-done" type="button" ${done === 0 ? "disabled" : ""}>Clear Done</button>'
            New = '<button class="sa-btn sa-btn-dismiss" data-action="clear-done" type="button" ${done === 0 ? "disabled" : ""}>清除已完成</button>'
            Label = "super agent clear done"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<button class="sa-btn" data-action="prompt-task" data-task-id="${task.id}">Prompt AI</button>'
            New = '<button class="sa-btn" data-action="prompt-task" data-task-id="${task.id}">提示 AI</button>'
            Label = "super agent prompt ai"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<button class="sa-btn sa-btn-approve" data-action="approve" data-task-id="${task.id}">Approve</button>'
            New = '<button class="sa-btn sa-btn-approve" data-action="approve" data-task-id="${task.id}">批准</button>'
            Label = "super agent approve button"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<button class="sa-btn" data-action="view-session" data-task-id="${escAttr(task.id)}">View Session →</button>'
            New = '<button class="sa-btn" data-action="view-session" data-task-id="${escAttr(task.id)}">查看会话 →</button>'
            Label = "super agent view session"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<button class="sa-btn sa-btn-dismiss" data-action="force-cancel" data-task-id="${escAttr(task.id)}">Force Cancel</button>'
            New = '<button class="sa-btn sa-btn-dismiss" data-action="force-cancel" data-task-id="${escAttr(task.id)}">强制取消</button>'
            Label = "super agent force cancel"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<button class="sa-btn sa-btn-dismiss" data-action="dismiss" data-task-id="${task.id}">Dismiss</button>'
            New = '<button class="sa-btn sa-btn-dismiss" data-action="dismiss" data-task-id="${task.id}">忽略</button>'
            Label = "super agent dismiss"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<button class="sa-btn" data-action="prompt-task" data-task-id="${escAttr(task.id)}" type="button">Prompt AI</button>'
            New = '<button class="sa-btn" data-action="prompt-task" data-task-id="${escAttr(task.id)}" type="button">提示 AI</button>'
            Label = "super agent quick prompt ai"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<button class="sa-btn sa-btn-approve" data-action="approve" data-task-id="${escAttr(task.id)}" type="button">Approve</button>'
            New = '<button class="sa-btn sa-btn-approve" data-action="approve" data-task-id="${escAttr(task.id)}" type="button">批准</button>'
            Label = "super agent quick approve"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<button class="sa-btn sa-btn-dismiss" data-action="dismiss" data-task-id="${escAttr(task.id)}" type="button">Dismiss</button>'
            New = '<button class="sa-btn sa-btn-dismiss" data-action="dismiss" data-task-id="${escAttr(task.id)}" type="button">忽略</button>'
            Label = "super agent quick dismiss"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<button class="sa-btn sa-btn-dismiss" data-action="dismiss" data-task-id="${escAttr(task.id)}" type="button">Clear</button>'
            New = '<button class="sa-btn sa-btn-dismiss" data-action="dismiss" data-task-id="${escAttr(task.id)}" type="button">清除</button>'
            Label = "super agent clear"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<button class="sa-btn" data-action="toggle-history" data-task-id="${escAttr(task.id)}" type="button">History</button>'
            New = '<button class="sa-btn" data-action="toggle-history" data-task-id="${escAttr(task.id)}" type="button">历史</button>'
            Label = "super agent history"
        }
        @{
            RelativePath = "session-sidebar.js"
            Old = '<button type="button" class="sidebar-confirm-no">Cancel</button>'
            New = '<button type="button" class="sidebar-confirm-no">取消</button>'
            Label = "sidebar confirm cancel"
        }
        @{
            RelativePath = "sidebar\index.js"
            Old = '<button type="button" class="sidebar-confirm-no">Cancel</button>'
            New = '<button type="button" class="sidebar-confirm-no">取消</button>'
            Label = "sidebar confirm cancel"
        }
        @{
            RelativePath = "session-sidebar.js"
            Old = '<button type="button" class="sidebar-confirm-yes">Delete</button>'
            New = '<button type="button" class="sidebar-confirm-yes">删除</button>'
            Label = "sidebar confirm delete"
        }
        @{
            RelativePath = "sidebar\index.js"
            Old = '<button type="button" class="sidebar-confirm-yes">Delete</button>'
            New = '<button type="button" class="sidebar-confirm-yes">删除</button>'
            Label = "sidebar confirm delete"
        }
        @{
            RelativePath = "app.js"
            Old = '<span class="queued-msg-label">Queued</span>'
            New = '<span class="queued-msg-label">队列中</span>'
            Label = "queued message label"
        }
        @{
            RelativePath = "session-sidebar.js"
            Old = '<span>Archived</span>'
            New = '<span>已归档</span>'
            Label = "sidebar archived label"
        }
        @{
            RelativePath = "sidebar\index.js"
            Old = '<span>Archived</span>'
            New = '<span>已归档</span>'
            Label = "sidebar archived label"
        }
        @{
            RelativePath = "sidebar\index.js"
            Old = '<span class="project-count">Pinned</span>'
            New = '<span class="project-count">已置顶</span>'
            Label = "sidebar pinned label"
        }
        @{
            RelativePath = "message-renderer.js"
            Old = '<span>/ Focus input</span>'
            New = '<span>/ 聚焦输入框</span>'
            Label = "message shortcut focus"
        }
        @{
            RelativePath = "ui\message-renderer.js"
            Old = '<span>/ Focus input</span>'
            New = '<span>/ 聚焦输入框</span>'
            Label = "message shortcut focus"
        }
        @{
            RelativePath = "message-renderer.js"
            Old = '<span>Esc Abort</span>'
            New = '<span>Esc 中止</span>'
            Label = "message shortcut abort"
        }
        @{
            RelativePath = "ui\message-renderer.js"
            Old = '<span>Esc Abort</span>'
            New = '<span>Esc 中止</span>'
            Label = "message shortcut abort"
        }
        @{
            RelativePath = "ui\message-renderer.js"
            Old = '<span class="thinking-label">${brainSvg} Thinking</span>'
            New = '<span class="thinking-label">${brainSvg} 思考</span>'
            Label = "thinking block label"
        }
        @{
            RelativePath = "app.js"
            Old = '<div>No API keys configured. Set a key in Settings &rarr; Configuration.</div>'
            New = '<div>未配置 API 密钥。请在“设置 &rarr; 配置”中设置密钥。</div>'
            Label = "no api keys configured hint"
        }
        @{
            RelativePath = "app.js"
            Old = '<button type="button" class="btn-primary" style="margin-top:10px">Open Settings</button>'
            New = '<button type="button" class="btn-primary" style="margin-top:10px">打开设置</button>'
            Label = "open settings button"
        }
        @{
            RelativePath = "app.js"
            Old = 'sessionCostEl.textContent = `$${sessionTotalCost.toFixed(4)} (sub)`;'
            New = 'sessionCostEl.textContent = `$${sessionTotalCost.toFixed(4)}（小计）`;'
            Label = "session cost subtotal"
        }
        @{
            RelativePath = "app-updater.js"
            Old = 'const from = update.currentVersion ? ` (from ${update.currentVersion})` : "";'
            New = 'const from = update.currentVersion ? `（当前 ${update.currentVersion}）` : "";'
            Label = "updater from version"
        }
        @{
            RelativePath = "app\updater.js"
            Old = 'const from = update.currentVersion ? ` (from ${update.currentVersion})` : "";'
            New = 'const from = update.currentVersion ? `（当前 ${update.currentVersion}）` : "";'
            Label = "updater from version"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<span class="runtime-task-title">${esc(task.title || "(untitled)")}</span>'
            New = '<span class="runtime-task-title">${esc(task.title || "(未命名)")}</span>'
            Label = "super agent untitled task"
        }
        @{
            RelativePath = "file-browser.js"
            Old = 'const parts = this.currentPath.split("/");'
            New = 'const parts = this.currentPath.split(/[/\\]/);'
            Label = "file browser path split"
        }
        @{
            RelativePath = "workspace\file-browser.js"
            Old = 'const parts = this.currentPath.split("/");'
            New = 'const parts = this.currentPath.split(/[/\\]/);'
            Label = "file browser path split"
        }
        @{
            RelativePath = "folder-picker.js"
            Old = 'const parts = this.currentPath.split("/").filter(Boolean);'
            New = 'const parts = this.currentPath.split(/[/\\]/).filter(Boolean);'
            Label = "folder picker path split"
        }
        @{
            RelativePath = "workspace\folder-picker.js"
            Old = 'const parts = this.currentPath.split("/").filter(Boolean);'
            New = 'const parts = this.currentPath.split(/[/\\]/).filter(Boolean);'
            Label = "folder picker path split"
        }
        @{
            RelativePath = "native\file-browser.js"
            Old = 'const parts = this.currentPath.split("/").filter(Boolean);'
            New = 'const parts = this.currentPath.split(/[/\\]/).filter(Boolean);'
            Label = "native file browser path split"
        }
        @{
            RelativePath = "session-sidebar.js"
            Old = 'const pathParts = project.path.split("/").filter(Boolean);'
            New = 'const pathParts = project.path.split(/[/\\]/).filter(Boolean);'
            Label = "legacy sidebar project path split"
        }
        @{
            RelativePath = "session-sidebar.js"
            Old = 'const pathParts = path.split("/").filter(Boolean);'
            New = 'const pathParts = path.split(/[/\\]/).filter(Boolean);'
            Label = "legacy sidebar search path split"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = 'const projectName = task.targetProject?.split("/").pop() || "";'
            New = 'const projectName = task.targetProject?.split(/[/\\]/).pop() || "";'
            Label = "super agent project path split"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = 'name: targetProject.split("/").pop() || targetProject,'
            New = 'name: targetProject.split(/[/\\]/).pop() || targetProject,'
            Label = "super agent target path split"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '? `Project: ${esc(targetProject.split("/").pop() || targetProject)}`'
            New = '? `项目：${esc(targetProject.split(/[/\\]/).pop() || targetProject)}`'
            Label = "super agent project hint"
        }
        @{
            RelativePath = "super-agent\task-state.js"
            Old = 'const lines = [`Task ID: ${normalized.id}`, `Title: ${normalized.title || "(untitled)"}`];'
            New = 'const lines = [`任务 ID：${normalized.id}`, `标题：${normalized.title || "(未命名)"}`];'
            Label = "super agent task lines"
        }
        @{
            RelativePath = "super-agent\task-state.js"
            Old = '`Title: ${normalized.title || "(untitled)"}`'
            New = '`标题：${normalized.title || "(未命名)"}`'
            Label = "super agent task title line"
        }
        @{
            RelativePath = "super-agent\task-state.js"
            Old = '`Task ${nextStatus}: "${normalized.title || "(untitled)"}"`'
            New = '`任务 ${nextStatus}: "${normalized.title || "(未命名)"}"`'
            Label = "super agent task status line"
        }
        @{
            RelativePath = "components\super-agent-runtime.js"
            Old = '<div class="runtime-task-target">Project: <strong>${esc(projectName)}</strong></div>'
            New = '<div class="runtime-task-target">项目：<strong>${esc(projectName)}</strong></div>'
            Label = "super agent project target label"
        }
        @{
            RelativePath = "super-agent\task-state.js"
            Old = '`Task ID: ${normalized.id}`'
            New = '`任务 ID：${normalized.id}`'
            Label = "super agent task id line"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = '<th>Session</th>'
            New = '<th>会话</th>'
            Label = "cost sessions session header"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = '<th>Model</th>'
            New = '<th>模型</th>'
            Label = "cost sessions model header"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = '<th>Session</th>'
            New = '<th>会话</th>'
            Label = "cost sessions session header"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = '<th>Model</th>'
            New = '<th>模型</th>'
            Label = "cost sessions model header"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = '<th class="num">Tokens</th>'
            New = '<th class="num">令牌</th>'
            Label = "cost sessions tokens header"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = '<th class="num">Tools</th>'
            New = '<th class="num">工具</th>'
            Label = "cost sessions tools header"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = '<th class="num">Cost</th>'
            New = '<th class="num">费用</th>'
            Label = "cost sessions cost header"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = '<th>Date</th>'
            New = '<th>日期</th>'
            Label = "cost sessions date header"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = 'const STAT_ICONS = {'
            New = @'
const STAT_LABELS = {
  "Total cost": "总费用",
  Sessions: "会话数",
  Messages: "消息数",
  "Total tokens": "总令牌数",
  "Active days": "活跃天数",
  "Current streak": "当前连续",
  "Longest streak": "最长连续",
  Input: "输入",
  Output: "输出",
  "Cache Read": "缓存读取",
  "Cache Write": "缓存写入",
  "Tool Calls": "工具调用",
};

const STAT_ICONS = {
'@
            Label = "cost stat label map"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = '${icon ? `<span class="infobar-stat-icon">${icon}</span>` : ""}${escapeHtml(title)}'
            New = '${icon ? `<span class="infobar-stat-icon">${icon}</span>` : ""}${escapeHtml(STAT_LABELS[title] || title)}'
            Label = "cost stat card display labels"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = '${formatCompact(model.inputTokens)} in · ${formatCompact(model.outputTokens)} out'
            New = '${formatCompact(model.inputTokens)} 输入 · ${formatCompact(model.outputTokens)} 输出'
            Label = "cost model token direction labels"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = '${formatInt(row.sessions || 0)} sessions'
            New = '${formatInt(row.sessions || 0)} 个会话'
            Label = "cost project sessions label"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = '${formatInt(row.count)} sessions'
            New = '${formatInt(row.count)} 个会话'
            Label = "cost tool sessions label"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = '<span>Less</span>'
            New = '<span>更少</span>'
            Label = "cost activity less label"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = '<span>More</span>'
            New = '<span>更多</span>'
            Label = "cost activity more label"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = '<th class="num">Tokens</th>'
            New = '<th class="num">令牌</th>'
            Label = "cost sessions tokens header"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = '<th class="num">Tools</th>'
            New = '<th class="num">工具</th>'
            Label = "cost sessions tools header"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = '<th class="num">Cost</th>'
            New = '<th class="num">费用</th>'
            Label = "cost sessions cost header"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = '<th>Date</th>'
            New = '<th>日期</th>'
            Label = "cost sessions date header"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = 'const STAT_ICONS = {'
            New = @'
const STAT_LABELS = {
  "Total cost": "总费用",
  Sessions: "会话数",
  Messages: "消息数",
  "Total tokens": "总令牌数",
  "Active days": "活跃天数",
  "Current streak": "当前连续",
  "Longest streak": "最长连续",
  Input: "输入",
  Output: "输出",
  "Cache Read": "缓存读取",
  "Cache Write": "缓存写入",
  "Tool Calls": "工具调用",
};

const STAT_ICONS = {
'@
            Label = "cost stat label map"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = '${icon ? `<span class="infobar-stat-icon">${icon}</span>` : ""}${escapeHtml(title)}'
            New = '${icon ? `<span class="infobar-stat-icon">${icon}</span>` : ""}${escapeHtml(STAT_LABELS[title] || title)}'
            Label = "cost stat card display labels"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = '${formatCompact(model.inputTokens)} in · ${formatCompact(model.outputTokens)} out'
            New = '${formatCompact(model.inputTokens)} 输入 · ${formatCompact(model.outputTokens)} 输出'
            Label = "cost model token direction labels"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = '${formatInt(row.sessions || 0)} sessions'
            New = '${formatInt(row.sessions || 0)} 个会话'
            Label = "cost project sessions label"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = '${formatInt(row.count)} sessions'
            New = '${formatInt(row.count)} 个会话'
            Label = "cost tool sessions label"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = '<span>Less</span>'
            New = '<span>更少</span>'
            Label = "cost activity less label"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = '<span>More</span>'
            New = '<span>更多</span>'
            Label = "cost activity more label"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = '<span>Mon</span>'
            New = '<span>周一</span>'
            Label = "cost activity monday label"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = '<span>Wed</span>'
            New = '<span>周三</span>'
            Label = "cost activity wednesday label"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = '<span>Fri</span>'
            New = '<span>周五</span>'
            Label = "cost activity friday label"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = '<span>Mon</span>'
            New = '<span>周一</span>'
            Label = "cost activity monday label"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = '<span>Wed</span>'
            New = '<span>周三</span>'
            Label = "cost activity wednesday label"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = '<span>Fri</span>'
            New = '<span>周五</span>'
            Label = "cost activity friday label"
        }
        @{
            RelativePath = "cost\dashboard.js"
            Old = '<h3>Models</h3>'
            New = '<h3>模型</h3>'
            Label = "cost dashboard models heading"
        }
        @{
            RelativePath = "cost\dashboard.js"
            Old = '<h3>Projects</h3>'
            New = '<h3>项目</h3>'
            Label = "cost dashboard projects heading"
        }
        @{
            RelativePath = "cost\dashboard.js"
            Old = '<h3>Sessions</h3>'
            New = '<h3>会话</h3>'
            Label = "cost dashboard sessions heading"
        }
        @{
            RelativePath = "cost\dashboard.js"
            Old = 'data-range-chip="7d">7d</button>'
            New = 'data-range-chip="7d">7天</button>'
            Label = "cost range 7d display label"
        }
        @{
            RelativePath = "cost\dashboard.js"
            Old = 'data-range-chip="30d">30d</button>'
            New = 'data-range-chip="30d">30天</button>'
            Label = "cost range 30d display label"
        }
        @{
            RelativePath = "cost\dashboard.js"
            Old = 'data-range-chip="90d">90d</button>'
            New = 'data-range-chip="90d">90天</button>'
            Label = "cost range 90d display label"
        }
        @{
            RelativePath = "cost\dashboard.js"
            Old = 'No data in selected range.'
            New = '所选范围内没有数据。'
            Label = "cost empty selected range"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = 'No recent sessions in selected range.'
            New = '所选范围内没有最近会话。'
            Label = "cost empty recent sessions"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = 'No recent sessions in selected range.'
            New = '所选范围内没有最近会话。'
            Label = "cost empty recent sessions"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = 'target.textContent = `You''ve used ~${ratio}x more tokens than War and Peace.`;'
            New = 'target.textContent = `你已使用约 ${ratio} 倍于《战争与和平》的令牌量。`;'
            Label = "cost war and peace template note"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = 'target.textContent = `You''ve used ~${ratio}x more tokens than War and Peace.`;'
            New = 'target.textContent = `你已使用约 ${ratio} 倍于《战争与和平》的令牌量。`;'
            Label = "cost war and peace template note"
        }
        @{
            RelativePath = "app.js"
            Old = 'function formatCompactThinkingLevelLabel(level) {'
            New = @'
const THINKING_LEVEL_LABELS = {
  off: "关闭",
  minimal: "极低",
  low: "低",
  medium: "中",
  high: "高",
};
function formatThinkingLevelDisplay(level) {
  return THINKING_LEVEL_LABELS[level || "off"] || level || "关闭";
}
function formatCompactThinkingLevelLabel(level) {
'@
            Label = "thinking level display map helper"
        }
        @{
            RelativePath = "app.js"
            Old = '  return `Think ${level || "off"}`;'
            New = '  return `思考 ${formatThinkingLevelDisplay(level)}`;'
            Label = "thinking level compact display text"
        }
        @{
            RelativePath = "app.js"
            Old = @'
function formatCompactThinkingLevelLabel(level) {
  return `Think ${level || "off"}`;
}
'@
            New = @'
const THINKING_LEVEL_LABELS = {
  off: "关闭",
  minimal: "极低",
  low: "低",
  medium: "中",
  high: "高",
};
function formatThinkingLevelDisplay(level) {
  return THINKING_LEVEL_LABELS[level || "off"] || level || "关闭";
}
function formatCompactThinkingLevelLabel(level) {
  return `思考 ${formatThinkingLevelDisplay(level)}`;
}
'@
            Label = "thinking level compact display map"
        }
        @{
            RelativePath = "app.js"
            Old = '    `Thinking effort: ${currentThinkingLevel}. Click to cycle reasoning depth.`,'
            New = '    `思考力度：${formatThinkingLevelDisplay(currentThinkingLevel)}。点击循环切换推理深度。`,'
            Label = "thinking button aria display map"
        }
        @{
            RelativePath = "settings\toggles.js"
            Old = 'export const THINKING_LEVELS = ["off", "minimal", "low", "medium", "high"];'
            New = @'
export const THINKING_LEVELS = ["off", "minimal", "low", "medium", "high"];
const THINKING_LEVEL_LABELS = {
  off: "关闭",
  minimal: "极低",
  low: "低",
  medium: "中",
  high: "高",
};
function formatThinkingLevelDisplay(level) {
  return THINKING_LEVEL_LABELS[level || "off"] || level || "关闭";
}
'@
            Label = "thinking effort display label map"
        }
        @{
            RelativePath = "settings\toggles.js"
            Old = '  if (thinkingName) thinkingName.textContent = normalized;'
            New = '  if (thinkingName) thinkingName.textContent = formatThinkingLevelDisplay(normalized);'
            Label = "thinking effort selected value display"
        }
        @{
            RelativePath = "components\chat-settings-panel.js"
            Old = '<span class="telegram-doctor-label">${esc(check.label)}</span>'
            New = '<span class="telegram-doctor-label">${esc(displayTextZh(check.label))}</span>'
            Label = "telegram doctor check label mapping"
        }
        @{
            RelativePath = "components\chat-settings-panel.js"
            Old = '<span class="telegram-doctor-message">${esc(check.message)}</span>'
            New = '<span class="telegram-doctor-message">${esc(displayTextZh(check.message))}</span>'
            Label = "telegram doctor check message mapping"
        }
        @{
            RelativePath = "components\chat-settings-panel.js"
            Old = @'
      this._doctorChecksEl.innerHTML = (report?.checks || [])
      .map(
        (check) => `
          <div class="telegram-doctor-check ${doctorStatusClass(check.status)}">
            <span class="telegram-doctor-label">${esc(check.label)}</span>
            <span class="telegram-doctor-message">${esc(check.message)}</span>
          </div>
        `,
      )
      .join("");
'@
            New = @'
      this._doctorChecksEl.innerHTML = (report?.checks || [])
      .map(
        (check) => `
          <div class="telegram-doctor-check ${doctorStatusClass(check.status)}">
            <span class="telegram-doctor-label">${esc(displayTextZh(check.label))}</span>
            <span class="telegram-doctor-message">${esc(displayTextZh(check.message))}</span>
          </div>
        `,
      )
      .join("");
'@
            Label = "telegram doctor check display mapping"
        }
        @{
            RelativePath = "components\chat-settings-panel.js"
            Old = @'
function doctorStatusClass(status) {
'@
            New = @'
function displayTextZh(text) {
  const map = {
    ["Con" + "fig"]: "配置",
    ["B" + "ot"]: "Bot",
    ["D" + "M"]: "私信",
    ["Sec" + "urity"]: "安全",
    ["List" + "ener"]: "监听器",
    ["Telegram is not " + "connected."]: "Telegram 未连接。",
    ["Bot identity is " + "missing."]: "缺少 Bot 身份信息。",
    ["No private Telegram DM is " + "bound."]: "未绑定 Telegram 私信。",
    ["No allowed Telegram user is configured; " + "restrict access before enabling remote intake."]: "未配置允许的 Telegram 用户；启用远程接入前请限制访问。",
    ["No live Telegram listener status was " + "found."]: "未找到实时 Telegram 监听状态。",
  };
  return map[text] || text || "";
}

function doctorStatusClass(status) {
'@
            Label = "telegram doctor text display map"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = '    return `${enabled} enabled · ${healthy} healthy · ${issues} issues`;'
            New = '    return `${enabled} 个启用 · ${healthy} 个健康 · ${issues} 个问题`;'
            Label = "settings provider summary template display"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = @'
  function describeProviderSummary(models) {
    const enabled = models.filter((model) => model.visible !== false).length;
    const healthy = models.filter((model) => model.health?.status === "healthy").length;
    const issues = models.filter((model) => model.health?.status === "unhealthy").length;
    return `${enabled} enabled · ${healthy} healthy · ${issues} issues`;
  }
'@
            New = @'
  function describeProviderSummary(models) {
    const enabled = models.filter((model) => model.visible !== false).length;
    const healthy = models.filter((model) => model.health?.status === "healthy").length;
    const issues = models.filter((model) => model.health?.status === "unhealthy").length;
    return `${enabled} 个启用 · ${healthy} 个健康 · ${issues} 个问题`;
  }
'@
            Label = "settings provider summary template"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = '    if (!health || health.status === "unknown") return "Health unknown";'
            New = '    if (!health || health.status === "unknown") return "健康状态未知";'
            Label = "settings model health unknown display"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = '      return health.latencyMs ? `Healthy (${health.latencyMs}ms)` : "Healthy";'
            New = '      return health.latencyMs ? `健康（${health.latencyMs}ms）` : "健康";'
            Label = "settings model healthy latency display"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = '    return health.error ? `Failed: ${health.error}` : "Failed";'
            New = '    return health.error ? `失败：${health.error}` : "失败";'
            Label = "settings model health failed display"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = @'
  function describeModelHealth(health) {
    if (!health || health.status === "unknown") return "Health unknown";
    if (health.status === "healthy") {
      return health.latencyMs ? `Healthy (${health.latencyMs}ms)` : "Healthy";
    }
    return health.error ? `Failed: ${health.error}` : "Failed";
  }
'@
            New = @'
  function describeModelHealth(health) {
    if (!health || health.status === "unknown") return "健康状态未知";
    if (health.status === "healthy") {
      return health.latencyMs ? `健康（${health.latencyMs}ms）` : "健康";
    }
    return health.error ? `失败：${health.error}` : "失败";
  }
'@
            Label = "settings model health display formatter"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = '      dot.title = "Checking health";'
            New = '      dot.title = "正在检查健康状态";'
            Label = "settings model health checking title"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = '    if (status) status.textContent = "Checking health...";'
            New = '    if (status) status.textContent = "正在检查健康状态...";'
            Label = "settings model health checking status"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = '    const text = `Failed: ${message || "Health check failed"}`;'
            New = '    const text = `失败：${message || "健康检查失败"}`;'
            Label = "settings model health error template"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = '      const message = resp?.error || "Health check failed";'
            New = '      const message = resp?.error || "健康检查失败";'
            Label = "settings model health fallback error"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = '        `Saving ${p.provider} key...`,'
            New = '        `正在保存 ${p.provider} 密钥...`,'
            Label = "settings api key saving template"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = '      `Removing ${p.provider} key...`,'
            New = '      `正在移除 ${p.provider} 密钥...`,'
            Label = "settings api key removing template"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = '  function renderApiKeysPanelError(message) {'
            New = @'
  function settingsDisplayTextZh(text) {
    const map = {
      ["Failed" + " to load providers."]: "加载提供商失败。",
      ["Failed" + " to load config"]: "加载配置失败",
      ["Failed" + " to save config"]: "保存配置失败",
      ["Failed" + " to save key."]: "保存密钥失败。",
    };
    return map[text] || text || "";
  }

  function renderApiKeysPanelError(message) {
'@
            Label = "settings display text mapping helper"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = '    msg.textContent = message;'
            New = '    msg.textContent = settingsDisplayTextZh(message);'
            Label = "settings api key panel error mapping"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = '    configEditorError.textContent = msg;'
            New = '    configEditorError.textContent = settingsDisplayTextZh(msg);'
            Label = "settings config modal error mapping"
        }
        @{
            RelativePath = "settings\editors.js"
            Old = '        inlineConfigError.textContent = e.message || String(e);'
            New = '        inlineConfigError.textContent = settingsDisplayTextZh(e.message || String(e));'
            Label = "settings inline config error mapping"
        }
        @{
            RelativePath = "settings\save-status.js"
            Old = 'export function showSettingsSaveError(messageEl, message) {'
            New = @'
function settingsSaveDisplayTextZh(text) {
  const map = {
    ["Sav" + "ed"]: "已保存",
    ["Sav" + "e"]: "保存",
    ["Failed" + " to save config"]: "保存配置失败",
    ["Failed" + " to save models.json"]: "保存 models.json 失败",
  };
  return map[text] || text || "";
}

export function showSettingsSaveError(messageEl, message) {
'@
            Label = "settings save status display map"
        }
        @{
            RelativePath = "settings\save-status.js"
            Old = '  messageEl.textContent = message;'
            New = '  messageEl.textContent = settingsSaveDisplayTextZh(message);'
            Label = "settings save error display mapping"
        }
        @{
            RelativePath = "settings\save-status.js"
            Old = '  messageEl.textContent = message;'
            New = '  messageEl.textContent = settingsSaveDisplayTextZh(message);'
            Label = "settings save success display mapping"
        }
        @{
            RelativePath = "settings\save-status.js"
            Old = '  button.textContent = isSaving ? "Saving…" : "Save";'
            New = '  button.textContent = isSaving ? "正在保存…" : "保存";'
            Label = "settings save button busy text"
        }
        @{
            RelativePath = "cost-infobar.js"
            Old = @'
const STAT_LABELS = {
  "Total cost": "总费用",
  Sessions: "会话数",
  Messages: "消息数",
  "Total tokens": "总令牌数",
  "Active days": "活跃天数",
  "Current streak": "当前连续",
  "Longest streak": "最长连续",
  Input: "输入",
  Output: "输出",
  "Cache Read": "缓存读取",
  "Cache Write": "缓存写入",
  "Tool Calls": "工具调用",
};

const STAT_LABELS = {
  "Total cost": "总费用",
  Sessions: "会话数",
  Messages: "消息数",
  "Total tokens": "总令牌数",
  "Active days": "活跃天数",
  "Current streak": "当前连续",
  "Longest streak": "最长连续",
  Input: "输入",
  Output: "输出",
  "Cache Read": "缓存读取",
  "Cache Write": "缓存写入",
  "Tool Calls": "工具调用",
};
'@
            New = @'
const STAT_LABELS = {
  "Total cost": "总费用",
  Sessions: "会话数",
  Messages: "消息数",
  "Total tokens": "总令牌数",
  "Active days": "活跃天数",
  "Current streak": "当前连续",
  "Longest streak": "最长连续",
  Input: "输入",
  Output: "输出",
  "Cache Read": "缓存读取",
  "Cache Write": "缓存写入",
  "Tool Calls": "工具调用",
};
'@
            Label = "cost stat label map dedupe"
        }
        @{
            RelativePath = "cost\infobar.js"
            Old = @'
const STAT_LABELS = {
  "Total cost": "总费用",
  Sessions: "会话数",
  Messages: "消息数",
  "Total tokens": "总令牌数",
  "Active days": "活跃天数",
  "Current streak": "当前连续",
  "Longest streak": "最长连续",
  Input: "输入",
  Output: "输出",
  "Cache Read": "缓存读取",
  "Cache Write": "缓存写入",
  "Tool Calls": "工具调用",
};

const STAT_LABELS = {
  "Total cost": "总费用",
  Sessions: "会话数",
  Messages: "消息数",
  "Total tokens": "总令牌数",
  "Active days": "活跃天数",
  "Current streak": "当前连续",
  "Longest streak": "最长连续",
  Input: "输入",
  Output: "输出",
  "Cache Read": "缓存读取",
  "Cache Write": "缓存写入",
  "Tool Calls": "工具调用",
};
'@
            New = @'
const STAT_LABELS = {
  "Total cost": "总费用",
  Sessions: "会话数",
  Messages: "消息数",
  "Total tokens": "总令牌数",
  "Active days": "活跃天数",
  "Current streak": "当前连续",
  "Longest streak": "最长连续",
  Input: "输入",
  Output: "输出",
  "Cache Read": "缓存读取",
  "Cache Write": "缓存写入",
  "Tool Calls": "工具调用",
};
'@
            Label = "cost stat label map dedupe"
        }
    )

    $changed = 0
    foreach ($group in ($fixes | Group-Object RelativePath)) {
        $path = Join-Path $Root $group.Name
        if (-not (Test-Path -LiteralPath $path)) {
            Write-Warning "兼容性修复目标不存在: $path"
            continue
        }

        $text = Get-Content -LiteralPath $path -Raw -Encoding UTF8
        $newText = $text

        foreach ($fix in $group.Group) {
            if ($newText.Contains($fix.Old)) {
                $changed++
                Write-Host "兼容性修复: $($fix.RelativePath) - $($fix.Label)" -ForegroundColor Cyan
                $newText = $newText.Replace($fix.Old, $fix.New)
                continue
            }

            if (-not $newText.Contains($fix.New)) {
                Write-Warning "兼容性修复未找到匹配内容: $($fix.RelativePath) - $($fix.Label)"
            }
        }

        if ($group.Name -in @("cost-infobar.js", "cost\infobar.js")) {
            $statLabelsBlock = @'
const STAT_LABELS = {
  "Total cost": "总费用",
  Sessions: "会话数",
  Messages: "消息数",
  "Total tokens": "总令牌数",
  "Active days": "活跃天数",
  "Current streak": "当前连续",
  "Longest streak": "最长连续",
  Input: "输入",
  Output: "输出",
  "Cache Read": "缓存读取",
  "Cache Write": "缓存写入",
  "Tool Calls": "工具调用",
};
'@
            $statLabelsPattern = '(?s)(?:const STAT_LABELS = \{\r?\n  "Total cost": "总费用",\r?\n  Sessions: "会话数",\r?\n  Messages: "消息数",\r?\n  "Total tokens": "总令牌数",\r?\n  "Active days": "活跃天数",\r?\n  "Current streak": "当前连续",\r?\n  "Longest streak": "最长连续",\r?\n  Input: "输入",\r?\n  Output: "输出",\r?\n  "Cache Read": "缓存读取",\r?\n  "Cache Write": "缓存写入",\r?\n  "Tool Calls": "工具调用",\r?\n\};\r?\n\r?\n)+const STAT_ICONS = \{'
            $newText = [regex]::Replace($newText, $statLabelsPattern, ($statLabelsBlock.TrimEnd() + "`r`n`r`nconst STAT_ICONS = {"))
        }

        if ($group.Name -eq "app.js") {
            $thinkingLabelsBlock = @'
const THINKING_LEVEL_LABELS = {
  off: "关闭",
  minimal: "极低",
  low: "低",
  medium: "中",
  high: "高",
};
function formatThinkingLevelDisplay(level) {
  return THINKING_LEVEL_LABELS[level || "off"] || level || "关闭";
}
'@
            $thinkingLabelsPattern = '(?s)(?:const THINKING_LEVEL_LABELS = \{\r?\n  off: "关闭",\r?\n  minimal: "极低",\r?\n  low: "低",\r?\n  medium: "中",\r?\n  high: "高",\r?\n\};\r?\nfunction formatThinkingLevelDisplay\(level\) \{\r?\n  return THINKING_LEVEL_LABELS\[level \|\| "off"\] \|\| level \|\| "关闭";\r?\n\}\r?\n)+function formatCompactThinkingLevelLabel\(level\) \{'
            $newText = [regex]::Replace($newText, $thinkingLabelsPattern, ($thinkingLabelsBlock.TrimEnd() + "`r`nfunction formatCompactThinkingLevelLabel(level) {"))
        }

        if ($group.Name -eq "settings\toggles.js") {
            $thinkingLabelsBlock = @'
export const THINKING_LEVELS = ["off", "minimal", "low", "medium", "high"];
const THINKING_LEVEL_LABELS = {
  off: "关闭",
  minimal: "极低",
  low: "低",
  medium: "中",
  high: "高",
};
function formatThinkingLevelDisplay(level) {
  return THINKING_LEVEL_LABELS[level || "off"] || level || "关闭";
}
'@
            $thinkingLabelsPattern = '(?s)export const THINKING_LEVELS = \["off", "minimal", "low", "medium", "high"\];\r?\n(?:const THINKING_LEVEL_LABELS = \{\r?\n  off: "关闭",\r?\n  minimal: "极低",\r?\n  low: "低",\r?\n  medium: "中",\r?\n  high: "高",\r?\n\};\r?\nfunction formatThinkingLevelDisplay\(level\) \{\r?\n  return THINKING_LEVEL_LABELS\[level \|\| "off"\] \|\| level \|\| "关闭";\r?\n\}\r?\n)+'
            $newText = [regex]::Replace($newText, $thinkingLabelsPattern, ($thinkingLabelsBlock.TrimEnd() + "`r`n"))
        }

        if ($group.Name -eq "components\chat-settings-panel.js") {
            $displayTextBlock = @'
function displayTextZh(text) {
  const map = {
    ["Con" + "fig"]: "配置",
    ["B" + "ot"]: "Bot",
    ["D" + "M"]: "私信",
    ["Sec" + "urity"]: "安全",
    ["List" + "ener"]: "监听器",
    ["Telegram is not " + "connected."]: "Telegram 未连接。",
    ["Bot identity is " + "missing."]: "缺少 Bot 身份信息。",
    ["No private Telegram DM is " + "bound."]: "未绑定 Telegram 私信。",
    ["No allowed Telegram user is configured; " + "restrict access before enabling remote intake."]: "未配置允许的 Telegram 用户；启用远程接入前请限制访问。",
    ["No live Telegram listener status was " + "found."]: "未找到实时 Telegram 监听状态。",
  };
  return map[text] || text || "";
}
'@
            $displayTextPattern = '(?s)(?:function displayTextZh\(text\) \{\r?\n  const map = \{\r?\n.*?\r?\n  \};\r?\n  return map\[text\] \|\| text \|\| "";\r?\n\}\r?\n\r?\n)+function doctorStatusClass\(status\) \{'
            $newText = [regex]::Replace($newText, $displayTextPattern, ($displayTextBlock.TrimEnd() + "`r`n`r`nfunction doctorStatusClass(status) {"))
        }

        if ($group.Name -eq "settings\editors.js") {
            $settingsDisplayTextBlock = @'
  function settingsDisplayTextZh(text) {
    const map = {
      ["Failed" + " to load providers."]: "加载提供商失败。",
      ["Failed" + " to load config"]: "加载配置失败",
      ["Failed" + " to save config"]: "保存配置失败",
      ["Failed" + " to save key."]: "保存密钥失败。",
    };
    return map[text] || text || "";
  }
'@
            $settingsDisplayTextPattern = '(?s)(?:  function settingsDisplayTextZh\(text\) \{\r?\n    const map = \{\r?\n.*?\r?\n    \};\r?\n    return map\[text\] \|\| text \|\| "";\r?\n  \}\r?\n\r?\n)+  function renderApiKeysPanelError\(message\) \{'
            $newText = [regex]::Replace($newText, $settingsDisplayTextPattern, ($settingsDisplayTextBlock.TrimEnd() + "`r`n`r`n  function renderApiKeysPanelError(message) {"))
        }

        if ($group.Name -eq "settings\save-status.js") {
            $settingsSaveTextBlock = @'
function settingsSaveDisplayTextZh(text) {
  const map = {
    ["Sav" + "ed"]: "已保存",
    ["Sav" + "e"]: "保存",
    ["Failed" + " to save config"]: "保存配置失败",
    ["Failed" + " to save models.json"]: "保存 models.json 失败",
  };
  return map[text] || text || "";
}
'@
            $settingsSaveTextPattern = '(?s)(?:function settingsSaveDisplayTextZh\(text\) \{\r?\n  const map = \{\r?\n.*?\r?\n  \};\r?\n  return map\[text\] \|\| text \|\| "";\r?\n\}\r?\n\r?\n)+export function showSettingsSaveError\(messageEl, message\) \{'
            $newText = [regex]::Replace($newText, $settingsSaveTextPattern, ($settingsSaveTextBlock.TrimEnd() + "`r`n`r`nexport function showSettingsSaveError(messageEl, message) {"))
        }

        if (-not $CheckOnly -and $newText -ne $text) {
            $Utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($path, $newText, $Utf8NoBom)
        }
    }

    return $changed
}

# ── 主流程 ──
Write-Host "Picot Desktop GUI 汉化脚本（完整版）`n" -ForegroundColor Cyan
Write-Host "目录: $publicDir"
Write-Host "文件数: $($files.Count)`n"

$compatModified = Invoke-CompatibilityFixes -Root $publicDir -CheckOnly:$Check

$modified = 0
foreach ($f in $files) {
    $rel = [System.IO.Path]::GetRelativePath($publicDir, $f.FullName)
    Write-Host "$rel" -ForegroundColor Magenta -NoNewline
    $ok = Invoke-Translation -Path $f.FullName -Dict $fullDict -SafeOnlyKeys $jsSafeKeys -CheckOnly:$Check
    if ($ok) { $modified++ } else { Write-Host "  ✔" -ForegroundColor DarkGreen }
}

Write-Host "`n═══════ 摘要 ═══════" -ForegroundColor Cyan
if ($Check) {
    Write-Host "有 $modified 个文件需要翻译" -ForegroundColor Yellow
    Write-Host "有 $compatModified 处兼容性修复需要应用" -ForegroundColor Yellow
}
else {
    Write-Host "✓ 已修改 $modified 个文件" -ForegroundColor Green
    Write-Host "✓ 已应用 $compatModified 处兼容性修复" -ForegroundColor Green
    Write-Host "备份: $backupDir"
    Write-Host "还原: .\picot-han.ps1 -Reset" -ForegroundColor DarkGray
    Write-Host "`n⚠ 请重启 Picot Desktop 后生效" -ForegroundColor Yellow
}
