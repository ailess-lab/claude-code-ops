---
name: devlog-gif
description: 把游戏/项目的录屏视频做成 GIF，上传到 GitHub 仓库并更新 README 作为开发进度展示（devlog 素材）。当用户说「做 GIF」「视频转 GIF」「发进度 GIF 到 GitHub」「更新仓库 GIF」「把录屏剪成动图传上去」「截一段做成动图」时使用。处理开发录屏带引擎 UI、大文件上传、本地远端不同步等坑。
---

# devlog-gif — 录屏视频 → GIF → GitHub 进度更新

> 把一段开发录屏做成干净的 GIF，传到 GitHub 仓库、更新 README 当进度展示。
> **只干这一件事**。写文案/选平台不在这。

## 前置：先和用户确认 4 件事

1. **源视频**：文件路径（录屏常是时间戳命名，看不出拍的是啥，第 1 步要验内容）。
2. **目标仓库**：`owner/repo`。
3. **GIF 去向**：新文件名（如 `demo-v6.gif`）放仓库根目录？还是替换旧 GIF？
4. **README 怎么插**：加在哪个位置？是否保留旧 GIF（默认**保留**，叠加新进度）。

> 没说清就问，别猜。

## 路径约定（贯穿全程，违反必踩坑）

- 本环境是 Windows + git bash，但会调 Windows 版 python。
- **所有临时文件路径统一用 `C:/...` 绝对正斜杠格式**——bash 和 python 都认。
- ❌ 别用 `/tmp/...`：git bash 的 `/tmp` Windows python 看不见，会 `FileNotFoundError`。

## 步骤

### 1. 定位并确认源视频内容

录屏文件名常是时间戳，看不出拍的是哪个项目。**先用内容验，别凭文件名猜。**

**1a. 按时长筛候选**（找目标长度，如 ~30 秒）：
```
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "C:/path/视频.mp4"
```
对目录下所有视频批量看时长，挑出时长接近用户说的那段。

**1b. 抽帧**（抽开头/中间/结尾各一帧，交叉确认）：
```
ffmpeg -y -ss 3 -i "C:/path/视频.mp4" -frames:v 1 "C:/path/frame_start.png"
ffmpeg -y -ss 15 -i "C:/path/视频.mp4" -frames:v 1 "C:/path/frame_mid.png"
```

**1c. 视觉模型确认内容**：用 `analyze_image` 类工具看帧图，确认拍的是**目标游戏/项目**的画面（不是录错了、不是别的项目）。

- **校验点**：视觉模型描述的画面 = 目标项目。✅ 对路才继续；❌ 错了 → 换视频，回 1a。

### 2. 裁掉引擎/编辑器 UI

开发录屏几乎都带 Godot/引擎的 dock、播放控制栏。**裁干净，否则公开看着像半成品调试录屏。**

**2a. 抽一帧带完整 UI 的图**（同 1b 命令，挑 UI 最全的一帧）。

**2b. 让视觉模型量 crop 坐标**：给视觉模型看帧图，问「纯游戏画面区域的矩形，给我 ffmpeg crop 的 `out_w:out_h:x:y`（宽:高:左上角x:左上角y）」。模型会给出如 `1720:900:130:80`。

**2c. ffmpeg 裁剪**：
```
ffmpeg -y -i "C:/path/视频.mp4" -vf "crop=1720:900:130:80" -c:a copy "C:/path/cropped.mp4"
```

**2d. 复核裁干净了没**：从 cropped 抽一帧（尤其看底部和左右边缘），让视觉模型再看一遍有没有残留的 dock/控制栏。
- **校验点**：无 UI 残留。❌ 底部还有控制栏 → 加大 crop 高度（如 `900`→`860`）或 y 偏移，重做 2c–2d。

### 3. 选精华片段 + 生成 GIF

**3a. 决定截哪段**：选最有动感、最能体现卖点的 10–15 秒（README 友好，太长 GIF 巨大）。记下 `<start>` `<duration>`。

