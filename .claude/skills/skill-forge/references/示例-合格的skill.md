# 标杆示例：一个合格的 skill 长什么样

> 造新 skill 时**照这个的结构和粒度写**，别自由发挥。它麻雀虽小五脏俱全：精确到命令 + 改道表 + 验收清单 + 只干一件事。
> 末尾有"合格 vs 放飞"对照——写完拿它自检。

---

## 范例（下面整段就是一个完整 skill 的样子）

````
---
name: gh-add-topics
description: 给 GitHub 仓库补 topics。当仓库 topics 缺失或少于 strategy 基线、需要按基线补齐时使用。
---

# gh-add-topics — 给仓库补 topics

## 步骤

### 1. 拉当前 topics
```
gh repo view {owner}/{repo} --json repositoryTopics --jq '.repositoryTopics[].name'
```

### 2. 算出缺哪些
基线 topics 在 strategy「仓库基线」。缺的 = 基线 − 当前。

### 3. 补齐（一次加一个）
```
gh repo edit {owner}/{repo} --add-topic {缺的topic}
```

### 4. 复核
重跑第 1 步，确认补上了。

## 常见问题与处理
| 问题 | 处理 |
|---|---|
| topic 含大写/空格 | GitHub topic 只允许小写连字符，转换后再加 |
| 权限不足 | 记 escalation，别反复试 |
| 已有 topic 不在基线里 | 留着不删（基线是下限，不是上限）|

## 验收清单
- [ ] 基线里的 topics 都在了
- [ ] 没删用户已有的 topic
- [ ] 复核过
````

---

## 合格 vs 放飞（写完拿这个自检）

| 合格（上面那样） | 放飞（要避免） |
|---|---|
| `gh repo edit --add-topic x`——精确命令 | "给仓库加上合适的 topics"——虚，专员得自己猜怎么加 |
| 改道表写了"权限不足 → escalation" | 没改道表，一报错就卡死或瞎试 |
| 验收清单能逐项勾 | "确保 topics 没问题"——没法勾，等于没验收 |
| 一个 skill 只干一件事（补 topics） | 又体检又改 README 又发帖——该拆成多个 |
| 步骤里写死命令/字段 | 通篇"你应该注意 X"——方法论，不是手册 |

**自检一句话**：把这个 skill 交给一个没上下文的专员，他能不能照着一步步做完、出错了知道怎么改道、做完知道算不算合格？能 = 合格；要靠他自己发挥 = 放飞，回去改。
