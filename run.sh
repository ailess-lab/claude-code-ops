#!/bin/bash
# Claude Code Ops — 主循环
# 轮询 tasks.md，发现到时间的任务就跑主管+专员。调度靠任务里的时间，不靠额外文件。
set -uo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
PROMPTS_DIR="$BASE_DIR/prompts"
LOGS_DIR="$BASE_DIR/logs"
NOTIF_DIR="$BASE_DIR/notifications"
MANIFEST="$BASE_DIR/manifest.md"
mkdir -p "$LOGS_DIR" "$NOTIF_DIR"

log() { local m="[$(date '+%F %T')] $*"; echo "$m"; echo "$m" >> "$LOGS_DIR/run.log"; }
timestamp() { date '+%Y-%m-%d-%H%M'; }

# 活跃项目（manifest 表格中状态为 🟢 的项目）
get_active_projects() {
  python -c "
import re,sys
sys.stdout.reconfigure(newline='\n')
with open(sys.argv[1],'r',encoding='utf-8') as f:
    for line in f:
        m = re.match(r'\|\s*(\S+)\s*\|\s*(🟢|🟡)', line)
        if m and m.group(2) == '🟢':
            print(m.group(1))
" "$MANIFEST" 2>/dev/null || true
}

# 可用「动作 skill」名字清单（白名单提醒——skill 的描述 Claude Code 已自动可见，这里只列名字；本轮用哪个由任务注明）
# 排除 ops-setup（交互初始化）和 skill-forge（造 skill 是对谈主管的事）
list_skills() {
  for f in "$BASE_DIR"/.claude/skills/*/SKILL.md; do
    [ -f "$f" ] || continue
    local n
    n=$(grep -m1 '^name:' "$f" | sed 's/^name:[[:space:]]*//')
    case "$n" in ops-setup|skill-forge) continue ;; esac
    printf '%s ' "$n"
  done
}

# 治理债提示（注入给自动主管）
governance_debt() {
  local drafts
  drafts=$(grep -c '草稿' "$BASE_DIR/.claude/skills/registry.md" 2>/dev/null || echo 0)
  echo "registry 未毕业草稿条目：${drafts}（内置占位不算）。超阈值时先治理（去重/毕业/精简）再派新产出。"
}

# 检查某项目是否有到时间的待办任务
has_due_tasks() {
  local pdir="$1"
  local tf="$pdir/state/tasks.md"
  [ -f "$tf" ] || return 1
  local now_ts=$(date '+%s')
  while IFS= read -r task_time; do
    [ -z "$task_time" ] && continue
    local task_ts=$(date -d "$task_time" '+%s' 2>/dev/null || echo 0)
    if [ "$task_ts" -gt 0 ] && [ "$now_ts" -ge "$task_ts" ]; then
      return 0
    fi
  done < <(grep -oP '\- \[ \] \K\d{4}-\d{2}-\d{2} \d{2}:\d{2}' "$tf" 2>/dev/null | sort -u)
  return 1
}

# 专员：注入四件套（你是谁 / 可用 SKILL / 任务 / 记忆摘要）
run_specialist() {
  local project="$1"
  local pdir="$BASE_DIR/projects/$project"
  [ -d "$pdir" ] || { log "❌ 项目目录不存在：$project"; return 1; }
  local tag="$(timestamp)-specialist-${project}"
  log "专员启动：${project} → logs/${tag}"

  local tasks memory skills strat prompt result
  strat=$(head -40 "$pdir/knowledge/strategy.md" 2>/dev/null || echo "（无策略）")
  tasks=$(cat "$pdir/state/tasks.md" 2>/dev/null || echo "（暂无任务，按 strategy 自行判断本轮该做什么）")
  memory=$(head -40 "$pdir/knowledge/insights.md" 2>/dev/null || echo "（暂无记忆）")
  skills=$(list_skills)
  [ -z "$skills" ] && skills="（暂无领域 skill——对谈主管造出来后才有）"

  prompt="$(cat "$PROMPTS_DIR/specialist.md")

---
## 你是谁
你是运营专员。本轮处理项目：${project}。
## 项目策略（写公开内容时，只用这里的外部口径）
${strat}
## 可用动作 skill 名字（描述 Claude Code 已自动可见；本轮用哪个见下面任务清单）
${skills}
## 任务清单
${tasks}
## 你的记忆摘要
${memory}"

  # 落盘：提示词
  echo "$prompt" > "$LOGS_DIR/${tag}-prompt.md"

  # 执行：prompt 从已落盘文件走 stdin，不当命令行参数（超长 prompt 会触发 ARG_MAX）
  result=$(claude -p --output-format text --max-turns 50 < "$LOGS_DIR/${tag}-prompt.md" 2>&1)

  # 落盘：结果
  echo "$result" > "$LOGS_DIR/${tag}-result.md"

  log "专员完成：${project}"
}

