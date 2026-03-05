"""
SoundScribe Weekly Report Sender
自动发送周报脚本

运行方式:
    python send_weekly_report.py
"""

import os
import sys
import json
from datetime import datetime

# 添加项目根目录到路径
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# 导入邮件服务
from docs.emails.email_service import EmailService, EmailConfig


def get_weekly_report():
    """读取任务看板，生成周报"""
    taskboard_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'docs', 'taskboard.md')

    report = {
        'completed': [],
        'in_progress': [],
        'issues': [],
        'next_week': []
    }

    if os.path.exists(taskboard_path):
        with open(taskboard_path, 'r', encoding='utf-8') as f:
            content = f.read()

            # 简单解析 taskboard.md
            lines = content.split('\n')
            for line in lines:
                if '✅ Done' in line:
                    # 提取任务名
                    parts = line.split('|')
                    if len(parts) > 2:
                        task_name = parts[2].strip()
                        if task_name and task_name != '任务名':
                            report['completed'].append(task_name)
                elif '🔄 In Progress' in line:
                    parts = line.split('|')
                    if len(parts) > 2:
                        task_name = parts[2].strip()
                        if task_name and task_name != '任务名':
                            report['in_progress'].append(task_name)

    # 添加下周计划
    report['next_week'] = [
        'Complete microphone recording feature',
        'Integrate Melody.ml API',
        'UI polishing',
        'Start testing'
    ]

    return report


def main():
    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Starting weekly report...")

    # 加载邮件配置
    config = EmailConfig()
    config.load_from_file('docs/emails/email_config.json')

    # 生成周报
    report = get_weekly_report()

    # 发送邮件
    service = EmailService(config)

    subject = f"[SoundScribe] Weekly Report - {datetime.now().strftime('%Y-%m-%d')}"

    body = f"""
<h3>SoundScribe Weekly Report</h3>
<p><strong>Date:</strong> {datetime.now().strftime('%Y-%m-%d')}</p>

<h4>Completed This Week</h4>
<ul>
{''.join(f'<li>{item}</li>' for item in report['completed'])}
</ul>

<h4>In Progress</h4>
<ul>
{''.join(f'<li>{item}</li>' for item in report['in_progress'])}
</ul>

<h4>Issues</h4>
<ul>
{''.join(f'<li>{item}</li>' for item in report['issues']) or '<li>None</li>'}
</ul>

<h4>Next Week Plan</h4>
<ul>
{''.join(f'<li>{item}</li>' for item in report['next_week'])}
</ul>

<p><i>Sent automatically by SoundScribe Agent</i></p>
"""

    # 发送到你的邮箱
    recipient = 'linj92813@gmail.com'
    success = service.send_email(recipient, subject, body)

    if success:
        print(f"[OK] Weekly report sent to {recipient}")
    else:
        print("[ERROR] Failed to send weekly report")
        sys.exit(1)


if __name__ == '__main__':
    main()
