# claude-code-ops

> AI operations system for Claude Code. Three agents collaborate to run your project's ops — strategy, content, community, data tracking, and intel — while you steer.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**English** | [中文](#中文说明)

---

## Why?

I need to do operations for my projects, but I'm not good at it. So I built a system where AI actually *does* the operations — not just suggests, but executes.

Most AI tools help you write content. This one runs the whole loop: strategy, content creation, community management, data tracking, and intel scanning. You set the direction, the agents execute.

## What It Actually Did

I used it to promote another open source project. Here's what happened:

**Set direction.** Chatted with the Conversation Director for 30 minutes — what the project is, which platforms to target. It asked a dozen questions, wrote up a strategy. I tweaked a few lines, confirmed.

**Did research.** It scanned 200+ top posts on the target subreddit, figured out which title formats work, what timing gets traction. Checked out the competition too — who's using similar tools, what the community thinks.

**Wrote content.** 12 drafts from different angles. Then three AIs simulated target platform users and scored each one — style match, credibility, viral potential. I got a ranked scorecard.

**Picked drafts.** I chose 3 from the 12, tweaked a few lines, ready to publish.

**My total contribution:** set the direction, pick the drafts. The rest was the system.

## What's Been Happening

> We use ccops to run ccops' own operations. Live updates. Full log - [LOG.md](LOG.md)

**6/11** - Helped define Steam strategy for FlyingSword (free demo, ongoing updates, targeting Next Fest). Specialist autonomously completed a 6-dimension deep dive on competitor AiToEarn (20k stars). Store page copy hit v3 — first two read like feature lists, studied Exo One and Race the Sun first, then got it right. Reddit account continuing to warm up.

**6/10** - Refactored task scheduling: specialist runs first, director reviews after. Published first Dev.to article (0 reactions). Started promo copy - 8 angles, 2 variants each.

**6/9** - Major README rewrite. Chinese section went from feature list to operational story. Added attractiveness review to skill-forge.

---

## How It Works

Three roles, one system:

```
┌─────────────────────────────────────────────────────┐
│                     You (human)                      │
│           Set direction · Approve publishes          │
└──────────┬──────────────────────────────┬───────────┘
           │ conversation                 │ run.sh (auto)
           ▼                              ▼
  ┌─────────────────┐          ┌──────────────────┐
  │  Conversation   │          │   Auto Director  │
  │  Director       │          │   (unattended)   │
  │                 │          │                  │
  │  • Strategy     │          │  • Review results│
  │  • Skill design │          │  • Assign tasks  │
  │  • Approve      │          │  • Extract learnings
  │    publishes    │          │  • Write reports │
  └─────────────────┘          └────────┬─────────┘
                                      │ assigns tasks
                                      ▼
                             ┌──────────────────┐
                             │   Specialist     │
                             │   (per project)  │
                             │                  │
                             │  • Execute tasks │
                             │  • Create content│
                             │  • Collect data  │
                             │  • Scan intel    │
                             └──────────────────┘
```

**Two parallel lines, not sequential phases**: conversation and auto run side by side. Published content never goes out without human confirmation.

### Conversation Director ↔ Auto Director

Same knowledge, two modes. Both read the same strategy and memory files. Judgments don't drift.

## File-Based Communication

Agents don't share context windows. They communicate through structured files. Simple, debuggable, inspectable.

```
projects/your-project/
├── knowledge/
│   ├── strategy.md     # Strategy (director writes, specialist reads)
│   └── insights.md     # Learnings (director extracts, specialist reads)
├── state/
│   └── tasks.md        # Tasks + receipts (single file)
├── content/            # Generated content (by platform)
├── metrics/            # Data tracking (tracker.json)
└── intel/              # Competitive intelligence
```

Every agent starts fresh each cycle — all state is in files, not conversation history.

## Skills

Ships with zero domain skills. The Conversation Director builds them as needed, using `skill-forge`. Each project grows its own skillset.

| Built-in Skill | Purpose |
|-------|---------|
| `ops-setup` | Initialize: interview → search → confirm strategy → hand off |
| `skill-forge` | Create and improve skills (the only way new skills grow) |

Use it once, it learns once. You figure out what works, it becomes a reusable skill.

## Quick Start

