# OPS-CHANGELOG

运营系统自动感知此文件。开发团队每有用户可感知的变更就加一行。

- 2026-06-11 | fix | specialist 明确内外任务边界（对外=影响团队外才需 skill）；删除 next-run.txt 机制（改为轮询 tasks.md 时间戳）；清理所有残留引用
- 2026-06-10 | refactor | 调度重写：轮询 tasks.md 替代 next-run.txt；专员先执行主管后复盘；只跑有到期任务的项目；Python 解析 manifest emoji；每次启动/结束落盘日志
- 2026-06-09 | refactor | 全量重构：三角色架构、.claude/skills 目录、hooks、模板化 config
- YYYY-MM-DD | 类型 | 一句话
