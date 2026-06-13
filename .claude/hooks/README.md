# Hooks — 状态落盘的机械触发（已配置，待实测）

治"对谈主管长聊不落盘、上下文太长忘了 CLAUDE.md"——配了两个 hook，机制硬触发，不靠 AI 自觉：

| hook | 触发 | 注入 | 脚本 |
|---|---|---|---|
| `SessionStart` | 新会话 / resume / **压缩后** | 提醒读 strategy+tasks+insights 恢复状态 | `restore.sh` |
| `UserPromptSubmit` | 每轮用户输入 | 提醒落盘 | `checkpoint.sh` |

**最关键的是 SessionStart 的 compact 触发**：autocompact 压缩后会重新触发它、并能注入（文档坐实）——自动喂"读文件恢复状态"。**压缩反而成了刷新记忆的点，不靠 GLM 自觉。**

## 待实测（实跑第一件事验证）

win 下 / `claude -p` 下 CC 触发 hook 用什么 shell、cwd、中文编码——**没实测**。实跑时确认：对谈主管**开场和每轮有没有收到那两句注入**。

- 收到了 → 成立。
- 没收到 → 大概率 command 的 shell/路径/编码问题，拿回来调（可能 command 要写成绝对路径，或 win 下换 `sh` / 直接 echo）。

> 之前说"不放假装生效的钩子"——现在不是假装，是配好待验证；验证不过就调，不留着骗自己。
