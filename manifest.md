# 顶层路由（manifest）

> AI 启动先读本文件。只做路由，不塞详情。

## 活跃项目

| 项目标识 | 状态 | 优先级 |
|---|---|---|
| my-project | 🟢 | P1 |

> 状态：🟢 活跃（run.sh 会跑）/ 🟡 暂缓（不跑）。
> 阶段（准备/宣发/验证）的唯一源在各项目 `strategy.md`，状态栏不塞阶段词。
> 用 ops-setup 初始化新项目后，项目会自动加进这张表。

## 全局资源

| 类别 | 位置 |
|---|---|
| 用户指令 | `config/directives.md`（随 CLAUDE.md @import 自动加载） |
| 团队档案 | `config/team.md`（随 CLAUDE.md @import 自动加载） |
| SKILL 库 + 台账 | `.claude/skills/` , `.claude/skills/registry.md` |
| 元提示 | `prompts/specialist.md` , `prompts/director.md` |
