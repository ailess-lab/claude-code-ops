---
name: repo-baseline
description: GitHub 开源仓库基线体检。需要核对仓库 description/topics/README/LICENSE/Discussions 是否达到 strategy 基线并补齐缺失项时，使用本 skill。
---

# repo-baseline — 仓库基线体检

> 对照 strategy 的「仓库基线」，逐项核对线上实际状态，缺啥补啥。**死规则、逐项查，不靠"看着差不多"。**

## 前置：读基线

读项目 `strategy.md` 的「仓库基线」段——它定义这个仓库**应该长什么样**：

```
## 仓库基线
- 仓库: owner/repo
- description: 一句话（来自外部口径）
- topics: [t1, t2, t3, …]   # ≥3
- 必备文件: README.md, LICENSE, OPS-CHANGELOG.md
- 功能开关: Discussions 开启
```

**strategy 没有「仓库基线」段 → 停，写 escalation 请主管补**（你无权定基线）。

## 步骤（逐项查，gh CLI）

### 1. 拉线上实际
```
gh repo view {owner}/{repo} --json description,repositoryTopics,hasDiscussionsEnabled,licenseInfo
gh api repos/{owner}/{repo}/contents/README.md --jq '.name' 2>/dev/null   # 有输出=存在
gh api repos/{owner}/{repo}/contents/LICENSE  --jq '.name' 2>/dev/null
```

### 2. 逐项对照基线

| 项 | 查什么 | FAIL 归类 |
|---|---|---|
| description | 与基线一致？ | 轻量 → 直接修 |
| topics | 覆盖基线且 ≥3？ | 轻量 → 直接补 |
| Discussions | 已开？ | 轻量 → 直接开 |
| README | 存在？ | **重量 → 上报** |
| LICENSE | 存在？ | **重量 → 上报** |

### 3. 轻量项 FAIL → 直接修到基线值
```
gh repo edit {owner}/{repo} -d "{基线 description}"
gh repo edit {owner}/{repo} --add-topic t1 --add-topic t2
gh repo edit {owner}/{repo} --enable-discussions
```
修完在回执记"已修 XX → 基线值"。

### 4. 重量项 FAIL → 不自动动手
README/LICENSE 缺失、仓库空壳、需删/重建 → **写 tasks（注明具体缺什么）+ escalation**，绝不擅自创建/重建仓库。

## 常见问题与处理

| 问题 | 处理 |
|---|---|
| strategy 无「仓库基线」 | 停，escalation 请主管补，别自己定 |
| `gh repo edit` 权限不足 | 记 escalation（账号/权限问题），别反复试 |
| topics 已有但不含基线项 | `--add-topic` 补，**不删**已有的 |
| README 存在但内容差 | 体检只管"存在性"；内容优化是 `readme-rewrite` 的事，不在这 |
| description 改完没生效 | `gh repo view` 复核一次；仍不符记 escalation |

## 验收清单（回执逐项勾）
- [ ] 5 项全查了（description / topics / Discussions / README / LICENSE）
- [ ] 轻量项 FAIL 已 gh 修到基线值，并复核
- [ ] 重量项 FAIL 已写 tasks + escalation
- [ ] 回执逐项记了结果（PASS / 已修 / 已上报）
