---
name: chinese-localization
description: 软件汉化/中文本地化技能。用于将桌面应用、Web 前端、Electron/Tauri public 资源、JS/HTML/CSS/配置资源中的英文 UI 文案汉化为中文，尤其适用于无 i18n 框架、硬编码字符串、运行时模板字符串、textContent/title/aria-label/innerHTML 赋值、按钮状态、表格列标题、设置页状态文案、诊断/健康检查文案、Windows 路径显示修复等场景。触发词包括：汉化、本地化、中文化、i18n、l10n、翻译 UI、界面英文、按钮英文、状态英文、模板字符串汉化、textContent 汉化。
---

# Chinese Localization

用于把软件界面从英文汉化为中文，并尽量避免把代码标识符、协议值、状态值或路径逻辑误改坏。优先读取真实代码、日志和 UI 截图，再制定替换策略。

## 工作流

1. 定位目标目录和实际加载文件。确认是源码、构建产物、`public` 资源、asar 解包目录还是用户配置目录。
2. 先备份再修改。创建可恢复备份目录，恢复逻辑必须把备份内容复制回目标根目录，不能把备份目录嵌套进目标目录。
3. 扫描字符串来源。至少覆盖 HTML 文本、属性、JS 字符串字面量、模板字符串、`.textContent`、`.innerText`、`.innerHTML`、`.title`、`setAttribute("aria-label")`、按钮 busy/disabled 状态、表格列标题、诊断/健康检查返回文案。
4. 分类决定汉化方式。能直接替换的走字典；动态模板和状态显示走精确补丁或显示映射；代码协议值不翻。
5. 实施后验证。对 JS 跑语法检查，对历史破坏模式和残留英文做 `rg` 复扫。必要时启动应用或读取日志确认。

## 先备份

汉化脚本必须先备份原始文件。备份规则：

- 首次运行创建完整备份，例如 `.public-backup`。
- 备份已存在时不要覆盖，除非用户明确要求刷新备份。
- 提供 `-Reset` 或等价恢复入口。
- 恢复时先清空目标目录内容，再把备份目录内容复制回目标根目录。
- 不要恢复成 `public\.public-backup\...` 这种嵌套结构。

PowerShell 方向：

```powershell
function Clear-DirectoryContents($Path) {
  Get-ChildItem -LiteralPath $Path -Force | Remove-Item -Recurse -Force
}

function Copy-DirectoryContents($Source, $Destination) {
  Get-ChildItem -LiteralPath $Source -Force | Copy-Item -Destination $Destination -Recurse -Force
}
```

## 字符串位置

重点扫描这些业务逻辑：

