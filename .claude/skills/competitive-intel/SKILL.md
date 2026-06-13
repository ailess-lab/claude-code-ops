---
name: competitive-intel
description: 竞品情报采集与深度分析。当需要建立某项目的竞品基线、跟踪竞品动态、从竞品仓库和社区提取用户痛点和需求时使用。支持浅层（元数据+Issues）和深层（源码+项目结构）两种模式。产物写入 projects/<标识>/intel/。
---

# competitive-intel — 竞品情报采集

> 从 GitHub 仓库 + 源码 + Issues + 社区提取竞品的用户痛点、技术架构、定位策略。**只看数据，不做无依据推测。**

## 前置：确认目标

1. 读项目 `strategy.md` 的「外部口径」和「核心卖点」——明确自己的定位。
2. 读 `internal.md`——明确自己的弱点和真实目标。
3. 确认要查的竞品列表。来源：
   - strategy 里提到的竞品
   - `gh search repos` 用项目关键词搜 top 5
   - 如需补充，搜 Reddit/HN 讨论里的同类项目

## 深度判断

**浅层**（默认）：元数据 + Issues + 外部提及。适用于一般竞品跟踪、定期更新。

**深层**：在浅层基础上 + 读竞品源码/项目结构。适用于以下情况（触发任一条即走深层）：
- 竞品是我们**直接 fork / 基于它改**的上游项目（我们改了什么、没改什么，必须搞清）
- 竞品是同赛道的**头部项目**（需要理解它的完整卖法来差异化）
- 需要**写对比文档**给社区看（事实必须坐实）
- 主管认为有必要深入了解时

---

## 步骤

### 1. 竞品仓库元数据

每个竞品跑一遍：

```
# 基础数据
gh api repos/{owner}/{repo} --jq '{stargazers_count, forks_count, open_issues_count, subscribers_count, created_at, pushed_at, description, topics, license: .license.spdx_id}'

# README 结构（只看头部 + 目录结构）
gh api repos/{owner}/{repo}/readme --jq '.content' | base64 -d | head -80
```

记录到情报：stars / forks / 最后更新 / license / 定位描述。

### 2. Issues 分析（用户痛点提取）

```
# 按评论数排（最热 = 最大痛点）
gh api "repos/{owner}/{repo}/issues?state=all&per_page=30&sort=comments&direction=desc" --jq '.[] | select(.pull_request == null) | {number, title, comments, state, labels: [.labels[].name]}'

# 最近 issue（看活跃度和维护状态）
gh api "repos/{owner}/{repo}/issues?state=all&per_page=20&sort=created&direction=desc" --jq '.[] | select(.pull_request == null) | {number, title, comments, state, created_at}'
```

**分类规则**：
- 评论数 ≥5 = 社区热点，重点分析
- 标题含"bug"/"error"/"fail" = 痛点
- 标题含"feature"/"request"/"support" = 未满足需求
- 标题含"token"/"cost"/"slow" = 性能/成本问题

### 3. 外部生态扫描

```
# 仓库外被提及
gh search issues "{竞品名}" --sort updated --limit 10 --json repository,title,commentsCount,url -- -repo:{owner}/{repo}
```

记录：被谁提及、在什么语境、正面还是负面。

### 4. 同类工具扫描

```
# 用竞品核心关键词搜同类
gh search repos "{关键词}" --sort stars --limit 5 --json fullName,description,stargazersCount,language
```

建立同类工具表：名字 / stars / 最后更新 / 定位差异。

### 5. 深层：竞品源码 / 项目结构分析

> **只在"深度判断"触发时做。** 目的：理解竞品的技术实现、用户动线、卖法细节。

#### 5a. 目录结构

```
# 看竞品的顶层目录结构
gh api repos/{owner}/{repo}/git/trees/{branch}?recursive=1 --jq '.tree[] | select(.type == "blob" or .type == "tree") | .path' | head -100
```

重点关注：
- `.claude/skills/` 或类似的 skill/command 目录 → 看它提供了哪些操作
- `prompts/` 或类似的 prompt 目录 → 看它的角色设计和指令结构
- `docs/` 或 `knowledge/` → 看它的用户教育和知识管理
- `config/` → 看它的配置结构
- 入口文件（`CLAUDE.md`、`run.sh` 等）→ 看它的动线设计

#### 5b. 核心文件读取

用 `gh api` 读取关键文件内容（base64 解码）：

