# S0-03 工程卫生与版本基线

日期：2026-08-12

## 生成文件策略

- `.dart_tool/`、`build/`、插件清单、IDE 状态、Android 本地配置和 Windows ephemeral 文件属于本机生成物，加入 `.gitignore`。
- `pubspec.lock` 作为 Flutter 应用依赖锁文件继续跟踪。
- `windows/flutter/generated_plugin_registrant.*` 是平台工程需要的生成源文件，继续跟踪；依赖变化后由 Flutter 工具重新生成，不手工编辑。
- `lib/core/database/app_database.g.dart`（如存在）只能由 Drift build_runner 根据源表生成，不能手工修改。
- 历史提交中已经跟踪的 `.dart_tool` 缓存不在本任务中批量删除，避免把缓存清理与用户已有产品改动混成不可审查的大 diff；后续应在独立工程卫生提交中移除其 Git 跟踪。

## 版本策略

版本事实源和递增规则见 [`docs/VERSION_POLICY.md`](../VERSION_POLICY.md)。本任务不改变当前发布版本，只建立一致性规则。

## 旧 worktree

`E:\project\idou\idou.worktrees\agents-diverse-walrus` 是活动仓库外的旧副本。当前 `git worktree list --porcelain` 只登记 `E:/project/idou/idou`；旧副本的 `.git` 文件指向已经不存在的 `E:/project/idou/idou/.git/worktrees/agents-diverse-walrus` 管理记录，因此无法安全判断其归属和是否仍有用户需要的未提交内容。本任务记录保留理由，不删除；删除前需先由用户确认或完成独立备份核验。
