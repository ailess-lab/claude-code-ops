---
name: repo-baseline
description: GitHub 开源仓库基线体检。需要核对仓库 description/topics/README/LICENSE/Discussions 是否达到 strategy 基线并补齐缺失项时使用。也用于新项目初始化后的首次体检，以及任何对外发布（发帖/推文/文章带仓库链接）前的门面检查——仓库可见性、脱敏、链接可访问（发布前置 0 步）。
---

# repo-baseline — 仓库基线体检

> 对照 strategy 的「仓库基线」或当前 strategy 定位，逐项核对线上实际状态，缺啥补啥。**死规则、逐项查，不靠"看着差不多"。**

## 前置：读基线

读项目 `strategy.md`——找到「仓库基线」段或从「外部口径」推断基线：

```
## 仓库基线
- 仓库: owner/repo
- description: 一句话（来自外部口径）
- topics: [t1, t2, t3, …]   # ≥3
- 必备文件: README.md, LICENSE, OPS-CHANGELOG.md
- 功能开关: Discussions 开启
```

**strategy 没有「仓库基线」段 → 从「外部口径」推导，写到回执让主管确认。**

## 步骤（逐项查，gh CLI）

### 1. 拉线上实际

```
# 仓库元数据
gh api repos/{owner}/{repo} --jq '{description, topics, license: .license.spdx_id, has_discussions: .has_discussions_enabled, has_issues, has_wiki, homepage, stargazers_count, forks_count, open_issues_count, pushed_at}'

# 必备文件存在性（有输出 = 存在）
gh api repos/{owner}/{repo}/contents/README.md --jq '.name' 2>/dev/null
gh api repos/{owner}/{repo}/contents/LICENSE  --jq '.name' 2>/dev/null
gh api repos/{owner}/{repo}/contents/OPS-CHANGELOG.md --jq '.name' 2>/dev/null

# README 内容概览（体检只看结构和关键段落）
gh api repos/{owner}/{repo}/readme --jq '.content' | base64 -d | head -50
```

### 2. 逐项对照

| 项 | 查什么 | FAIL 归类 |
|---|---|---|
| description | 与基线一致？覆盖核心定位词？ | 轻量 → 直接修 |
| topics | 覆盖基线且 ≥3？ | 轻量 → 直接补 |
| Discussions | 已开？ | 轻量 → 直接开 |
| README | 存在？有定位/Quick Start/ license？ | **重量 → 上报** |
| LICENSE | 存在？ | **重量 → 上报** |
| OPS-CHANGELOG | 存在？ | 轻量 → 创建空模板 |

### 3. 轻量项 FAIL → 直接修到基线值

```
gh api repos/{owner}/{repo} -X PATCH -f description="{基线 description}"
# topics 逐个加（不删已有的）
gh api repos/{owner}/{repo}/topics -X PUT -f names='["t1","t2","t3"]'
gh api repos/{owner}/{repo} -X PATCH -f has_issues=true -f has_projects=true
```

OPS-CHANGELOG 缺失 → 用 strategy 里确认的空模板通过 `gh api` 创建：
```
CONTENT=$(printf '# OPS-CHANGELOG\n\n- YYYY-MM-DD | 类型 | 一句话' | base64 | tr -d '\n')
gh api repos/{owner}/{repo}/contents/OPS-CHANGELOG.md -X PUT -f message="Add OPS-CHANGELOG.md" -f content="$CONTENT"
```

### 4. 重量项 FAIL → 不自动动手

README/LICENSE 缺失、仓库空壳、需删/重建 → **写 tasks（注明具体缺什么）+ escalation**，绝不擅自创建/重建仓库。

### 5. 写体检报告

在 `projects/{标识}/intel/` 下写 `YYYY-MM-DD-repo-baseline.md`，格式：

```markdown
# 仓库基线体检：{项目名}

## 元数据
| 指标 | 值 |
|---|---|
| Stars | X |
| Forks | X |
| Issues | X |
| 最后更新 | YYYY-MM-DD |

## 检查结果
| 项 | 状态 | 动作 |
|---|---|---|
| description | ✅/⚠️ | 已修 → 新值 / 不需改 |
| topics | ✅/⚠️ | 已补 t1, t2 |
| ... | ... | ... |

## 需要关注的问题
- （重量项或有品味的判断）
```

## 对外发布门面检查（0 步，发布前强制前置）