```bash
# 示例：读竞品的 skill 列表
gh api "repos/{owner}/{repo}/contents/.claude/skills" --jq '.[].name'

# 示例：读某个具体 skill
gh api "repos/{owner}/{repo}/contents/.claude/skills/{skill-name}/SKILL.md" --jq '.content' | base64 -d

# 示例：读入口配置
gh api "repos/{owner}/{repo}/contents/CLAUDE.md" --jq '.content' | base64 -d | head -100
```

**必读文件**（如果存在）：
- `CLAUDE.md` 或主入口文档
- README 的完整版（不只是前 80 行）
- `.claude/skills/` 目录列表 + 每个 skill 的 SKILL.md
- `prompts/` 目录下的角色 prompt
- 对比文档（如果有 `COMPARISON.md` 或类似）

#### 5c. 差异对比

读完后，与我们项目做**具体到文件/功能**的对比：

| 维度 | 竞品 | 我们 | 差异性质 |
|---|---|---|---|
| Skill 数量 | X 个 | X 个 | 精简/扩展了哪些 |
| Skill 内容 | 具体描述 | 具体描述 | 哪些照搬、哪些改了、哪些新增 |
| 角色设计 | X 个角色 | X 个角色 | 结构差异 |
| 动线设计 | 具体步骤 | 具体步骤 | 流程差异 |
| 用户教育 | 有/无 | 有/无 | 文档覆盖差异 |

### 6. 写情报报告

输出到 `projects/{标识}/intel/YYYY-MM-DD-竞品名-情报.md`：

```markdown
# 竞品情报：{竞品名}

> 日期 / 采集范围 / 模式（浅层 or 深层）

## 数据快照
| 指标 | 竞品 | 我们 |
|---|---|---|
| Stars | X | X |
| ... | ... | ... |

## 用户痛点（从 Issues 提取，按热度排）
### 🔴 痛点 N：{标题}（X 条评论）
- issue #X：原文标题
- **推导**：从数据到结论的链路
- **对我们的意义**：怎么用于定位/内容

## 竞品定位分析
- README 结构和卖法
- 目标用户画像
- 与我们的差异点

## 技术架构（仅深层模式）
- 目录结构概览
- 核心文件分析
- 与我们的逐项对比表

## 社区生态
- 社区规模、活跃度
- 语言分布（中文/英文社区）
- 被谁提及（趋势日报/竞品issue）

## 同类工具
| 项目 | Stars | 状态 |
|---|---|---|
| ... | ... | ... |

## 对我们的建议
| 方向 | 对应痛点/发现 | 优先级 |
```

### 7. 关键结论提炼到 insights

如果情报里有**会改决策的发现**（如新竞品出现、社区痛点变化），提炼一句话写入 `projects/{标识}/knowledge/insights.md` 对应分节。**纯数据/事实不进 insights，只有"所以我们该怎么做"的判断才进。**

## 常见问题与处理

| 问题 | 处理 |
|---|---|
| 竞品仓库 Issues 被禁用 | 改搜外部提及（`gh search issues`）和 Reddit/HN 讨论 |
| Issue 数量太多（>200） | 只看评论数 top 30 + 最近 20，在报告里注明范围 |
| 同类工具搜索结果太多 | 只取 stars top 5，记"搜索了但截断在 top 5" |
| 推导不出明确结论 | 原始数据照记，结论栏写"数据不足以判断"，不硬编 |
| 发现竞品在踩我们 | 记事实（原链接 + 原文），不回应，上报主管决策 |
| 推广话术想踩竞品 | **不踩。** 只展示自己，不拿别人当垫脚石 |
| 数据和上次差不多 | 仍写报告，结论写"本轮无显著变化"，不跳过 |
| 深层模式下文件太多 | 只读必读文件列表 + 与我们差异最大的部分，不贪全 |
| 竞品没有 .claude/skills/ 目录 | 换路径找（可能是 `commands/`、`agents/`、`prompts/`），找不到就记"未发现结构化 skill 系统" |
| gh api 速率限制 | 用 `gh api` 带 `--paginate` 注意速率，必要时 sleep |

## 验收清单（回执逐项勾）

- [ ] 竞品元数据全查了（stars/forks/issues/更新时间/license/topics）
- [ ] Issues 按评论数和创建时间各取了一份
- [ ] 外部生态扫了一圈
- [ ] 同类工具 top 5 建了表
- [ ] 如为深层模式：源码/项目结构读了、差异对比表写了
- [ ] 情报报告写入了 `intel/YYYY-MM-DD-xxx.md`
- [ ] 痛点推导链写清楚了（数据 → 判断 → 对我们的意义）
- [ ] 如有决策级发现，提炼进了 `insights.md`
- [ ] 无挑衅/踩竞品的措辞