- 固定 UI：`index.html`、`*.html`、模板里的 `<button>`、`<span>`、`<th>`、`placeholder`、`title`、`aria-label`。
- 运行时赋值：`.textContent = "..."`、`.innerText = "..."`、`.title = "..."`、`setAttribute("aria-label", "...")`。
- 模板渲染：`innerHTML = \`...\``、数组 `map().join("")` 拼出来的按钮、表格、空状态、卡片标题。
- 按钮状态：`Checking...`、`Saving...`、`Downloading...`、`Installing...`、`Retry`、`Remove`、`Update` 等运行中或失败后的按钮标签。
- 设置页：配置加载失败、保存失败、API key 弹窗、模型健康检查、provider/model 统计摘要。
- 诊断/健康检查：`Config`、`Bot`、`Security`、`Listener`、`No ... configured` 等后端返回后赋值到 UI 的文案。
- 统计页：`Overview`、`Total cost`、`Sessions`、`Tokens`、`Tools`、`Cost`、`Date`、`7d/30d/90d` 显示标签、`Mon/Wed/Fri` 图表标签、说明句。
- 工具/任务面板：任务状态、历史记录、审批/取消/忽略/清除按钮、目标项目标签。
- 路径显示：Windows 文件路径用反斜杠，显示层拆路径时需要支持 `/` 和 `\`。

常用扫描：

```powershell
rg -n '\.(textContent|innerText|title|ariaLabel)\s*=\s*' public --glob '!**/*.test.js'
rg -n 'setAttribute\(("aria-label"|''aria-label'')' public --glob '!**/*.test.js'
rg -n '<button[^>]*>[^<]*[A-Za-z][^<]*</button>|<span[^>]*>[^<]*[A-Za-z][^<]*</span>|<th[^>]*>[^<]*[A-Za-z][^<]*</th>' public --glob '!**/*.test.js'
rg -n 'Checking|Loading|Saving|Retry|Remove|Update|Cancel|Submit|Open Settings|Health|Unavailable|untitled' public --glob '!**/*.test.js'
```

## 可直接汉化

可以直接替换的内容通常满足：只作为用户可见文本出现，不参与逻辑判断、协议、选择器、键名或路径计算。

- HTML 标签文本：`<button>Cancel</button>` → `<button>取消</button>`。
- HTML 属性中的用户提示：`title="Open Settings"`、`placeholder="Search"`、`aria-label="Skills"`。
- 表格列标题：`Session`、`Model`、`Tokens`、`Tools`、`Cost`、`Date`。
- 静态空状态和说明句：`No API keys configured.`、`This action cannot be undone.`。
- 普通 JS 字符串字面量中明确是 UI 的句子：`"Checking..."`、`"Failed to save config"`。
- CSS 之外的纯展示文案；CSS 类名、id、data 属性名不属于展示文案。

直接替换要长串优先，避免 `Theme` 先替换导致 `Themes` 变成 `主题s`。对复数、大小写、整句优先建立词条。

## 需要映射汉化

这些内容不要改原始值，应该在显示层做映射：

- 枚举/状态值：`off/minimal/low/medium/high`、`ready/running/done/error`、`complete/error`。
- 后端返回的诊断标签和消息：`Config`、`Security`、`No live ... status was found.`。
- 运行时根据当前选择显示的值：例如思考力度中间显示的 `high`，内部仍应保存 `high`，UI 显示 `高`。
- 表格/卡片标题来自数据对象：`title`、`label`、`status` 先经过 `displayTextZh(value)` 再渲染。
- 错误对象、API 返回消息、保存状态：`resp?.error || "Failed to save key."` 应包一层显示映射。

推荐模式：

```javascript
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
```

插入映射时要幂等。重复运行脚本不能插入多个同名 `const` 或 `function`。如果脚本会多次运行，需要用正则清理重复块，或先检测函数是否存在。

如果脚本先插入映射、后执行通用翻译，映射的英文 key 可能被翻译器改掉。解决办法是拆分 key：

```javascript
function displayTextZh(text) {
  const map = {
    ["Failed" + " to save config"]: "保存配置失败",
    ["No live Telegram listener status was " + "found."]: "未找到实时 Telegram 监听状态。",
  };
  return map[text] || text || "";
}
```

## 需要精确补丁的场景

模板字符串含 `${...}` 时不要用全局字典盲替换，优先写精确补丁：

```javascript
statusText.textContent = `Retrying (${attempt}/${maxAttempts})...`;
// 改为
statusText.textContent = `正在重试 (${attempt}/${maxAttempts})...`;
```

适合精确补丁的内容：

- 模板字符串：`` `Update available: ${version}` ``。
- 由数组/函数拼出的 HTML：`` `<button>Approve ${ready}</button>` ``。
- 带表达式的 title/aria-label：`` `Open ${path} in ${app.label}` ``。
- 路径显示修复：`path.split("/")` → `path.split(/[/\\]/)`，仅用于文件系统路径，不用于 URL/router。
- 需要保留 data 值但改显示文本：`data-range-chip="7d"` 保留，按钮文本改为 `7天`。

## 不得汉化

这些内容不能翻，翻了会破坏代码或数据协议：

- JS 变量名、函数名、类名、导入导出名：`outputTokens`、`renderSessionHistory`、`createAppUpdater`。
- 对象属性名、API 字段、JSON key、数据库字段：`inputTokens`、`outputTokens`、`currentVersion`、`targetProject`。
- CSS 类名、id、选择器、data 属性名：`.btn-primary`、`#dialog-save`、`data-action`。
- 事件名、自定义事件、通道名：`picot-chat-config-updated`、`stateUpdate`。
- 协议值/枚举值/配置值：`high`、`medium`、`7d`、`30d`、`90d`、`general`。
- URL、路由、文件扩展名、包名、模块路径：`./app/updater.js`、`route.split("/")`。
- 品牌名和标准技术缩写：`Picot`、`Telegram`、`API`、`URL`、`JSON`、`HTML`、`CSS`、`Tauri`、`tmux`。
- 用户数据、文件名、模型名、工具名、项目路径、日志原文。
- 过短英文词的全局替换：`in`、`out`、`Mon`、`Wed`、`Fri`、`Model`、`Session`、`Update`、`Remove`、`high`。

