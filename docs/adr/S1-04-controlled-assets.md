# ADR S1-04：受控媒体存储与补偿清理

## 状态

已采纳（2026-08-13）。

## 决策

所有图纸原图、预览和完成照通过 `AssetStore` 写入应用支持目录，不再把 image_picker 缓存路径直接存入 `patterns`。`LocalAssetStore` 对每个资源执行：

1. 校验 `assetId` 不含绝对路径或 `..` 越界片段。
2. 在受控目录创建父目录。
3. 先写入带唯一后缀的临时文件，再原子重命名为最终路径。

`PersistAssets` 负责一次资源组的编排。任何后续资源或持久化提交失败，都会删除本次已经创建的路径；删除失败由 `AssetStore` 写入 cleanup queue，并可通过 `retryPendingCleanup` 重试。

## 边界

本任务提供可注入的 `PersistAssets`，其 `commit` 回调代表数据库提交边界。真实图纸保存/扣库事务将在后续任务中注入该回调，避免媒体和数据库写入各自管理生命周期。

## 验证

`test/asset_store_test.dart` 覆盖受控路径、原子落盘、路径穿越、后续资源失败补偿、提交失败补偿和首次清理失败后的重试。
