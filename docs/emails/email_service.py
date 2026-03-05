"""
SoundScribe Email Service
真实邮件发送服务

使用方式:
    python email_service.py --to "pm@soundscribe.local" --subject "Task Complete" --body "内容"
"""

import smtplib
import os
import json
import argparse
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime

# 邮件配置 (从环境变量或配置文件读取)
class EmailConfig:
    def __init__(self):
        self.smtp_server = os.environ.get('SMTP_SERVER', 'smtp.gmail.com')
        self.smtp_port = int(os.environ.get('SMTP_PORT', '587'))
        self.smtp_username = os.environ.get('SMTP_USERNAME', '')
        self.smtp_password = os.environ.get('SMTP_PASSWORD', '')
        self.from_email = os.environ.get('FROM_EMAIL', self.smtp_username)
        self.from_name = os.environ.get('FROM_NAME', 'SoundScribe Agent')

    def load_from_file(self, config_path='email_config.json'):
        if os.path.exists(config_path):
            with open(config_path, 'r') as f:
                config = json.load(f)
                self.smtp_server = config.get('smtp_server', self.smtp_server)
                self.smtp_port = config.get('smtp_port', self.smtp_port)
                self.smtp_username = config.get('smtp_username', self.smtp_username)
                self.smtp_password = config.get('smtp_password', self.smtp_password)
                self.from_email = config.get('from_email', self.from_email)
                self.from_name = config.get('from_name', self.from_name)

    def save_template(self, config_path='email_config.json'):
        template = {
            "smtp_server": "smtp.gmail.com",
            "smtp_port": 587,
            "smtp_username": "your_email@gmail.com",
            "smtp_password": "your_app_password",
            "from_email": "your_email@gmail.com",
            "from_name": "SoundScribe Agent"
        }
        with open(config_path, 'w') as f:
            json.dump(template, f, indent=2)


class EmailService:
    def __init__(self, config=None):
        self.config = config or EmailConfig()

    def send_email(self, to_email, subject, body, cc=None):
        """发送邮件"""
        if not self.config.smtp_username or not self.config.smtp_password:
            print("错误: 请先配置 SMTP 设置")
            print("运行: python email_service.py --setup")
            return False

        try:
            # 创建邮件
            msg = MIMEMultipart('alternative')
            msg['From'] = f"{self.config.from_name} <{self.config.from_email}>"
            msg['To'] = to_email
            msg['Subject'] = subject
            if cc:
                msg['Cc'] = cc

            # HTML 内容
            html_body = f"""
            <html>
            <body style="font-family: Arial, sans-serif; padding: 20px;">
                <div style="background-color: #f5f5f5; padding: 20px; border-radius: 10px;">
                    <h2 style="color: #6366F1;">SoundScribe Agent Team</h2>
                    <div style="background-color: white; padding: 20px; border-radius: 5px; margin-top: 10px;">
                        {body.replace('\n', '<br>')}
                    </div>
                    <p style="color: #888; font-size: 12px; margin-top: 20px;">
                        发送时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
                    </p>
                </div>
            </body>
            </html>
            """

            msg.attach(MIMEText(body, 'plain'))
            msg.attach(MIMEText(html_body, 'html'))

            # 连接 SMTP 服务器
            server = smtplib.SMTP(self.config.smtp_server, self.config.smtp_port)
            server.starttls()
            server.login(self.config.smtp_username, self.config.smtp_password)

            # 发送邮件
            recipients = [to_email] + ([cc] if cc else [])
            server.sendmail(self.config.from_email, recipients, msg.as_string())
            server.quit()

            print(f"✅ 邮件已发送到: {to_email}")
            return True

        except Exception as e:
            print(f"❌ 发送失败: {e}")
            return False

    def send_task_email(self, agent_name, task_id, task_name, status, to_email):
        """发送任务邮件"""
        status_emoji = {
            'done': '✅',
            'in_progress': '🔄',
            'blocked': '⚠️',
            'pending': '⏳'
        }

        subject = f"[SoundScribe] {status_emoji.get(status, '')} {task_id}: {task_name}"
        body = f"""
        <h3>任务更新</h3>
        <p><strong>Agent:</strong> {agent_name}</p>
        <p><strong>任务ID:</strong> {task_id}</p>
        <p><strong>任务名:</strong> {task_name}</p>
        <p><strong>状态:</strong> {status.upper()}</p>
        <p><strong>时间:</strong> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
        """

        return self.send_email(to_email, subject, body)

    def send_weekly_report(self, report_data, to_email):
        """发送周报"""
        subject = f"[SoundScribe] 周报 - {datetime.now().strftime('%Y-%m-%d')}"
        body = f"""
        <h3>📊 SoundScribe 周报</h3>
        <p><strong>日期:</strong> {datetime.now().strftime('%Y-%m-%d')}</p>

        <h4>本周完成</h4>
        <ul>
        {''.join(f'<li>{item}</li>' for item in report_data.get('completed', []))}
        </ul>

        <h4>进行中</h4>
        <ul>
        {''.join(f'<li>{item}</li>' for item in report_data.get('in_progress', []))}
        </ul>

        <h4>遇到问题</h4>
        <ul>
        {''.join(f'<li>{item}</li>' for item in report_data.get('issues', []))}
        </ul>

        <h4>下周计划</h4>
        <ul>
        {''.join(f'<li>{item}</li>' for item in report_data.get('next_week', []))}
        </ul>
        """

        return self.send_email(to_email, subject, body)


def main():
    parser = argparse.ArgumentParser(description='SoundScribe Email Service')
    parser.add_argument('--setup', action='store_true', help='创建邮件配置模板')
    parser.add_argument('--to', type=str, help='收件人')
    parser.add_argument('--subject', type=str, help='主题')
    parser.add_argument('--body', type=str, help='邮件内容')
    parser.add_argument('--cc', type=str, help='抄送')
    parser.add_argument('--config', type=str, default='email_config.json', help='配置文件路径')

    args = parser.parse_args()

    if args.setup:
        config = EmailConfig()
        config.save_template(args.config)
        print(f"✅ 配置文件模板已创建: {args.config}")
        print("请编辑配置文件填入你的 SMTP 设置")
        return

    if not args.to or not args.subject or not args.body:
        print("错误: 请提供 --to, --subject, --body 参数")
        print("示例: python email_service.py --to 'boss@example.com' --subject '周报' --body '内容'")
        return

    config = EmailConfig()
    config.load_from_file(args.config)

    service = EmailService(config)
    service.send_email(args.to, args.subject, args.body, args.cc)


if __name__ == '__main__':
    main()