**3b. palette 两遍法**（控制大小兼顾清晰）：
```
# 第一遍：生成调色板
ffmpeg -y -ss <start> -t <duration> -i "C:/path/cropped.mp4" ^
  -vf "fps=12,scale=600:-1:flags=lanczos,palettegen=stats_mode=diff" "C:/path/palette.png"

# 第二遍：用调色板生成 GIF
ffmpeg -y -ss <start> -t <duration> -i "C:/path/cropped.mp4" -i "C:/path/palette.png" ^
  -filter_complex "fps=12,scale=600:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=5" "C:/path/out.gif"
```
> git bash 里把 `^` 换行去掉写成一行，或用 `\`。

**3c. 看大小**：
```
ls -l "C:/path/out.gif"   # 看 KB
```
- **校验点**：README 友好区间约 < 8MB。❌ 太大 → 降 `fps`(12→10)、缩更小(`600`→`480`)、截更短；❌ 太糊 → `scale` 调大(`720`)、`fps` 提到 15（权衡大小）。

### 4. 上传 GIF 到 GitHub（关键坑：别用 `-f content`）

**GIF 转 base64 后常超 shell ARG_MAX（~6MB 就会报 `Argument list too long`）。❌ 不能用 `gh api -f content="$B64"`。必须写 payload 文件 + `--input`。**

**4a. 查目标路径有没有同名旧文件**（有就要带 sha 才能覆盖）：
```
gh api repos/{owner}/{repo}/contents/{gif路径} --jq '.sha' 2>/dev/null
```
有输出 → 记下 `OLD_SHA`；无输出（404）→ 新建，不用 sha。

**4b. base64 编码**：
```
B64=$(base64 -w 0 < "C:/path/out.gif")
```

**4c. 写 payload 文件**（heredoc 嵌 `${B64}`；更新已有文件就加 `"sha"` 行）：
```
cat > "C:/path/gif_payload.json" <<EOF
{"message":"add devlog gif","content":"${B64}","branch":"main"}
EOF
```

**4d. 上传**：
```
gh api --method PUT repos/{owner}/{repo}/contents/{gif路径} --input "C:/path/gif_payload.json"
```
- **校验点**：返回 `201`（新建）或 `200`（更新），有 `commit.sha`。❌ 失败看改道表。

### 5. 更新 README（关键坑：直传远端，绝不碰本地）

**本地仓库常和远端不同步（本地是旧 README，还堆着无关的未提交改动）。❌ 改本地再 push 会用旧版覆盖远端新版。全程走 GitHub contents API 直传远端。**

**5a. 拉远端 README + sha**：
```
gh api repos/{owner}/{repo}/contents/README.md > "C:/path/readme_meta.json"
```

**5b. python：解码 → 插入新 GIF 块（保留旧 GIF）→ 再编码 → 输出 payload**：
```python
import json, base64, sys
meta = json.load(open(sys.argv[1], encoding="utf-8"))
content = base64.b64decode(meta["content"]).decode("utf-8")
sha = meta["sha"]

# 用「独特锚点字符串」定位插入点——别用 </p>\n--- 这种短串（会撞多处）
anchor = '<em>这里贴一段 README 里唯一存在的长句子作为锚点</em>\n</p>\n\n---'
new_block = anchor + '\n\n<p align="center">\n  <img src="demo-v6.gif" width="100%">\n  <em>Latest progress — 一句诚实的进度说明（work in progress）</em>\n</p>'
assert content.count(anchor) == 1, f"锚点命中 {content.count(anchor)} 处，要唯一"
content = content.replace(anchor, new_block)

new_b64 = base64.b64encode(content.encode("utf-8")).decode()
json.dump({"message":"update readme: add progress gif","content":new_b64,"sha":sha,"branch":"main"},
          open(sys.argv[2],"w",encoding="utf-8"))
