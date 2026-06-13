# Quick Start Guide

Get claude-code-ops running in 5 minutes.

---

## Prerequisites

### Required

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed and authenticated (`claude` command works in your terminal)
- [GitHub CLI](https://cli.github.com/) installed and authenticated (`gh auth status` shows you're logged in)
- Bash (Linux, macOS, or WSL on Windows)

### Recommended

- **[opencli](https://github.com/nicepkg/opencli)** with `opencli-browser` skill — enables browser automation (posting to Reddit/HN, filling forms, interacting with dynamic pages). Without it, the system falls back to CLI tools and search APIs for platform operations, which covers GitHub fully but limits community interaction on web-only platforms.

## Step 1: Clone

```bash
git clone https://github.com/ailess-lab/claude-code-ops.git
cd claude-code-ops
```

## Step 2: Initialize Your Project

In Claude Code, run the setup skill:

```
/ops-setup
```

It walks you through:
1. **Self-check** — verifies the directory structure is complete
2. **Interview** — asks about your team and each project
3. **Strategy** — writes `strategy.md` and `team.md` based on your answers
4. **Register** — adds your project to `manifest.md`

When it's done, you have a project with strategy, team profile, and empty runtime directories ready to go.

### Manual Setup (Alternative)

If you prefer to set up manually:

```bash
# Create project structure
mkdir -p projects/my-project/{knowledge,state,content,metrics,intel}

# Write strategy
cat > projects/my-project/knowledge/strategy.md << 'EOF'
# My Project — Operations Strategy

> Status: ✅ Confirmed

## Public Positioning
One-line description for external audiences.

## Key Selling Points
1. Point 1
2. Point 2

## Tone
Practical, honest, plain language.

## Current Phase
Preparation

## Platform Status
| Platform | Status |
|----------|--------|
| GitHub | ✅ Active |

## Goals
| Timeline | Stars | Meaning |
|----------|-------|---------|
| 1 month | 100 | Niche validated |
EOF

# Create task list
cat > projects/my-project/state/tasks.md << 'EOF'
# Tasks

> Director assigns, specialist executes and writes receipts below each task.

## To Do
(Conversation Director will assign first batch)

## Completed
(empty)
EOF

# Create empty insights
cat > projects/my-project/knowledge/insights.md << 'EOF'
# Insights

> Only beliefs that change decisions. Max 30 entries. Director extracts from receipts.

(empty)
EOF

# Create empty metrics
echo '[]' > projects/my-project/metrics/tracker.json

# Register in manifest
# Edit manifest.md — add your project to the table:
# | my-project | 🟢 Active | P1 |
```

## Step 3: Start the Conversation Director

In Claude Code (same directory):

```
# Just start talking. The system detects you're the Conversation Director automatically.
# It will read your strategy and suggest first actions.
```

The Conversation Director will:
1. Read your project's strategy
2. Check what skills are available
3. **Propose first actions** based on the "common operations map" (repo baseline, competitive intel, etc.)
4. Execute them one by one, growing skills with `skill-forge` as it goes

## Step 4: Run Auto Ops (When Ready)

When skills are in place and strategy is confirmed:

```bash
bash run.sh
```

Each cycle:
1. **Auto Director** reviews specialist receipts → extracts insights → writes daily report → assigns next tasks
2. **Specialist** executes tasks per skill → writes receipts in `tasks.md`
3. **Next run** scheduled based on activity level (hourly if active, 4-8 hours if quiet)

All state is in files. Stop anytime with `Ctrl+C`. Restart picks up where you left off.

## What Goes Where

| What | Where | Who writes |
|------|-------|------------|
| Strategy & direction | `projects/<p>/knowledge/strategy.md` | Conversation Director (user approves) |
| Task list + receipts | `projects/<p>/state/tasks.md` | Director assigns, Specialist receipts |
| Learnings (changes decisions) | `projects/<p>/knowledge/insights.md` | Director (from specialist receipts) |
| Content drafts | `projects/<p>/content/<platform>/` | Specialist |
| Competitive intel | `projects/<p>/intel/` | Specialist |
| Data metrics | `projects/<p>/metrics/tracker.json` | Specialist |
| Daily report | `notifications/today.md` | Auto Director |

## Monitor

```bash
# Today's report (for you, plain language)
cat notifications/$(date +%F).md

# Current tasks and receipts
cat projects/my-project/state/tasks.md

# Data tracking
cat projects/my-project/metrics/tracker.json

# Execution logs
tail -20 logs/run.log
```

## Connect Your Project's Changelog

If your project repo has an `OPS-CHANGELOG.md` file, the operations system will automatically detect changes and respond (new feature → content material, breaking change → alert).

See [OPS-CHANGELOG.md](OPS-CHANGELOG.md) for the format.

## Stopping

Press `Ctrl+C` to stop `run.sh`. All state is saved to files. The system picks up where it left off on the next run.

---

## Tips

- **Start with the Conversation Director.** Don't jump straight to `run.sh`. Talk to it first — set strategy, build skills, verify outputs.
- **Skills grow organically.** The system ships with zero domain skills. Each one is built by the Conversation Director doing the work, then using `skill-forge` to capture it.
- **Publishing needs your approval.** Auto mode never publishes externally. When it's time to post, the Conversation Director confirms with you.
- **Check escalations.** The system writes things it can't decide to `projects/<p>/state/escalation.md`. Check it regularly.
- **Strategy is the source of truth.** Update `strategy.md` to change direction. All agents read it.