**Prerequisites:** [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI + [GitHub CLI](https://cli.github.com/) installed and authenticated. [opencli](https://github.com/nicepkg/opencli) with browser skill recommended for platform operations.

```bash
# 1. Clone
git clone https://github.com/ailess-lab/claude-code-ops.git
cd claude-code-ops

# 2. Initialize your project
# In Claude Code, run /ops-setup — it walks you through setup

# 3. Run auto ops
bash run.sh
```

See [QUICKSTART.md](QUICKSTART.md) for the full guide.

## Honest Bits

- Currently used by one person (me).
- Requires basic command line and Claude Code knowledge.
- Not plug-and-play — you spend 30 minutes setting strategy first, then it works.
- Publishing has a safety lock. Nothing goes out without your say-so.

## Philosophy

- **Show, don't tell.** Real results from real projects.
- **Honest perspective.** Built by someone who needs operations but isn't an operations expert.
- **Plain language.** No jargon, no buzzwords.
- **Useful > perfect.** Ship something that works, iterate from there.

## License

[MIT](LICENSE)

---

## 中文说明

我做项目还行，做运营是真的不行。

不是不想做——每次打开 Reddit 想发帖，脑子就空白。写推广文案比写代码难十倍。数据追踪、社区互动、竞品分析，知道该做，就是做不来。

所以造了这个。说功能没感觉，说个真事吧。

## 它实际干了什么

用它推了另一个开源项目。真实经过：

**定方向**。跟对谈主管聊了半小时，说清楚项目是什么、想在哪些平台发。它问了十几个问题，写了份运营策略。我改了几条，拍板。

**做调研**。它自己扫了目标社区前 200 个帖子，总结什么标题能火、什么格式受欢迎。竞品也查了一遍——谁在用同类工具、社区里什么态度。

**写文案**。12 篇，不同角度。写完不自己说好——三个 AI 分别模拟目标平台用户，每篇按风格、可信度、传播力打分。我拿到的是一份评分表。

**选稿**。我从 12 篇里挑了 3 篇，改了几句，准备发三个平台。

整个过程我做了什么？定方向、选稿子。其余它干的。

## 最近在干嘛

> 我们用自己的系统运营自己的项目。这里记录实际发生了什么。
> 完整日志 - [LOG.md](LOG.md)

**6/11** - 协助此剑定了 Steam 策略：免费 Demo、持续更新、目标参加 Next Fest。专员自主跑完了竞品 AiToEarn（2 万星）的六维度调研。商店页文案写到第三版——前两版太像功能列表被毙了，研究竞品商店页才改对。Reddit 账号持续养号。

**6/10** - 重构调度方式：专员先跑，跑完主管复盘。Dev.to 发了第一篇文章（目前 0 反应）。开始写推广文案，8 个方向各写两版。

**6/9** - README 大改：中文部分从功能列表重写成运营过程展示。skill-forge 加了对外输出的吸引力审查。

---

## 怎么做到的

三个 AI 角色各管一摊：

```
┌─────────────────────────────────────────────────┐
│                   你（人）                        │
│         定方向 · 发布前确认                        │
└──────┬────────────────────────────┬─────────────┘
       │ 对谈                       │ run.sh（自动）
       ▼                            ▼
┌─────────────┐          ┌──────────────────┐
│  对谈主管    │          │   自动主管        │
│             │          │   （无人值守）     │
│ • 定策略    │          │ • 复盘结果        │
│ • 沉淀skill │          │ • 派任务          │
│ • 确认发布  │          │ • 提炼经验        │
└─────────────┘          └───────┬──────────┘
                                │ 派任务
                                ▼
                       ┌──────────────────┐
                       │     专员          │
                       │   （按项目）       │
                       │                  │
                       │ • 执行任务        │
                       │ • 产出内容        │
                       │ • 采集数据        │
                       └──────────────────┘
```

**两条线并行，不是先后阶段**：对谈和自动同时跑。对外发布永远要你确认，不会偷偷发。

所有状态在文件里，不在对话里。关掉终端下次打开，从文件恢复，不丢任何东西。`bash run.sh` 一行启动。

出厂不带任何领域 skill。用一次，学一次。你跑通了什么，它就会什么。

## 上手

**前置**：[Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI + [GitHub CLI](https://cli.github.com/) 安装并登录。[opencli](https://github.com/nicepkg/opencli) 搭配浏览器 skill 推荐，用于平台操作。

```bash
# 1. 克隆
git clone https://github.com/ailess-lab/claude-code-ops.git
cd claude-code-ops

# 2. 初始化你的项目
# 在 Claude Code 里跑 /ops-setup — 它会引导你完成设置

# 3. 跑自动运营
bash run.sh
```

完整指南见 [QUICKSTART.md](QUICKSTART.md)。

## 诚实的部分

- 目前就我在用，没有"数千用户"。
- 需要懂一点命令行和 Claude Code。
- 不是开箱即用——先花半小时定策略，然后它才开始干活。
- 对外发布有安全锁，不会偷偷发东西出去。

## 信条

- **展示，不吹。** 真实项目的真实过程。
- **诚实视角。** 造它的人需要运营但不擅长运营。
- **说人话。** 不堆术语和空话。
- **有用比完美重要。** 先跑起来，再迭代。

## 许可证

[MIT](LICENSE)
