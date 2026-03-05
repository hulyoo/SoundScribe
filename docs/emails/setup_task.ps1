# SoundScribe 计划任务设置脚本
# 以管理员身份运行此脚本

$taskName = "SoundScribe Weekly Report"
$scriptPath = "D:\ai_product\SoundScribe\docs\emails\send_report.bat"
$description = "自动发送 SoundScribe 周报"

# 检查任务是否已存在
$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($existingTask) {
    Write-Host "[INFO] Task '$taskName' already exists. Removing it first..."
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# 创建触发器 - 每天 10:00
$trigger = New-ScheduledTaskTrigger -Daily -At "10:00"

# 创建操作
$action = New-ScheduledTaskAction -Execute $scriptPath

# 创建任务设置
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# 注册任务
Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Settings $settings -Description $description -RunLevel Limited

Write-Host "[OK] Task '$taskName' created successfully!"
Write-Host "The report will be sent daily at 10:00 AM to your email."
Write-Host ""
Write-Host "To view or manage the task:"
Write-Host "  1. Open Task Scheduler (taskschd.msc)"
Write-Host "  2. Find task: $taskName"
Write-Host ""
Write-Host "To remove the task, run:"
Write-Host "  Unregister-ScheduledTask -TaskName '$taskName' -Confirm:`$false"
