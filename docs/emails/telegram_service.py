"""
SoundScribe Telegram Service
Telegram 机器人通知服务

使用方式:
    python telegram_service.py --chat_id "YOUR_CHAT_ID" --message "Hello!"
"""

import requests
import argparse
import json
import os

class TelegramService:
    def __init__(self, bot_token=None, config_file='telegram_config.json'):
        if bot_token:
            self.bot_token = bot_token
        else:
            config = self._load_config(config_file)
            self.bot_token = config.get('bot_token', '')

        self.api_url = f"https://api.telegram.org/bot{self.bot_token}"

    def _load_config(self, config_file):
        if os.path.exists(config_file):
            with open(config_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        return {}

    def send_message(self, chat_id, text, parse_mode='HTML'):
        """发送消息到 Telegram"""
        if not self.bot_token:
            print("[ERROR] Please configure bot_token in telegram_config.json")
            return False

        url = f"{self.api_url}/sendMessage"
        data = {
            'chat_id': chat_id,
            'text': text,
            'parse_mode': parse_mode
        }

        try:
            response = requests.post(url, json=data, timeout=30)
            result = response.json()

            if result.get('ok'):
                print(f"[OK] Message sent to chat {chat_id}")
                return True
            else:
                print(f"[ERROR] Failed: {result.get('description')}")
                return False

        except requests.exceptions.Timeout:
            print("[ERROR] Connection timeout")
            return False
        except Exception as e:
            print(f"[ERROR] {e}")
            return False

    def send_task_update(self, chat_id, task_id, task_name, status):
        """发送任务更新"""
        status_emoji = {
            'done': '[DONE]',
            'in_progress': '[IN PROGRESS]',
            'blocked': '[BLOCKED]',
            'pending': '[PENDING]'
        }

        message = f"""
<b>SoundScribe Task Update</b>

Task: {task_name}
ID: {task_id}
Status: {status_emoji.get(status, status)}
        """

        return self.send_message(chat_id, message)

    def send_weekly_report(self, chat_id, report_data):
        """发送周报"""
        message = f"""
<b>SoundScribe Weekly Report</b>

<b>Completed:</b>
{chr(10).join(f"- {item}" for item in report_data.get('completed', []))}

<b>In Progress:</b>
{chr(10).join(f"- {item}" for item in report_data.get('in_progress', []))}

<b>Issues:</b>
{chr(10).join(f"- {item}" for item in report_data.get('issues', []))}

<b>Next Week:</b>
{chr(10).join(f"- {item}" for item in report_data.get('next_week', []))}
        """

        return self.send_message(chat_id, message)

    def get_chat_id(self, message_text):
        """获取 chat_id（用于初始化）"""
        url = f"{self.api_url}/getUpdates"
        try:
            response = requests.get(url, timeout=30)
            result = response.json()
            if result.get('ok'):
                for update in result.get('result', []):
                    if update.get('message', {}).get('text') == message_text:
                        chat_id = update['message']['chat']['id']
                        print(f"[OK] Your chat_id is: {chat_id}")
                        return chat_id
                print("[INFO] No matching message found. Send /start to your bot first.")
                print("[INFO] Then run this command again.")
            else:
                print(f"[ERROR] {result.get('description')}")
        except Exception as e:
            print(f"[ERROR] {e}")


def main():
    parser = argparse.ArgumentParser(description='SoundScribe Telegram Service')
    parser.add_argument('--setup', action='store_true', help='Get bot info')
    parser.add_argument('--get_chat_id', type=str, help='Get chat ID from a message')
    parser.add_argument('--chat_id', type=str, help='Telegram chat ID')
    parser.add_argument('--message', type=str, help='Message to send')
    parser.add_argument('--config', type=str, default='telegram_config.json', help='Config file')

    args = parser.parse_args()

    if args.setup:
        print("[INFO] To set up Telegram bot:")
        print("1. Open Telegram and search for @BotFather")
        print("2. Send /newbot to create a new bot")
        print("3. Copy the bot token")
        print("4. Edit telegram_config.json with your token")
        print("5. Start your bot by clicking /start")
        print("6. Run: python telegram_service.py --get_chat_id /start")
        return

    if args.get_chat_id:
        service = TelegramService(config_file=args.config)
        service.get_chat_id(args.get_chat_id)
        return

    if not args.chat_id or not args.message:
        print("Error: Please provide --chat_id and --message")
        print("Example: python telegram_service.py --chat_id '123456' --message 'Hello'")
        return

    service = TelegramService(config_file=args.config)
    service.send_message(args.chat_id, args.message)


if __name__ == '__main__':
    main()
