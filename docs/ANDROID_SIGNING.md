# Android 发布签名管理

本文只记录密钥位置、证书指纹和使用流程。任何密码、私钥内容或完整 `key.properties` 都不得写入 Git、文档、Issue、日志或聊天。

## 安全位置

本机发布签名文件保存在仓库外：

```text
E:\project\idou\.secrets\android-release\upload-keystore.jks
E:\project\idou\.secrets\android-release\key.properties
```

目录及两个文件的 Windows ACL 仅允许：

- `DESKTOP-BF35M0F\14504`：完全控制
- `NT AUTHORITY\SYSTEM`：完全控制

原回收站中的 `upload-keystore.jks` 与 `android/key.properties` 已在完成复制、哈希校验、证书校验和正式签名构建后删除。

## 身份与完整性

- Alias：`upload`
- Keystore 创建日期：2026-07-01
- Keystore 文件 SHA-256：`71C10F39497559B11C171E4B4413713B3844276839C3D26E2D10DF3F92090513`
- 签名证书 SHA-256：`0535EED85C0791B93D1FE4670D8ED008C99E8A9E473B9F9367DA49630513F28F`
- 证书到期时间：2053-11-16 23:28:15 CST
- 该证书与 GitHub `v1.3.7` APK 的签名证书完全一致。

Keystore 文件哈希用于检查本地副本是否损坏；APK 升级兼容性必须比较证书 SHA-256，不能比较 keystore 文件哈希。

## 构建

正式签名配置不复制到 `android/`。构建进程通过环境变量读取仓库外配置：

```powershell
$env:JAVA_HOME = 'E:\project\idou\.tools\jdk21\jdk-21.0.12+8'
$env:IDOU_ANDROID_KEY_PROPERTIES = 'E:\project\idou\.secrets\android-release\key.properties'
flutter build apk --release --build-name=1.4.0-alpha.1 --build-number=2101
```

如果没有找到完整 release signing 配置，Gradle 默认拒绝 release 构建。`IDOU_ALLOW_QA_DEBUG_SIGNING=true` 只允许生成不能覆盖正式安装的内部 QA 包，正式发布流程不得设置它。

从 `v1.3.7` 升级时，新 APK 必须同时满足：

- applicationId 为 `com.example.idou`；
- versionCode 大于 `2001`；
- 签名证书 SHA-256 与上述证书一致。

## 验证

构建后必须使用 Android SDK 的 `apkanalyzer` 和 `apksigner` 核对包名、versionName、versionCode、签名方案与证书指纹。不得仅以 Gradle 构建成功作为签名验收。

建议每次发布前再执行一次：

```powershell
Get-FileHash -Algorithm SHA256 E:\project\idou\.secrets\android-release\upload-keystore.jks
icacls E:\project\idou\.secrets\android-release
```

## 备份与恢复

- 当前安全目录解决了误删和仓库泄露风险，但仍位于 E 盘。
- 已在独立物理磁盘 F（Disk 0，E 盘位于 Disk 1）创建 AES-256 加密灾备：

  ```text
  F:\idou-secure-backup\android-release\idou-android-release-signing-2026-08-14.7z
  ```

- 归档使用 7-Zip `7zAES` 并启用文件名加密，包含 `upload-keystore.jks` 与 `key.properties`；创建后已执行完整解密测试。
- 归档 SHA-256：`A3EFE0CB365D3136F5DB364A0A366C59BDA7A539FB8B77A838B639F755FFA659`
- F 盘备份目录与归档 ACL 仅允许当前用户和 SYSTEM。
- F 盘是独立物理盘，但仍是常在线本机磁盘，只能防范单盘损坏，不能防范整机丢失、勒索软件或同地点灾害。仍须另做至少一份离线或异地加密副本。
- `upload-keystore.jks`、`key.properties` 和密码恢复说明必须作为同一恢复集合管理，但密码应与密钥文件分离保存。
- 恢复后先核对 keystore 文件 SHA-256，再用 `keytool` 核对证书 SHA-256，最后构建一个非正式 APK 并用 `apksigner` 复核。
- 丢失该私钥后，未来版本无法覆盖升级现有正式安装；不得重新生成同名密钥冒充旧密钥。