```
跑：`python "C:/path/edit_readme.py" "C:/path/readme_meta.json" "C:/path/readme_payload.json"`

> `assert` 那行是命脉：锚点必须唯一，否则一个 replace 改坏多处。先 `grep` 确认锚点在远端 README 只出现一次。

**5c. PUT 更新 README**：
```
gh api --method PUT repos/{owner}/{repo}/contents/README.md --input "C:/path/readme_payload.json"
```

**5d. 复核**：再拉一次远端 README，确认新 GIF 块在、**旧 GIF 块还在**。
- **校验点**：新旧 GIF 都在 = ✅。

### 6. 清理 + 落盘回执

**6a. 删临时文件**：frames、palette.png、cropped.mp4、各 payload.json——都是中间产物，不留。

**6b. 回执写入项目 `state/tasks.md`**（对应该 GIF 任务的条目下）：
```
- [x] <任务简述>
  - skill: devlog-gif
  - 回执：源 `<视频>` → 裁 `crop=W:H:X:Y` 去 UI → <start>-<start+duration>s 精华 → `<gif名>`(<大小>KB)。
    上传 commit <sha>；README 加 GIF 块 commit <sha>（旧 GIF 保留）。配文标 work in progress。
```

## 对外口径（写 GIF 配文时遵守）

- **诚实标进度**：配文带 "work in progress / 进行中"，不吹成成品。
- **画面没到发布门槛别炫耀**：游戏画面若未达发布门槛（如经评估 <6 分），GIF 只作"进度展示"，不作"成品炫耀"。配文往"做到哪了"写，不往"多好看"写。
- **README 是公开的**：截取段落选精华（最有动感、最能体现卖点的几秒）。
- **腔调跟项目 `team.md`**：短句、不堆形容词、收尾一句话钩子。

## 常见问题与处理

| 问题 | 处理 |
|---|---|
| `ffprobe`/`ffmpeg` 命令找不到 | 确认 ffmpeg 在 PATH。没有 → 记 escalation，别装（环境问题） |
| 视觉模型把内容认错 | 多抽几帧（开头/中间/结尾）交叉确认；不确定就问用户 |
| crop 后底部还有控制栏 | 加大 crop 高度（减 `out_h`）或加 `y` 偏移，重抽帧复核 |
| GIF 太大（>8MB） | 降 fps(12→10)、缩更小(600→480)、截更短 |
| GIF 太糊 | scale 调大(720)、fps 提到 15，和大小权衡 |
| `gh api -f content` 报 `Argument list too long` | ❌ 换 payload 文件 + `--input`（第 4 步），别在命令行塞 base64 |
| 上传报 409/422 sha mismatch | 文件已被改过，重拉 sha 再 PUT |
| README replace 撞多处 / 改错位置 | 锚点不唯一 → 用更长的独特串；先 `grep -c` 确认命中 1 次 |
| anchor `hit 0`（replace 一处没替换） | README 很可能是 **CRLF（\r\n）换行**，anchor 用 `\n` 会全 miss。拉远端后先 `print(repr(content[锚点附近]))` 看实际换行符，anchor 和插入块都用 `\r\n`（与原文一致，别混 LF/CRLF） |
| python 报 `FileNotFoundError: /tmp/...` | 路径没用 `C:/` 绝对格式，改掉 |
| 本地工作树有未提交改动想 push | ⚠️ 停。本 skill 第 5 步直传远端不碰本地。push 会覆盖远端 |

## 验收清单（回执逐项勾）

- [ ] 源视频内容经视觉模型确认 = 目标项目（不是录错）
- [ ] 引擎 UI 已裁干净（视觉模型复核过，无 dock/控制栏残留）
- [ ] GIF 大小 < 8MB 且清晰度够（README 全宽不糊）
- [ ] GIF 已上传到仓库（commit sha 记了）
- [ ] README 远端已更新：新 GIF 块在、**旧 GIF 块保留**
- [ ] 全程没碰本地工作树（走 contents API）
- [ ] 临时文件已清理
- [ ] 配文诚实（work in progress，没吹画面，符合 team.md 腔调）
- [ ] 回执已写入项目 `state/tasks.md`
