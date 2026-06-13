# Growing ccops

> QUICKSTART gets you installed. This guide is about taking it from "runs" to "works well."

**English** | [中文](#中文)

---

ccops ships knowing only two things — how to initialize, and how to forge skills. Everything else grows from "use it once, learn it once." This is the manual for that.

## How ccops Gets Better

Two mechanisms. Understand them and you know how to use it:

- **Skills grow themselves.** You and the Conversation Director run an action end to end, then capture it as a skill with `skill-forge`. Next time the Specialist follows the skill instead of figuring it out from scratch. It ships with zero domain skills — all of them grow this way.
- **Insights accumulate themselves.** Each cycle, the Director distills "findings that change a decision" out of the Specialist's receipts into `insights.md`. Next cycle has an anchor; the same trap isn't stepped in twice.

So ccops won't understand your thing on day one. **What it can do equals the experience you've run it through.** That's the thesis of this whole guide.

## Your Role (Don't Invert It)

- **You**: set direction, pick outputs, give feedback. You don't write files or run commands — it does. But "what to do, is it on track" is your judgment.
- **Conversation Director**: your partner. Does the work, captures actions as skills, extracts learnings from results.
- **Auto Director + Specialist**: script-driven, follow mature skills for deterministic tasks, write receipts back for you and the Director to read.

The biggest trap: **don't jump straight to `run.sh` after installing.** Talk to the Conversation Director first — set strategy, run the first actions through and capture them as skills, then let the auto line run. Skip this and you've handed an inexperienced Specialist a pile of tasks.

## How to Grow the Right Skills

1. **Run an action first.** Don't think "I need an X skill" and fabricate one — first do one thing end to end with the Director: post a comment, write a draft, research a competitor.
2. **Capture it while it's warm.** Run `skill-forge` right after: commands, steps, pitfalls, written as a manual. Next time the Specialist follows it.
3. **A skill must be runnable as-is.** A good skill is a manual the Specialist can follow step by step — concrete commands, fields, what to do on each error. Not "you should watch out for X." Run it once after forging; if it's off, fix it.
4. **Don't forge junk skills.** One-off or duplicative actions don't deserve a skill — just do them, or reuse an existing one. Skills are for what you'll do repeatedly.

Signals it's time to forge a skill: you've done the same action a second time, the Specialist's receipt says "no matching skill," or you keep hand-repeating a flow.

## How to Get Useful Insights Out of the Director

Insights are ccops's memory. Empty insights = every cycle judges from zero. Help it remember the right things:

- **Record findings that change decisions, not logs.** "A new account posting too fast got rate-limited" is an insight — it changes the "warm-up pace" decision. "Posted 3 comments today" is a log — that stays in the receipt.
- **Zero data must be investigated, and the cause goes into insights.** After a publish with zero engagement, don't just record "0" — check whether the link works, the platform's right, the account's ready, and record the cause. **Logging a number isn't doing your job.**
- **Give feedback.** Scan the insights the Director extracts; have it fix the wrong ones. You're its only external calibration — it can't detect its own bad judgment.

## How Not to Flail During Cold Start

Don't pick the first actions by gut. After `ops-setup`, the Conversation Director proposes against a "common operations map" — **let it propose first, then you decide.** Typical prep actions: repo baseline check, competitive intel, target platform culture study, platform account setup.

One action at a time: run it → capture it → next one. Don't fan out. Once the first few skills exist, the rest speeds up.

## How to Tell If ccops Is Getting Better

**Getting better**: Specialist receipts get smoother (fewer escalations), the skill library grows, insights accumulate and you agree with them, outputs match your taste.

**Drifting**: escalations pile up (the Specialist keeps saying no skill / can't do it), the same trap gets hit twice (an insight wasn't recorded or wasn't injected), outputs keep missing the mark (a skill wasn't captured right).

When it drifts, go back to conversation mode: run it yourself, fix the skill, calibrate insights. The auto line won't self-correct — correction happens when you're present.

## A Few Hard Truths

- **Strategy is the single source of truth.** Change direction by editing `strategy.md` — all roles follow. Don't change direction in conversation without writing it down.
- **Publishing always needs your confirmation.** The auto line won't sneak things out.
- **State lives in files, not conversation.** Close the terminal, recover fully from files = you did it right.
- **It's a tool, not an expert.** ccops's operational judgment equals what you've trained into it. Don't calibrate, and it stays at factory level.

---

## 中文

> QUICKSTART 教你装好、跑起来。这份教你怎么让它从"能跑"变成"好用"。
> ccops 出厂只会两件事（初始化 + 造 skill），其余全靠"用一次、学一次"长出来。这份是养成手册。

## ccops 靠什么变好

两个机制，理解了就知道该怎么用：

- **skill 自己长**。你和对谈主管跑通一个动作，用 `skill-forge` 把它固化成 skill。下次专员照着 skill 做，不用重新摸索。出厂零领域 skill，全这么长出来。
- **insights 自己沉淀**。主管每轮从专员回执里，把"会改决策的发现"提炼进 `insights.md`。下次判断就有了锚点，不重复踩坑。

所以 ccops 不会一上来就懂你的事——**它的本事，等于你带它跑出来的经验。** 这句话是整份指南的纲。

## 你的角色（别搞反）

- **你**：定方向、挑产出、给反馈。你不用写文件、跑命令，这些它干。但"做什么、对不对路"是你的判断。
- **对谈主管**：你的搭档。下场干活、把动作沉淀成 skill、从结果提炼经验。
- **自动主管 + 专员**：脚本驱动，照成熟的 skill 干确定性任务，回执写回来给你和主管看。

最大的坑：**别装好就直奔 `run.sh`**。先和对谈主管聊，把 strategy 定了、第一批动作跑通沉淀成 skill，再让自动线跑。跳过这步 = 让没经验的专员瞎干。

## 怎么让它长出对路的 skill

1. **跑通一个动作再说**。别想"我需要 XX skill"然后凭空造——先和对谈主管把一件事从头做一遍：发一条评论、写一篇文案、查一个竞品。
2. **跑通了立刻沉淀**。趁热用 `skill-forge` 固化：命令、步骤、踩过的坑写成手册。下次专员照着做。
3. **造的 skill 要能照做**。好的 skill 是"专员拿着就能执行"的手册（具体命令、字段、出错怎么改道），不是"你应该注意 XX"的空话。造完试跑一次，不对就改。
4. **别造废 skill**。只做一次、或本质重复的动作，别造——直接做或用现有的。skill 是"会反复用"的才值得固化。

判断"该造 skill 了"的信号：同一个动作做了第二次、专员回执说"没匹配的 skill"、或一个流程你反复手工重复。

## 怎么让主管提炼出有用的 insight

insights 是 ccops 的记忆。空 insights = 每轮都从零判断。帮它记对的东西：

- **记"会改决策的发现"，不记流水**。比如"新号发太快被平台限流"是 insight——它改了"养号节奏"这个决策；"今天发了 3 条评论"是流水，记回执就够。
- **0 数据要倒查，倒查的结论记进 insight**。发布后零互动，别只记一个"0"——查链接活不活、平台对不对、账号够不够，把原因记下来。**记一个数 ≠ 尽职。**
- **给它反馈**。主管提炼的 insight 你扫一眼，不对的让它改。你是它唯一的"外部校准"——它自己发现不了自己判断错了。

## 冷启动怎么不瞎摸

第一批动作别凭感觉。`ops-setup` 之后，对谈主管会对照"常见运营动作地图"提建议——**让它先提，你再拍板**。典型准备期动作：仓库门面体检、竞品调研、目标平台文化研究、平台账号初始化。

一个动作"跑通 → 沉淀 → 再下一个"，别一次铺开。前几个 skill 长出来，后面就快了。

## 怎么看 ccops 在不在变好

**变好的信号**：专员回执越来越顺（escalation 少）、skill 库在长、insights 在累积且你认可、产出对得上你的品味。
**跑偏的信号**：escalation 堆积（专员老说没 skill / 不会）、同一个坑踩第二次（insights 没记或没被注入）、产出总不对味（skill 没沉淀对）。

看到跑偏，回到对谈模式：下场跑一遍、改 skill、校准 insights。自动线不会自己纠偏——纠偏是你在场时的事。

## 几个硬道理

- **strategy 是唯一源**。改方向就改 `strategy.md`，所有角色跟着变。别在对话里改了方向不落盘。
- **发布永远要你确认**。自动线不会偷偷把东西发出去。
- **状态在文件里，不在对话里**。关掉终端，能从文件完整恢复 = 合格。
- **它是工具不是专家**。ccops 的运营判断力，等于你带出来的。你不上心校准，它就停在出厂水平。
