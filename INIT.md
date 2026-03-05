# SoundScribe 项目恢复指南

## 快速恢复

下次对话时，直接告诉我：
> "继续 SoundScribe 项目"

或者运行以下命令读取项目状态：

```bash
# 1. 读取任务看板
cat D:/ai_product/SoundScribe/docs/taskboard.md

# 2. 读取沟通机制
cat D:/ai_product/SoundScribe/docs/AGENT_COMMUNICATION.md
```

---

## 项目状态摘要

### 最后更新
- 日期: 2026-03-05
- 版本: v0.1.0

### 完成的工作
- ✅ Git 仓库初始化
- ✅ 项目结构创建
- ✅ SPEC.md 技术规格
- ✅ Agent 沟通机制 v2.0
- ✅ 任务看板

### 当前任务 (Week 1)
- 🔄 T002: 技术方案设计 (Backend)
- 🔄 T003: UI 原型设计 (Frontend)
- 🔄 T004: 测试计划编写 (QA)

### 计划
- Week 2: Flutter 基础框架、麦克风录音
- Week 3: AI 集成、PDF 生成
- Week 4: 测试与发布
- Deadline: 2026-04-05 (1个月)

---

## Agent 团队

| Agent | 邮箱 | 当前任务 |
|-------|------|----------|
| PM | pm@soundscribe.local | 任务分配、进度汇报 |
| Frontend | frontend@soundscribe.local | UI 原型设计 |
| Backend | frontend@soundscribe.local | 技术方案设计 |
| QA | qa@soundscribe.local | 测试计划编写 |

---

## 常用命令

```bash
# 进入项目目录
cd D:/ai_product/SoundScribe

# 查看任务看板
cat docs/taskboard.md

# 查看最新邮件
cat docs/emails/01_welcome.md

# 查看技术规格
cat SPEC.md

# Git 提交
git add . && git commit -m "描述"

# Git 推送 (如已配置远程)
git push origin master
```
