# ADR S1-03：图纸持久化 schema v3

## 状态

已采纳（2026-08-13）。

## 决策

`patterns` 从 schema v2 升级到 v3，增加以下字段：

- `palette_id`：图纸使用的色卡标识，可为空以兼容旧数据。
- `rows` / `cols`：网格尺寸，旧数据默认为 `0`。
- `grid`：序列化后的网格事实来源，旧数据保持 `NULL`。
- `inventory_deducted`：是否已经完成扣库，默认 `false`。
- `preview_image`：预览资源路径。
- `recognition_summary`：识别质量/摘要 JSON。

升级逻辑通过 Drift migration source 实现，并由 build_runner 生成 `app_database.g.dart`。v1 先沿用既有 v1→v2 色卡修复，再执行 v2→v3 加列；所有历史图纸标记为 `legacy`，不凭空生成网格。

## 兼容与安全

- 新安装由 Drift `createAll` 直接创建 v3 表。
- v1、v2 fixture 均保留图纸标题、原图路径和时间；v1 色卡仍升级为完整内置色卡。
- 迁移不删除历史库存或图纸记录；新字段使用可空/默认值。
- 生成文件只由 `dart run build_runner build --delete-conflicting-outputs` 更新，禁止手工编辑。

## 后续边界

本任务只完成 schema 和 DAO 读写字段准备，不实现保存并扣库事务、不迁移页面模型、不推断旧图纸网格。S1-04 处理媒体路径，后续图纸闭环任务负责原子保存与扣库。
