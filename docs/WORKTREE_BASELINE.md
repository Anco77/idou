# 当前工作区验收基线

> 基线日期：2026-08-13
> Git 基点：`main@958a3f5`
> 用途：给当前未提交工作区中的每个改动指定唯一的后续验收责任，防止已有代码被重复宣称完成或越序扩展。

## 1. 基线结论

- Flutter 3.44.4 / Dart 3.12.2 工具链可用；Flutter CLI 在 Codex 中必须使用已授权的沙箱外执行入口。
- `lib/`、`test/` 格式门禁稳定；`flutter analyze --no-fatal-infos` 无 error/warning；全量 52 项测试通过。
- S0、S1 与 S2-01 的当前验收证据足以保留 `done`。
- S2-02、S2-03、S2-04 已有实现且核心回归通过，但分别缺少批量失败/Widget、页面状态 Widget、流水分页/索引/跳转等验收，回退为 `ready`。
- S3～S6 的提前实现均作为候选保留；除 S3-01 可开始验收外，其余任务按依赖保持 `planned`。
- 现有 102 个已被 Git 跟踪的 `.dart_tool` 文件是历史工程卫生债务，本轮没有改写或删除；应在独立、可审查的工程卫生提交中停止跟踪。

## 2. 状态分类

| 分类 | 任务 | 当前判断 |
|---|---|---|
| 已实现并通过当前门禁 | S0-01～S0-05、S1-01～S1-04、S2-01 | 保留 `done` |
| 部分实现，需补验收 | S2-02、S2-03、S2-04、S3-01～S3-05、S4-01～S4-03、S5-01～S5-03 | 保留代码，按依赖重新执行 |
| 只有边界/脚手架 | S4-04、S4-05、S5-04、S6-01～S6-03 | 不视为功能完成 |
| 尚未实施 | S6-04 | 依赖全部发布门禁 |

## 3. 唯一文件归属

“归属”表示下一次对该文件的完整验收责任，不表示该文件只能永久由一个任务修改。若后续任务确需修改，必须在开始记录中显式转移归属。

### 3.1 工程与文档

| 文件或精确集合 | 唯一归属 |
|---|---|
| `.gitignore`、`docs/VERSION_POLICY.md`、`docs/RELEASE_CHECKLIST.md`、`docs/adr/S0-03-engineering-baseline.md`、`test/version_policy_test.dart` | S0-03 |
| `docs/FLUTTER_TOOLCHAIN.md`、本轮纯机械格式化文件、`test/widget_test.dart` | S0-04 |
| `AGENTS.md`、`.agents/skills/**`、`docs/00_项目总览与现状审计.md`、`docs/01_目标架构.md`、`docs/02_产品目标与需求基线.md`、`docs/03_实施计划书.md`、`docs/04_AI全流程执行计划.md`、`docs/AI_TASKS.yaml`、`docs/AI_PROGRESS.md`、`docs/README.md`、本文 | S0-05 |
| `docs/adr/S0-02-image-change-review.md` | S0-02 |
| 其他 `docs/adr/<TASK-ID>-*.md` | 文件名中的 TASK-ID；S4-01 的两份 ADR 留到 S4-01 合并审查 |

S0-04 机械格式化集合为：

```text
lib/core/database/tables/color_standards_table.dart
lib/core/database/tables/inventory_logs_table.dart
lib/core/database/tables/inventory_table.dart
lib/core/database/tables/pattern_consumptions_table.dart
lib/core/services/app_update_service.dart
lib/core/services/user_settings_service.dart
lib/domain/services/pattern_recognition_service.dart
lib/presentation/common/color_card.dart
lib/presentation/common/low_stock_banner.dart
lib/presentation/common/quantity_selector.dart
lib/presentation/common/restock_dialog.dart
lib/presentation/common/update_dialog.dart
lib/presentation/pages/ai_generate/ai_generate_page.dart
lib/presentation/pages/ai_generate/preview_page.dart
lib/presentation/pages/home/home_page.dart
lib/presentation/pages/inventory/color_detail_page.dart
lib/presentation/pages/inventory/inventory_page.dart
lib/presentation/pages/inventory/operation_history_page.dart
lib/presentation/pages/patterns/patterns_page.dart
lib/presentation/pages/profile/profile_page.dart
lib/presentation/pages/recognition/recognition_result_page.dart
lib/presentation/providers/settings_providers.dart
lib/presentation/providers/update_providers.dart
lib/presentation/router/app_router.dart
lib/presentation/theme/app_colors.dart
test/widget_test.dart
```

其中有后续业务任务需要继续修改的文件，必须在对应任务开始时从 S0-04 转移归属，不能把格式化本身算作业务实现。

### 3.2 领域、数据与豆仓

