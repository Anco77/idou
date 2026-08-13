# ADR S1-01：建立色卡与图纸领域模型

## 状态

已采纳（2026-08-12）。

## 决策

先在 `lib/domain/models/` 建立不依赖 Flutter、Drift、文件系统或平台插件的最小领域模型：

- `bead_color.dart`：单个颜色及 RGB 校验；按稳定 `id` 判断相等。
- `palette.dart`：不可变色卡，支持按 `id`、规范化后的 `code` 查询。
- `pattern.dart`：`PatternCell`、`PatternGrid` 和 `PatternDraft`，表达图纸单元、网格聚合及编辑快照。

`PatternGrid` 将 `null` 作为空格；用量由非空单元实时聚合；`withCell` 通过深拷贝返回新网格，保留旧快照。色卡查询只依赖 `Palette` 自身，因此不要求库存 Provider 先加载。

## 未做的迁移

本任务不迁移现有 `StandardColor`、DAO 的 `PatternItem` 或识别/转换服务结果模型，也不改变数据库 schema。后续由 S1-02/S1-03 通过端口和 mapper 渐进接入，避免一次性破坏已有页面与持久化数据。

## 验证

- `test/domain_models_test.dart` 覆盖色卡独立查询、空格/用量、手工覆盖、矩形校验和不可变编辑快照。
- 领域目录导入扫描无 Flutter/Drift/IO 依赖。
