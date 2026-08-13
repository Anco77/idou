# ADR S1-02：Application 用例与基础设施端口

## 状态

已采纳（2026-08-12）。

## 决策

用例编排放在 `lib/application/`，外部能力的可替换契约放在 `lib/domain/ports/`：

- `PatternReader` + `LoadPatterns`：以 `PatternSummary` 提供图纸列表只读查询。
- `Clock` + `GetCurrentTime`：隔离系统时间，保证测试可重复。
- `AssetStore`：隔离受控媒体落盘和删除。
- `OcrPort`：隔离 OCR 平台调用，保留逐项坐标和置信度。

Drift、文件系统和现有 OCR 服务只在 `lib/infrastructure/` 中实现。`app/bootstrap/application_providers.dart` 负责把具体实现装配给 Provider；测试可以直接注入 fake port。

## 迁移范围

首页“最近图纸”是本任务迁移的现有只读流程。图纸中心的写入仓储、详情页和库存仓储仍保留旧 DAO 型接口，留给后续 schema/事务任务，不在本任务隐式改变数据模型。

## 验证

`test/application_ports_test.dart` 使用 fake `PatternReader`、`Clock`、`AssetStore` 和 `OcrPort`，验证用例不需要 Flutter、Drift 或真实文件/OCR 环境即可运行。
