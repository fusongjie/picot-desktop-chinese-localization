# Picot Desktop GUI 汉化脚本

## 使用说明

### 快速汉化
1. 双击 `汉化.bat`，输入 `1` 回车
2. 重启 Picot Desktop

> 选项 [1] 自动完成 GUI 汉化 + 社区包中文缓存写入。

### 命令行

```powershell
.\picot-han.ps1                # GUI 汉化
.\picot-han.ps1 -TranslatePackages  # GUI 汉化 + 包中文缓存
.\picot-han.ps1 -Check         # 预览（不修改）
.\picot-han.ps1 -Reset         # 还原英文版
```

### 社区包翻译

`package-translation-cache.json` 为已翻译的社区包缓存，`汉化.bat` 选项 [1] 会自动读取并写入中文包名/描述到 Picot 前端，无需额外操作。

### 编码说明

`汉化.bat` 使用 UTF-8 编码。如双击后中文乱码，开启系统 UTF-8 支持：

```
设置 → 时间和语言 → 语言和区域 → 管理语言设置
→ 更改系统区域设置 → 勾选 "Beta 版: 使用 Unicode UTF-8 提供全球语言支持(U)"
```

## 翻译范围

- **界面汉化**：设置面板、按钮、状态消息、操作提示、对话框等所有 UI 界面文本
- **包描述翻译**：社区包列表中的包名和描述自动显示为中文

## 特点

- **安全**：HTML 全文替换，JS 仅翻译长字符串，不破坏代码逻辑
- **幂等**：已汉化的内容不会重复修改
- **自动备份**：首次运行自动备份到 `%LOCALAPPDATA%\Picot\.public-backup`
- **支持更新**：Picot 更新后再次运行即可翻译新增内容

## 文件结构

```
Picot Desktop GUI 汉化脚本/
├── picot-han.ps1                 # 主汉化脚本（PowerShell）
├── 汉化.bat                       # 快捷启动
├── package-translation-cache.json # 社区包翻译缓存
└── README.md                     # 本文件
```
