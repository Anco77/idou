# idou Release Checklist

> Release: 未指定
> Candidate commit: 未指定
> Target branch/tag: 未指定
> Status: not_started

## 1. Scope

- [ ] 所有纳入版本的任务为 `done`
- [ ] 没有意外的 `in_progress` / 未解释工作区修改
- [ ] 需求、架构、README、执行日志和发布说明已更新
- [ ] 已列出不纳入版本的已知问题

## 2. Quality gates

- [ ] Format check
- [ ] Flutter analyze
- [ ] Full Flutter tests
- [ ] Database new-install and upgrade fixtures
- [ ] Image regression metrics
- [ ] Android target build and smoke test
- [ ] Windows target build and smoke test
- [ ] Offline core-flow verification

## 3. Data safety

- [ ] 从上一公开版本升级时数据数量和余额一致
- [ ] 库存/日志/图纸用量对账一致
- [ ] 媒体路径均在受控目录
- [ ] 备份和恢复演练通过
- [ ] 迁移失败恢复方案已验证

## 4. Version and artifacts

- [ ] `pubspec.yaml` 版本
- [ ] `version.json` 版本和下载地址
- [ ] 数据库 schema 版本
- [ ] Changelog / release notes
- [ ] Git tag
- [ ] Android artifact + SHA-256
- [ ] Windows artifact + SHA-256

## 5. Authorization and remote delivery

- [ ] 用户已授权 commit
- [ ] 用户已授权 push
- [ ] 用户已授权 tag
- [ ] 用户已授权 publish/upload
- [ ] 远端 commit/tag 与本地审核对象一致
- [ ] 远端制品哈希验证完成

## 6. Sign-off

```text
Gate command/results:
Artifacts/checksums:
Known issues:
Rollback/backup advice:
Remote URLs:
Verified at:
```
