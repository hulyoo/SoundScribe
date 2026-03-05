# Telegram 通知服务配置指南

## 步骤 1: 创建 Telegram Bot

1. 打开 Telegram，搜索 **@BotFather**
2. 发送 `/newbot` 创建新机器人
3. 按照提示输入机器人名称（如 `SoundScribe PM`）
4. 获取 **Bot Token**（类似：`123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`）

## 步骤 2: 配置 Token

编辑 `telegram_config.json`：
```json
{
  "bot_token": "你的Bot_Token",
  "chat_id": "YOUR_CHAT_ID"
}
```

## 步骤 3: 获取 Chat ID

1. 启动你的机器人（点击 /start）
2. 运行：
```bash
python telegram_service.py --get_chat_id /start
```
3. 会输出你的 **Chat ID**

## 步骤 4: 更新配置

将 Chat ID 填入 `telegram_config.json`：
```json
{
  "bot_token": "你的Bot_Token",
  "chat_id": "123456789"
}
```

## 发送测试消息

```bash
python telegram_service.py --chat_id "123456789" --message "Hello from SoundScribe!"
```

---

## 使用场景

- 任务完成通知
- 周报发送
- 紧急问题提醒