# 自动主管：注入 策略/记忆/各项目结果/治理债
run_director_auto() {
  local tag="$(timestamp)-director"
  log "自动主管启动 → logs/${tag}"

  local skills debt states="" prompt result
  skills=$(list_skills)
  [ -z "$skills" ] && skills="（暂无领域 skill——对谈主管造出来后才有）"
  debt=$(governance_debt)
  local p
  for p in $(get_active_projects); do
    states+="### ${p}
策略（方向/阶段/目标）：
$(head -40 "$BASE_DIR/projects/$p/knowledge/strategy.md" 2>/dev/null || echo '（无策略）')
任务清单 + 专员回执（上一轮派了啥、做得怎样都在这）：
$(cat "$BASE_DIR/projects/$p/state/tasks.md" 2>/dev/null || echo '（无任务）')
记忆当前重点：
$(head -25 "$BASE_DIR/projects/$p/knowledge/insights.md" 2>/dev/null || echo '（无记忆）')
"
  done

  prompt="$(cat "$PROMPTS_DIR/director.md")

---
## 你的模式
自动模式（无人值守，专员执行后复盘）：复盘各项目 tasks 里专员的回执 + 记忆 → 写日报到 notifications/今天.md → 把回执里会改决策的发现提炼进 insights → 判断并派下一轮 tasks（含治理）。第一轮没有回执，就基于 strategy 派第一批。
## 可派的动作 skill 名字（描述自动可见；派任务时在每条任务里写明用哪个）
${skills}
## 各项目：策略 + 任务清单与回执 + 记忆当前重点（这是你判断的全部依据，不丢）
${states}
## 治理债
${debt}"

  # 落盘：提示词
  echo "$prompt" > "$LOGS_DIR/${tag}-prompt.md"

  # 执行：prompt 从已落盘文件走 stdin，不当命令行参数（超长 prompt 会触发 ARG_MAX）
  result=$(claude -p --output-format text --max-turns 50 < "$LOGS_DIR/${tag}-prompt.md" 2>&1)

  # 落盘：结果
  echo "$result" > "$LOGS_DIR/${tag}-result.md"

  log "自动主管完成"
}

# ---- 主循环 ----
log "=== Claude Code Ops 启动 ==="
while true; do
  active=$(get_active_projects)

  if [ -z "$active" ]; then
    log "⚠️ 无活跃项目。请在 Claude Code 里唤起对谈主管初始化。空转等待。"
    sleep 300; continue
  fi

  # 检查各项目是否有到时间的待办任务
  has_due=false
  for p in $active; do
    if has_due_tasks "$BASE_DIR/projects/$p"; then
      has_due=true
      break
    fi
  done

  if [ "$has_due" = true ]; then
    # 只跑有到期任务的项目的专员 → 主管复盘
    for p in $active; do
      if has_due_tasks "$BASE_DIR/projects/$p"; then
        run_specialist "$p"
      fi
    done
    run_director_auto
  else
    log "轮询：${active// /, } — 暂无到期任务"
  fi

  sleep 60
done
