# idou - 拼豆库存管理

一款跨平台的拼豆（ fuse beads ）色号库存管理应用，支持 Windows 和 Android。

## 功能

- **库存管理**：按色系分组展示所有色号，支持展开/折叠
- **补货/消耗**：单个或批量操作，记录变更日志
- **余量排序**：一键按库存数量排序，扁平列表展示
- **四级预警**：< 400 紧缺 / 400-700 较少 / 700-1000 适中 / > 1000 充足，颜色+进度条直观提示
- **一键初始化**：将所有色号库存重置为指定数量
- **色号详情**：查看单个色号的操作历史
- **自动更新**：通过 GitHub Releases 检查更新并下载安装
- **搜索过滤**：按色号或名称快速搜索

## 技术栈

| 技术 | 用途 |
|------|------|
| Flutter 3.x | 跨平台 UI 框架 |
| Riverpod | 状态管理 |
| Drift (SQLite) | 本地数据库 |
| go_router | 路由导航 |
| package_info_plus | 版本信息 |
| http | 网络请求 |
| open_filex | Android APK 安装 |

## 构建

### 环境要求

- Flutter SDK >= 3.0
- Windows 构建：Visual Studio 2022（含 C++ 工作负载）
- Android 构建：Android Studio + Android SDK

### Windows

```bash
flutter build windows --release
```

输出：`build\windows\x64\runner\Release\idou.exe`

### Android

```bash
flutter build apk --release
```

输出：`build\app\outputs\flutter-apk\app-release.apk`

## 色系说明

| 系列 | 名称 | 示例色号 |
|------|------|---------|
| A | 黄色系 | A1, A2, ... |
| B | 绿色系 | B1, B2, ... |
| C | 蓝色系 | C1, C2, ... |
| D | 紫色系 | D1, D2, ... |
| E | 粉色系 | E1, E2, ... |
| F | 红色系 | F1, F2, ... |
| G | 棕色系 | G1, G2, ... |
| H | 黑白灰 | H1, H2, ... |
| M | 哑色系 | M1, M2, ... |

色号格式参照 [pindou.online/colors](https://www.pindou.online/colors)。

## 自动更新

应用启动时自动检查 GitHub Releases 最新版本，支持：
- Windows：下载 `.exe` 安装包
- Android：下载 `.apk` 并通过系统安装器安装

## 许可证

MIT
