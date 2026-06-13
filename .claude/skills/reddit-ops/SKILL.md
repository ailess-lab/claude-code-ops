---
name: reddit-ops
description: Reddit 评论、浏览帖子、查用户状态。养号（新号攒 karma）和社区互动时用。专员收到任务里提到 Reddit / r/ClaudeAI / r/SideProject / r/godot / 评论 / 养号 / karma 时触发。
---

# reddit-ops — Reddit 操作（opencli 内置命令）

> 所有 Reddit 操作都通过 opencli 内置命令完成，不需要 opencli browser 手动操作页面。
> **新号养号期间，严格遵守节奏限制（见下），否则会被封号。**

## 前提

- 浏览器已登录 Reddit（opencli reddit 命令需要 cookie 认证）
- 账号信息见项目 `strategy.md` 的「平台状态」表

## 账号初始化前置（新号发帖/评论前必做）

> 6/13 教训：新号（默认头像 / 0 历史 / karma 1）直接发帖会被 spam filter 拦截，发出去即折叠 = 白发。**账号初始化是发帖前的必要步骤，不是可选的。**

新号第一次操作前必须完成：

1. **改用户名**（默认随机名像机器人）→ 用项目显示名（见 strategy 平台状态）
2. **设头像**（默认头像 = 新号红旗）
3. **写 bio**（一两句，像真人）
4. **养号**（见下「养号节奏」铁律，karma ≥ 30 / 3-5 天活跃历史）
5. **验证发帖权限**（在目标 subreddit 试发一帖，确认不被 spam filter 拦，再正式发）

跳过 1-4 直接发 = 被 spam filter 拦 = 白发。改头像/bio 等资料设置用 opencli browser 或人工完成（opencli reddit 命令覆盖发评论/浏览，不覆盖改资料）。

## 命令速查

| 用途 | 命令 |
|---|---|
| 浏览 subreddit 帖子 | `opencli reddit subreddit <name> --sort new --limit 5 -f json` |
| 读取帖子+评论 | `opencli reddit read <post-id> -f json` |
| 发评论 | `opencli reddit comment <post-id> "<text>"` |
| 查用户评论历史 | `opencli reddit user-comments <username> --limit 10 -f json` |
| 搜索帖子 | `opencli reddit search "<query>" --limit 5 -f json` |
| 点赞 | `opencli reddit upvote <post-id> up` |

### post-id 怎么拿

从帖子 URL 提取。例如：
- URL: `https://www.reddit.com/r/ClaudeAI/comments/1u20dhk/a_fable_5_success_story/`
- post-id: `1u20dhk`

格式：`/comments/<post-id>/` 中间的那段。

### --sort 选项

`hot`（默认）, `new`, `top`, `rising`, `controversial`

## 养号节奏（铁律）

**新号（karma < 30）必须遵守：**

1. **一天最多 2 条评论**，间隔 ≥ 6 小时
2. **只回有话可说的帖子**，不硬凑数量
3. **不自我推广**——不提 ccops、不提自己的项目、不放链接
4. **不在同一 subreddit 连续发**——混着来（r/godot → r/ClaudeAI → r/SideProject）
5. **评论要自然**——有观点、帮到人、像真人写的

违反 = 触发 spam filter = 封号。急不来。

## 操作流程

### 发评论

1. 浏览目标 subreddit，找有话可说的新帖：
   ```bash
   opencli reddit subreddit ClaudeAI --sort new --limit 5 -f json
   ```
2. 从返回的 JSON 中找到目标帖子，提取 `url` 中的 post-id
3. 写评论内容（自然、有观点、不推广）
4. 发送：
   ```bash
   opencli reddit comment 1u20dhk "你的评论内容"
   ```
5. 确认返回 `status: success`
6. 如果返回 `RATELIMIT` → 等 10 秒重试一次，再失败就停
7. **记录到 `content/reddit-karma-log.md`**：在当天段落追加一行（时间、subreddit、帖子标题、评论内容摘要、score）

### 检查账号状态

```bash
opencli reddit user-comments <username> --limit 10 -f json
```

每条评论的 `score` 就是获得的 karma 数。

## 常见问题

| 问题 | 处理 |
|---|---|
| `RATELIMIT` | 等待 10 秒重试。连续触发 → 今天停止，明天再来 |
| `status: failed` + 权限错误 | 账号可能被封或 cookie 过期，写 escalation |
| 评论发出但 user-comments 里看不到 | 可能被 subreddit 的 automod 捕获了。换一个小 subreddit 试 |
| 浏览帖子返回空 | 可能是 VPN/网络问题，或者 subreddit 名拼错 |

## 验收清单

- [ ] 评论内容自然，不像 AI 生成
- [ ] 没有任何自我推广或链接
- [ ] 当天评论数 ≤ 2
- [ ] 返回 status: success
- [ ] 回执写了评论链接和 score
- [ ] 评论内容已记录到 content/reddit-karma-log.md
