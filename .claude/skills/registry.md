# SKILL 注册表（治理台账）

> 所有 skill 在 `.claude/skills/<name>/SKILL.md`（Claude Code 标准位置）。无登记 = 未交付。
> maturity：草稿 → 打磨中 → ✅毕业 → deprecated。
> **对外**：`公开` = 可进公开仓库；`内部` = 不对外（绑个人配置 / CC 原生已覆盖 / 临时）。**开发层 publish 按此列过滤**——`内部` 的不推。白名单跟 skill 同源维护，不漂移。

## 系统级（框架自带，跨项目，出厂即有）

| skill | maturity | 对外 | 作用 |
|---|---|---|---|
| ops-setup | ✅ | 公开 | 初始化：访谈 → 搜索 → 方案确认 → 落盘 → 交接对谈主管 |
| skill-forge | ✅ | 公开 | meta：造 / 优化 skill 并接入动线（唯一进化入口） |

## 领域 skill（出厂不预置，由对谈主管按项目需求现造）

> 对谈主管初始化后，对照 `prompts/director.md` 的「常见运营动作地图」规划，下场干一个、用 skill-forge 沉淀一个。
> 造出来的在这里登记：name / maturity / 对外 / 一句话作用 / 动线位置。

| skill | maturity | 对外 | 作用 |
|---|---|---|---|
| repo-baseline | 打磨中 | 公开 | 仓库基线体检：核对 description/topics/README/LICENSE/Discussions，缺啥补啥。**补对外发布门面检查**（可见性/脱敏/链接/文案一致，发布前置 0 步，6/13 事故后补） |
| competitive-intel | 打磨中 | 公开 | 竞品情报采集与深度分析：支持浅层（元数据+Issues）和深层（源码+项目结构）两种模式，产物写入 intel/ |
| promo-plan | 打磨中 | 公开 | 推广计划制定：产品事实校准 → 竞品调研 → 平台调研 → **多方向发散** → 每方向写样稿 → 评价优选 → 完整文案 → QA → 风险预案 → 排期，产物写入 content/ 和 intel/。**补步骤10发布后追踪与倒查**（0 数据强制倒查链接/平台/账号/文案，6/13 教训） |
| reddit-ops | 打磨中 | 公开 | Reddit 操作（opencli 内置命令）：浏览帖子、发评论、查用户状态。养号和社区互动用。**补账号初始化前置**（新号默认头像/0 历史直接发被 spam filter 拦，6/13 教训） |
| devlog-gif | 打磨中 | 公开 | 录屏视频 → GIF → 上传 GitHub 并更新 README 当开发进度展示（devlog 素材）。已 2 次试跑（demo-v6/v7）。坑：引擎 UI 裁剪、大文件上传 ARG_MAX、本地远端不同步、README CRLF 换行 |
| gpt-vision | 草稿 | **内部** | 精细识图（付费强模型）：本机视觉 MCP 不够精时调 gemini-3.1-pro / gpt-5.5。**不对外**——绑 jeniya 中转 + key（个人配置）、CC 原生多模态已覆盖、个人/临时 skill |
| time-aware | 草稿 | 公开 | 时间认知与任务排期：先 `date` 拿时刻 + 相对→绝对换算（凌晨"明早"=当天上午）+ 没给时间自行定通知不问 + 盘点先读 tasks.md |
| content-review | 待造 | 公开 | 文案评价：模拟目标平台用户 + 项目主人口味，对多个方向/稿件打分、比较、给修改建议 |
