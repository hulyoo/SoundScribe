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
            with open(config_path, 'r', encoding='utf-8') as f:
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
        with open(config_path, 'w', encoding='utf-8') as f:
            json.dump(template, f, indent=2)


class EmailService:
    def __init__(self, config=None):
        self.config = config or EmailConfig()

    def send_email(self, to_email, subject, body, cc=None):
        """发送邮件"""
        if not self.config.smtp_username or not self.config.smtp_password:
            print("Error: Please configure SMTP settings first")
            print("Run: python email_service.py --setup")
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
                        {body.replace(chr(10), '<br>')}
                    </div>
                    <p style="color: #888; font-size: 12px; margin-top: 20px;">
                        Sent: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
                    </p>
                </div>
            </body>
            </html>
            """

            msg.attach(MIMEText(body, 'plain', 'utf-8'))
            msg.attach(MIMEText(html_body, 'html', 'utf-8'))

            # 连接 SMTP 服务器 (添加超时)
            server = smtplib.SMTP(self.config.smtp_server, self.config.smtp_port, timeout=30)
            server.starttls()
            server.login(self.config.smtp_username, self.config.smtp_password)

            # 发送邮件
            recipients = [to_email] + ([cc] if cc else [])
            server.sendmail(self.config.from_email, recipients, msg.as_string())
            server.quit()

            print(f"[OK] Email sent to: {to_email}")
            return True

        except smtplib.SMTPAuthenticationError:
            print(f"[ERROR] Authentication failed. Check your email/password.")
            return False
        except smtplib.SMTPConnectError as e:
            print(f"[ERROR] Cannot connect to SMTP server: {e}")
            print(f"[HINT] If you're in China, Gmail may be blocked. Try using a VPN or a Chinese email service.")
            return False
        except TimeoutError:
            print(f"[ERROR] Connection timeout. The SMTP server may be unreachable.")
            print(f"[HINT] If you're in China, Gmail may be blocked. Try using a VPN or a Chinese email service.")
            return False
        except Exception as e:
            print(f"[ERROR] Failed to send email: {e}")
            return False

    def send_task_email(self, agent_name, task_id, task_name, status, to_email):
        """发送任务邮件"""
        status_emoji = {
            'done': '[DONE]',
            'in_progress': '[IN PROGRESS]',
            'blocked': '[BLOCKED]',
            'pending': '[PENDING]'
        }

        subject = f"[SoundScribe] {status_emoji.get(status, '')} {task_id}: {task_name}"
        body = f"""
        <h3>Task Update</h3>
        <p><strong>Agent:</strong> {agent_name}</p>
        <p><strong>Task ID:</strong> {task_id}</p>
        <p><strong>Task Name:</strong> {task_name}</p>
        <p><strong>Status:</strong> {status.upper()}</p>
        <p><strong>Time:</strong> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
        """

        return self.send_email(to_email, subject, body)

    def send_weekly_report(self, report_data, to_email):
        """发送周报"""
        subject = f"[SoundScribe] Weekly Report - {datetime.now().strftime('%Y-%m-%d')}"
        body = f"""
        <h3>SoundScribe Weekly Report</h3>
        <p><strong>Date:</strong> {datetime.now().strftime('%Y-%m-%d')}</p>

        <h4>Completed This Week</h4>
        <ul>
        {''.join(f'<li>{item}</li>' for item in report_data.get('completed', []))}
        </ul>

        <h4>In Progress</h4>
        <ul>
        {''.join(f'<li>{item}</li>' for item in report_data.get('in_progress', []))}
        </ul>

        <h4>Issues</h4>
        <ul>
        {''.join(f'<li>{item}</li>' for item in report_data.get('issues', []))}
        </ul>

        <h4>Next Week Plan</h4>
        <ul>
        {''.join(f'<li>{item}</li>' for item in report_data.get('next_week', []))}
        </ul>
        """

        return self.send_email(to_email, subject, body)


def main():
    parser = argparse.ArgumentParser(description='SoundScribe Email Service')
    parser.add_argument('--setup', action='store_true', help='Create email config template')
    parser.add_argument('--to', type=str, help='Recipient')
    parser.add_argument('--subject', type=str, help='Subject')
    parser.add_argument('--body', type=str, help='Body')
    parser.add_argument('--cc', type=str, help='CC')
    parser.add_argument('--config', type=str, default='email_config.json', help='Config file path')

    args = parser.parse_args()

    if args.setup:
        config = EmailConfig()
        config.save_template(args.config)
        print(f"[OK] Config template created: {args.config}")
        print("Please edit the config file with your SMTP settings")
        return

    if not args.to or not args.subject or not args.body:
        print("Error: Please provide --to, --subject, --body parameters")
        print("Example: python email_service.py --to 'boss@example.com' --subject 'Report' --body 'Content'")
        return

    config = EmailConfig()
    config.load_from_file(args.config)

    service = EmailService(config)
    service.send_email(args.to, args.subject, args.body, args.cc)


if __name__ == '__main__':
    main()
