# SKILL 注册表（治理台账）

> 所有 skill 在 `.claude/skills/<name>/SKILL.md`（Claude Code 标准位置）。无登记 = 未交付。
> maturity：草稿 → 打磨中 → ✅毕业 → deprecated。

## 系统级（框架自带，跨项目，出厂即有）

| skill | maturity | 作用 |
|---|---|---|
| ops-setup | ✅ | 初始化：访谈 → 搜索 → 方案确认 → 落盘 → 交接对谈主管 |
| skill-forge | ✅ | meta：造 / 优化 skill 并接入动线（唯一进化入口） |

## 领域 skill（出厂不预置，由对谈主管按项目需求现造）

> 对谈主管初始化后，对照 `prompts/director.md` 的「常见运营动作地图」规划，下场干一个、用 skill-forge 沉淀一个。
> 造出来的在这里登记：name / maturity / 一句话作用 / 动线位置。

| repo-baseline | 草稿 | 仓库基线体检：核对 description/topics/README/LICENSE/Discussions，缺啥补啥 |
| competitive-intel | 打磨中 | 竞品情报采集与深度分析：支持浅层（元数据+Issues）和深层（源码+项目结构），产物写入 intel/ |
| promo-plan | 打磨中 | 推广计划制定：产品事实校准 → 竞品调研 → 平台调研 → **多方向发散** → 每方向写样稿 → 评价优选 → 完整文案 → QA → 风险预案 → 排期，产物写入 content/ 和 intel/ |
| reddit-ops | 草稿 | Reddit 操作（opencli 内置命令）：浏览帖子、发评论、查用户状态。养号和社区互动用 |
| devlog-gif | 打磨中 | 录屏视频 → GIF → 上传 GitHub 并更新 README 当开发进度展示（devlog 素材）。已 2 次试跑（demo-v6/v7）。坑：引擎 UI 裁剪、大文件上传 ARG_MAX、本地远端不同步、README CRLF 换行 |
| content-review | 待造 | 文案评价：模拟目标平台用户 + 项目主人口味，对多个方向/稿件打分、比较、给修改建议 |