> **这不是日常基线体检**，是任何对外发布（发帖 / 推文 / 文章里带仓库链接）前的**强制前置**，排在所有文案打磨之前。
> 6/13 教训：仓库私有 + 未脱敏却已发推广帖，读者点链接 = 404，42h 零互动。门面是 0 步，跳过 = 推广无效甚至有害。**四项任一不过 = 禁止发布。**

### 门面四项

| # | 项 | 查（gh CLI） | FAIL 怎么办 |
|---|---|---|---|
| 1 | 仓库可见性 | `gh api repos/{owner}/{repo} --jq '.private'` 必须 `false` | 设公开（`gh repo edit {owner}/{repo} --visibility public`，对外不可逆，对谈主管确认）或停发。**绝不带私仓链接发** |
| 2 | 内容脱敏 | 见下「脱敏检查」 | 含内部信息 → 先脱敏（运营层活），不脱敏不发 |
| 3 | 链接可访问 | 见下「链接检查」 | 死链 → 修；带死链发 = 读者 404 |
| 4 | 文案与实际一致 | 文案声称（"开源""可访问"）对照仓库实际状态 | 不一致 → 改文案（交 promo-plan），不自欺 |

### 脱敏检查（门面第 2 项）

仓库 public = 全网能读**所有文件 + git 历史**。

1. 取敏感词清单：项目的 `config/directives.md` 红线段 / 项目自己的脱敏清单。没有 → 问主管，**不自己猜哪些敏感**。
2. **fresh clone** 后查（不能只查工作区——git 历史藏旧版本）：
   ```
   mkdir -p tmp
   git clone https://github.com/{owner}/{repo}.git tmp/audit
   cd tmp/audit
   git log --all --oneline -S"敏感词"   # pickaxe：哪些 commit 碰过敏感词
   grep -rn "敏感词" .                   # 当前文件
   ```
3. 命中 → 写 escalation（"历史含敏感词，需清历史"），**专员不自己 force push**（对外不可逆，归对谈主管 / 开发层）。

### 链接检查（门面第 3 项）

- README **本仓库内链**（QUICKSTART.md / GROWING.md 等）→ 双语 README 常见坑：英文版改了链接、中文版没同步，两版都查。
- 文案指向仓库的链接 → 确认仓库 public（第 1 项过）即未登录全球可达。

### 落盘（铁律）

门面四项查完，**写报告到 `intel/YYYY-MM-DD-publish-gate.md`**（四项逐项 PASS/FAIL + 证据 + 命中的敏感词 commit）。不落盘 = 没做（6/13 教训：审查做了不落盘 = 没尽职）。报告是发布的放行凭证。

## 常见问题与处理

| 问题 | 处理 |
|---|---|
| strategy 无「仓库基线」 | 从外部口径推导，写到回执让主管确认，别自己定 |
| `gh repo edit` 权限不足 | 记 escalation（账号/权限问题），别反复试 |
| topics 已有但不含基线项 | 补，**不删**已有的 |
| README 存在但内容差 | 体检只管"存在性 + 结构"；内容优化是 README 重写的活 |
| OPS-CHANGELOG 已存在 | 检查格式是否正确，不覆盖内容 |
| description 改完没生效 | `gh api` 复核一次；仍不符记 escalation |
| 仓库有两个 README（中英） | 检查中文版链接是否断（双语 README 常见：英文版链接改了，中文版没同步） |
| 仓库 `private: true` 却要发推广 | 门面第 1 项不过。设公开（对谈主管确认，对外不可逆）或停发，**不带私仓链接发** |
| fresh clone grep 命中敏感词 | 历史含敏感版 → escalation 报「需清历史」，专员不自己 force push |
| 历史已 squash 但 release tag 指向旧 commit | 删旧 tag 重打到新 commit（`git push origin :refs/tags/vX` 删 + `git push origin vX` 建），否则 tag 留后门 |

## 验收清单（回执逐项勾）

- [ ] 元数据全查了（description / topics / license / Discussions / README / LICENSE / OPS-CHANGELOG）
- [ ] 轻量项 FAIL 已修到基线值，并复核
- [ ] 重量项 FAIL 已写 tasks + escalation
- [ ] 体检报告已写入 `intel/YYYY-MM-DD-repo-baseline.md`
- [ ] 回执逐项记了结果（PASS / 已修 / 已上报）

### 如本次是对外发布前置（门面检查，逐项勾）

- [ ] 仓库 `private: false`（第 1 项）
- [ ] fresh clone grep 敏感词零命中，**含 git 历史**（第 2 项）
- [ ] README 双语内链 + 文案链接都活（第 3 项）
- [ ] 门面报告落盘 `intel/YYYY-MM-DD-publish-gate.md`（放行凭证）
