# Picot Desktop GUI 汉化脚本

## 使用说明

### 快速汉化
1. 双击 `汉化.bat`
2. 输入 `1` 回车
3. 重启 Picot Desktop

### 命令行
```powershell
# 汉化
pwsh -NoProfile -File picot-han.ps1

# 预览（不修改文件）
pwsh -NoProfile -File picot-han.ps1 -Check

# 还原英文版
pwsh -NoProfile -File picot-han.ps1 -Reset
```

## 编码说明

> `汉化.bat` 使用 **UTF-8 编码**（含 BOM）编写。

如果双击运行后**中文显示为乱码**，请开启 Windows 的 UTF-8 支持：

```
设置 → 时间和语言 → 语言和区域 → 管理语言设置
→ 更改系统区域设置 → 勾选
"Beta 版: 使用 Unicode UTF-8 提供全球语言支持(U)"
→ 确定 → 重启电脑
```

> ⚠️ 开启后，系统默认代码页变为 `65001`（UTF-8），`汉化.bat` 中的中文可正常显示。
> 此选项为 Windows 可选功能，对其它程序一般无影响。

## 特点

- **安全**：HTML 全量翻译，JS 仅翻译长字符串（避免破坏代码逻辑）
- **幂等**：重复运行不会重复翻译已汉化的内容
- **自动备份**：首次运行自动备份到 `%LOCALAPPDATA%\Picot\.public-backup`
- **支持更新**：Picot 更新后再次运行脚本即可翻译新增内容

## 翻译范围

| 类别 | 内容 |
|------|------|
| 设置面板 | 设置、外观、保护、更新、Agent 配置等 |
| 界面标签 | 命令、技能、状态、文件、聊天、模型、Agent |
| 按钮文字 | 保存、取消、关闭、删除、重试、复制、安装、卸载 |
| 状态消息 | 已连接、已断开、加载中、检查中、下载中 |
| 操作提示 | 输入消息，或使用 / 调用技能、用户已中止 |
| 错误提示 | 安装失败、保存失败、健康检查失败、密钥不能为空 |
| Telegram | 连接/断开/检查/诊断 Telegram |
| Super Agent | 超级 Agent、Agent 收件箱、强制取消 |
| 对话框 | 确认、编辑器、输入 |

## 文件结构

```
Picot Desktop GUI 汉化脚本/
├── picot-han.ps1    # 主脚本
├── 汉化.bat          # 快捷启动（UTF-8 编码）
└── README.md        # 本文件
```
