# SoundScribe Agent 邮件系统

## 真实邮件服务

本项目使用真实 SMTP 邮件服务进行 Agent 之间的沟通。

### 配置步骤

#### 1. Gmail 配置（推荐）

1. 开启 Gmail 两步验证：https://myaccount.google.com/signinoptions/two-step-verification
2. 生成应用专用密码：https://myaccount.google.com/apppasswords
3. 编辑 `email_config.json`：

```json
{
  "smtp_server": "smtp.gmail.com",
  "smtp_port": 587,
  "smtp_username": "your_email@gmail.com",
  "smtp_password": "xxxx xxxx xxxx xxxx",
  "from_email": "your_email@gmail.com",
  "from_name": "SoundScribe PM"
}
```

#### 2. 其他邮箱

| 邮箱服务 | SMTP 服务器 | 端口 |
|---------|-------------|------|
| Gmail | smtp.gmail.com | 587 |
| Outlook | smtp.office365.com | 587 |
| QQ Mail | smtp.qq.com | 587 |
| 163 | smtp.163.com | 25 |

---

## 使用方法

### 发送任务邮件

```bash
cd D:/ai_product/SoundScribe/docs/emails

python email_service.py \
  --to "frontend@soundscribe.local" \
  --subject "[Task] T003 UI设计" \
  --body "请完成UI原型设计..." \
  --cc "boss@soundscribe.local"
```

### 发送周报（PM→Boss）

```bash
python email_service.py \
  --to "boss@soundscribe.local" \
  --subject "[周报] 2026-03-05 项目进度" \
  --body "本周完成：项目初始化、技术方案设计..."
```

---

## Agent 邮箱地址

| Agent | 职责 | 邮箱 | 备注 |
|-------|------|------|------|
| PM | 任务分配、汇报 | pm@soundscribe.local | 向 Boss 汇报 |
| Frontend | UI 开发 | frontend@soundscribe.local | |
| Backend | 后端开发 | backend@soundscribe.local | |
| QA | 测试 | qa@soundscribe.local | |

---

## 自动邮件规则

### 每日
- 无自动邮件

### 周五
- PM → Boss: 周报

### 遇到阻塞时
- Agent → PM: 紧急邮件 @pm

### 任务完成时
- Agent → PM + 相关 Agent: 任务完成通知
