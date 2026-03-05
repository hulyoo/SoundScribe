# SoundScribe 技术规格说明书

## 1. 项目概述

- **项目名称**: SoundScribe
- **项目类型**: 跨平台移动/桌面应用
- **核心功能**: 用户通过麦克风录音，AI 自动识别歌曲并生成曲谱，导出 PDF
- **目标用户**: 音乐爱好者、吉他学习者、乐队排练人员

## 2. 技术方案

### 2.1 技术栈

| 类别 | 技术选择 |
|------|----------|
| 框架 | Flutter 3.x |
| 语言 | Dart 3.x |
| 状态管理 | Riverpod / Provider |
| 音频录制 | record package |
| AI 扒谱 | Melody.ml API |
| PDF 生成 | pdf, printing packages |
| 存储 | path_provider |
| HTTP | dio |

### 2.2 架构设计

```
lib/
├── core/              # 核心工具类
│   ├── constants/    # 常量定义
│   ├── theme/        # 主题配置
│   └── utils/        # 工具函数
├── data/             # 数据层
│   ├── models/       # 数据模型
│   ├── repositories/# 仓库实现
│   └── services/     # 外部服务
├── domain/           # 领域层
│   ├── entities/     # 实体
│   └── usecases/    # 用例
├── infrastructure/   # 基础设施
│   └── api/         # API 客户端
└── presentation/     # 表现层
    ├── pages/       # 页面
    ├── widgets/     # 组件
    └── providers/   # 状态管理
```

### 2.3 AI 服务集成

**Melody.ml API**
- 端点: https://api.melody.ml
- 功能: 音频转乐谱
- 认证: API Key

### 2.4 音频处理流程

```
麦克风录音 → WAV/MP3 编码 → 上传 Melody.ml →
获取识别结果 → 解析和弦/旋律 → 生成 PDF → 用户下载
```

## 3. 功能列表

### MVP (Week 1-2)

| 功能 | 优先级 | 状态 |
|------|--------|------|
| 麦克风录音 | P0 | - |
| 音频保存 | P0 | - |
| Melody.ml API 集成 | P0 | - |
| 吉他谱 PDF 生成 | P0 | - |
| 录音列表 | P1 | - |
| 曲谱预览 | P1 | - |

### 后续版本

| 功能 | 优先级 |
|------|--------|
| 音频文件上传 | P1 |
| 多乐器支持 | P2 |
| 在线播放识别 | P2 |
| 云端存储 | P2 |

## 4. 界面设计

### 4.1 页面结构

1. **首页** - 录音入口、历史记录
2. **录音页** - 实时录音、波形显示
3. **处理页** - AI 处理中状态
4. **结果页** - 曲谱预览、PDF 导出
5. **设置页** - API 配置、主题切换

### 4.2 UI 风格

- 简洁现代
- 音乐相关元素（音符、吉他图标）
- 深色/浅色主题支持

## 5. API 接口

### Melody.ml

```
POST /transcribe
Headers:
  Authorization: Bearer <API_KEY>
  Content-Type: multipart/form-data
Body:
  audio: <audio_file>
Response:
{
  "chords": [...],
  "melody": [...],
  "tempo": 120,
  "key": "C"
}
```

## 6. 数据模型

### TranscriptionResult
- id: String
- audioPath: String
- chords: List<Chord>
- melody: List<Note>
- tempo: int
- key: String
- createdAt: DateTime

### Chord
- name: String (e.g., "C", "Am", "G7")
- startTime: double
- duration: double

### Note
- pitch: String
- octave: int
- startTime: double
- duration: double

## 7. 测试计划

### 单元测试
- 音频处理逻辑
- API 客户端
- PDF 生成

### 集成测试
- 完整录音→识别→导出流程

### UI 测试
- 各平台兼容性

## 8. 发布计划

| 平台 | 目标 |
|------|------|
| Windows | MVP |
| macOS | MVP |
| Linux | MVP |
| iOS | Week 3-4 |
| Android | Week 3-4 |