已知破坏模式：

- `Mon` 全局替换会破坏 `Month`，出现 `周一th`。
- `Model` 全局替换会破坏标识符，出现类似 `inline模型Save`。
- `out` 全局替换会破坏 `outputTokens`。
- `7d/30d/90d` 全局替换会破坏范围逻辑和 `data-range-chip`。
- 把 `high` 直接替换成 `高` 会破坏 `data-level="high"` 或设置保存值。

## JS 替换策略

无 i18n 框架时，JS 只能做“安全字符串字面量替换”，不要对整个 JS 文件全文替换。

推荐原则：

- 跳过注释。
- 只扫描 `'...'`、`"..."`、`` `...` `` 字符串字面量。
- 模板字符串如果包含 `${...}`，默认跳过，除非写精确补丁。
- 短词默认禁止进入 JS 通用字典，除非包含空格、标点或明确安全。
- 保持大小写敏感配对，处理 `Theme/Themes`、`Prompt/Prompts` 这类复数问题。
- HTML 可以比 JS 放宽，但仍要避免改 `<script>` 中逻辑值。

PowerShell 实现方向：

```powershell
function Test-SafeJsTextKey([string]$Text) {
  if ($Text.Length -lt 6 -and $Text -notmatch '[\s\.\?\!\:\(\)/&…→↓·\[\]~-]') { return $false }
  return $true
}
```

## 术语规范

常用译法：

```text
Settings=设置
General=通用
Extensions=扩展
Skills=技能
Themes=主题
Prompts=提示词
Overview=概览
Sessions=会话
Messages=消息
Total tokens=总令牌
Input=输入
Output=输出
Tools=工具
Cost=费用
Date=日期
Update=更新
Remove=移除
Cancel=取消
Save=保存
Submit=提交
Retry=重试
Checking...=正在检查...
Loading...=正在加载...
Saving...=正在保存...
Downloading...=正在下载...
Installing...=正在安装...
Connected=已连接
Disconnected=已断开
Failed=失败
Error=错误
Done=完成
Unavailable=不可用
Archived=已归档
Pinned=已置顶
```

中文 UI 风格：

- 操作用短按钮：保存、取消、重试、移除、更新。
- 状态用短句：正在检查...、保存失败、已是最新版本。
- 中文与英文/数字之间留空格：`共 3 个文件`、`API 密钥`。
- 保留品牌和技术缩写：`Picot`、`Telegram`、`API`、`Tauri`。
- 表格和卡片标题要简洁，避免过长导致布局溢出。

## 验证清单

修改后必须至少做这些检查：

```powershell
# JS 语法检查
$base = "C:\Users\WhaleBay\AppData\Local\Picot\public"
$files = Get-ChildItem -LiteralPath $base -Recurse -File -Filter '*.js' |
  Where-Object { $_.FullName -notmatch '\.test\.js$' }
$bad = @()
foreach ($f in $files) {
  node --check $f.FullName 2>$null
  if ($LASTEXITCODE -ne 0) { $bad += $f.FullName }
}
"FailedJs=" + $bad.Count
$bad
```

```powershell
# 已知破坏模式
rg -n '周一th|inline模型|输出put|输入put|data-level="高"|DEFAULT_RANGE\s*=\s*"30天"|data-range-chip="7天"' $base --glob '!**/*.test.js'
```

```powershell
# 高价值 UI 残留
rg -n 'Checking\.\.\.|Check health|Update|Remove|Retry startup|Open Settings|No API keys configured|>Cancel<|>Delete<|>Submit<|>Save<|>All<|>Tasks<|Approve|Prompt AI|Force Cancel|Dismiss|History|Listening|>Archived<|>Pinned<' $base --glob '!**/*.test.js'
```

检查结果要分类：

- 真实 UI 残留：继续补直接替换、精确补丁或映射。
- 代码标识符/日志/注释/用户数据：通常不处理。
- 路由 URL 的 `split("/")`：不改。
- 文件系统路径的 `split("/")`：改成 `split(/[/\\]/)`。

## 完成标准

- 目标文件已备份，恢复命令可用。
- 汉化脚本可重复运行，不重复插入 helper。
- 关键 UI 文案已覆盖：静态标签、动态按钮、状态文案、诊断文案、模板字符串、表格列标题。
- 内部逻辑值、协议值、枚举值未被翻译。
- JS 语法检查通过。
- 已知破坏模式扫描无命中。
- 用户需要重启应用时明确说明。
