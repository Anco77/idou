# S0-02 图像改动审查记录

日期：2026-08-12

本记录对应需求 `REC-002`、`REC-003`、`REC-005`、`CONV-001`、`CONV-004`、`CONV-006`。

| 文件 | 决策 | 依据 |
|---|---|---|
| `lib/core/services/bead_pattern_service.dart` | 保留并补测 | 空白格必须与白色串珠分开；保留中心采样、透明度过滤和手工改单格入口。颜色数量以最终网格重新统计，避免低频颜色被静默丢弃。 |
| `lib/core/services/ocr_service.dart` | 保留并调整 | hOCR 解析抽为纯函数，统一使用放大后坐标映射到裁剪坐标，并使用半开区间 `floor` 映射网格；非法色号和重复单元被拒绝。 |
| `lib/core/utils/color_matcher.dart` | 保留并调整 | 保留 CIEDE2000 和调色板约束；增加空色库/非法网格参数保护，量化主色采样和调色板归并均有确定性测试。 |
| `lib/core/utils/grid_detector.dart` | 保留并补测 | 保留规则序列检测方向，支持矩形网格并返回行列、裁剪框和置信度；新增合成矩形网格与无网格拒绝测试。 |
| `lib/domain/services/pattern_generation_service.dart` | 保留，暂不扩展 | 裁剪、缩放、采样、背景过滤、限色和预览职责边界清晰；本任务不引入共享编辑器或持久化逻辑。 |
| `lib/presentation/pages/ai_generate/crop_page.dart` | 保留，暂不扩展 | 归一化裁剪框到原图像素坐标的映射清晰；真实 EXIF/旋转和跨平台 Widget 验收留给 `S5-01`。 |
| `lib/presentation/pages/recognition/upload_page.dart` | 保留并调整 | 自动检测失败回到明确的手动设置入口；检测异常不再让页面停留在处理中；行列输入仍在提交前校验范围。 |

## 当前验证边界

- 聚焦图像回归：10 个测试通过。
- 全量 Flutter 测试：11 个测试通过。
- `flutter analyze`：无 error，但仍有历史 info/warning；这些非本任务范围的 lint 将在工程卫生任务中集中处理。
- 未使用真实版权不明图纸作为自动准确率证据；ground-truth 样本和指标运行器属于 `S3-01`。