| 文件或精确集合 | 唯一归属 |
|---|---|
| `lib/domain/models/**`、`test/domain_models_test.dart`、`docs/adr/S1-01-domain-models.md` | S1-01 |
| `lib/app/bootstrap/application_providers.dart`、`lib/application/common/get_current_time.dart`、`lib/application/patterns/load_patterns.dart`、`lib/domain/ports/{clock,ocr_port,pattern_reader}.dart`、`lib/infrastructure/common/system_clock.dart`、`lib/infrastructure/patterns/patterns_reader_adapter.dart`、`test/application_ports_test.dart`、`docs/adr/S1-02-application-ports.md` | S1-02 |
| `lib/core/database/app_database.dart`、`lib/core/database/app_database.g.dart`、`lib/core/database/tables/patterns_table.dart`、`test/database_migration_test.dart`、`docs/adr/S1-03-schema-v3.md` | S1-03 |
| `lib/application/assets/persist_assets.dart`、`lib/domain/ports/asset_store.dart`、`lib/infrastructure/filesystem/local_asset_store.dart`、`test/asset_store_test.dart`、`docs/adr/S1-04-controlled-assets.md` | S1-04 |
| `test/inventory_transaction_test.dart` | S2-01 |
| `lib/core/database/daos/inventory_dao.dart`、`lib/data/repositories/inventory_repository_impl.dart`、`lib/domain/repositories/inventory_repository.dart`、`lib/domain/services/inventory_service.dart`、`lib/presentation/pages/inventory/bulk_inventory_page.dart`、`test/batch_inventory_test.dart` | S2-02，S2-04 如需修改 DAO 必须显式转移 |
| `lib/presentation/providers/inventory_providers.dart`、`test/inventory_state_test.dart` | S2-03 |
| `test/inventory_reversal_test.dart` | S2-04 |

### 3.3 识别、编辑、转换与交付候选

| 文件或精确集合 | 唯一归属 |
|---|---|
| `lib/test_support/image_samples.dart`、`test/image_sample_metrics_test.dart`、`docs/adr/S3-01-image-samples.md` | S3-01 |
| `lib/core/utils/grid_detector.dart`、`test/grid_test.dart`、`docs/adr/S3-02-grid-diagnostics.md` | S3-02 |
| `lib/core/services/ocr_service.dart`、`lib/infrastructure/ocr/ocr_port_adapter.dart`、`test/services/ocr_service_test.dart` | S3-03 |
| `lib/core/services/bead_pattern_service.dart`、`lib/core/utils/color_matcher.dart`、`lib/domain/services/recognition_fusion.dart`、`test/services/color_matcher_test.dart`、`test/recognition_fusion_test.dart`、`docs/adr/S3-04-recognition-fusion.md` | S3-04 |
| `lib/application/recognition/recognize_pattern.dart`、`lib/presentation/pages/recognition/upload_page.dart`、`test/recognize_pattern_test.dart`、`docs/adr/S3-05-recognition-flow.md` | S3-05 |
| `lib/domain/services/editor_commands.dart`、`lib/domain/services/editor_quality.dart`、`lib/presentation/controllers/pattern_editor_controller.dart`、`test/editor_commands_test.dart`、`test/editor_quality_test.dart`、`tool/pure_editor_regression.dart`、两份 S4-01 ADR | S4-01 |
| `lib/presentation/widgets/pattern_editor.dart`、`test/pattern_editor_widget_test.dart` | S4-02 |
| `lib/core/database/daos/patterns_dao.dart`、`lib/presentation/providers/patterns_providers.dart`、`test/pattern_persistence_test.dart`、`docs/adr/S4-03-pattern-save.md` | S4-03 |
| `lib/presentation/pages/patterns/pattern_detail_page.dart` | S4-05；其中提前接入的编辑器由 S4-02 先验收 |
| `lib/presentation/pages/ai_generate/crop_page.dart` | S5-01 |
| `lib/domain/services/pattern_generation_service.dart` | S5-03；采样部分在 S5-02 开始时转移 |
| `lib/application/export/export_pattern.dart`、`test/pattern_export_test.dart`、`docs/adr/S6-01-pattern-export.md` | S6-01；当前只有 CSV/JSON 脚手架 |
| `lib/application/backup/backup_manifest.dart`、`test/backup_manifest_test.dart`、`docs/adr/S6-02-backup-manifest.md` | S6-02；当前只有 manifest 脚手架 |
| `docs/adr/S4-04-save-deduct-boundary.md` | S4-04 |
| `docs/adr/S6-03-platform-verification.md` | S6-03 |

## 4. 已知架构债务

- 旧 `lib/domain/services/pattern_generation_service.dart`、`pattern_recognition_service.dart` 仍依赖 `dart:io`。
- 旧 `lib/domain/repositories/*` 和 `inventory_service.dart` 仍暴露 DAO 类型。
- 多个 presentation 页面仍直接依赖 DAO、Repository 实现和文件系统。
- 这些是已知迁移目标，不影响新 `domain/models` 与 application ports 的边界成立，但任何新代码不得继续扩大反向依赖。
- `build_runner` 在 Dart 3.12.2 下提示 analyzer language version 3.9 较旧；当前生成成功且全量测试通过，依赖升级应独立执行，不能与功能任务混合。

## 5. 后续验证矩阵

| 顺序 | 任务 | 重点补齐门禁 |
|---:|---|---|
| 1 | S2-02 | 批量写入失败注入、条件更新/并发语义、批量 UI Widget |
| 2 | S2-03 | 阈值跨页面联动、加载/空/错误/重试 Widget |
| 3 | S2-04 | patternId 跳转、reason 兼容、分页/筛选/索引与冲正防重 |
| 4 | S3-01 | 真实生成器、授权/变换字段、可落盘机器指标报告 |
| 5 | S3-02～S3-05 | geometry/OCR/融合指标、Android smoke、isolate/取消/性能 |
| 6 | S4-01～S4-05 | 编辑性能/Golden、真实保存、单事务扣库、失败注入、资源清理 |
| 7 | S5-01～S5-04 | EXIF/裁剪坐标、采样、背景/限色、轮廓与共享闭环 |
| 8 | S6-01～S6-04 | PNG/PDF/CSV、完整备份恢复、双平台/离线/更新安全与发布授权 |

所有任务继续遵守：一次一个 `in_progress`；聚焦门禁通过后再跑全量门禁；未完成的候选实现不删除、不提交完成声明。
