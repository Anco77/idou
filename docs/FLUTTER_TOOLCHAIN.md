# Flutter 工具链运行说明

## 已验证环境

- Flutter：3.44.4 stable，`D:\flutter`
- Dart：3.12.2
- Windows：Windows 11 25H2
- Android SDK：36.1.0
- Visual Studio Build Tools：2022 17.14

## Codex 执行约束

Flutter CLI 会写入 `D:\flutter\bin\cache\lockfile`。项目工作区沙箱只能写仓库目录，因此在 Codex 中运行 `flutter` 命令必须使用已授权的沙箱外 Flutter 前缀；若在沙箱内直接调用，会出现“cannot access lockfile”，这不是 SDK 文件损坏或 Windows ACL 异常。

直接 Dart SDK 命令可在沙箱内用于格式化纯 Dart 源码：

```powershell
D:\flutter\bin\cache\dart-sdk\bin\dart.exe format --output=none --set-exit-if-changed lib test
```

## 正确命令

```powershell
flutter --version
flutter doctor -v
flutter pub get
flutter analyze --no-fatal-infos
flutter test test/editor_commands_test.dart -r expanded
flutter test -r compact
```

Flutter 工程测试必须使用 `flutter test`。不要执行：

```powershell
dart run test/editor_commands_test.dart
```

该命令把 Flutter 测试文件当成普通 Dart 脚本编译，并会在当前依赖图的 native-assets FFI 转换阶段触发 `InvalidType is not a subtype of FunctionType`。这不是测试失败；测试主体尚未开始。`dart test` 也不是替代入口，因为项目没有直接依赖 `package:test`，测试框架由 `flutter_test` 提供。

## 环境变量

当前 SDK remote 为：

```text
https://v4.gh-proxy.org/https://github.com/flutter/flutter.git
```

若进程环境中的 `FLUTTER_GIT_URL` 指向其他仓库，`flutter doctor` 会给出上游不一致警告。执行诊断或升级前应让它与 SDK remote 一致。`PUB_HOSTED_URL` 和 `FLUTTER_STORAGE_BASE_URL` 当前使用 Flutter 中国镜像；网络探测偶发超时不影响本地测试，但依赖下载失败时应记录具体 URL 和超时。

## 2026-08-13 验证基线

- `flutter --version`：1.4 秒，成功。
- `flutter doctor -v`：主要本地平台工具链通过；外部 GitHub 网络探测有一次超时。
- `flutter pub get`：6.9 秒，成功。
- 聚焦编辑器、命令和持久化测试：5 项通过。
- 格式门禁：96 个文件，0 个变化。
- `flutter analyze --no-fatal-infos`：成功，无 error/warning，42 条 info。
- `flutter test -r compact`：52 项全部通过，10.4 秒。

