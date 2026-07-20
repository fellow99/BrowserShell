# BrowserShell 对外接口模型

> 最后更新: 2026-07-20

## 1. 概述

BrowserShell 是一个纯前端应用，当前版本不暴露对外 API 接口。本文档描述内部模块间的接口约定。

## 2. 模块间接口

### 2.1 EntryAbility → Index 页面

**接口**: `windowStage.loadContent('pages/Index', callback)`

| 方向 | 说明 |
|------|------|
| 调用方 | EntryAbility.onWindowStageCreate() |
| 被调用方 | Index 页面 @Entry @Component |

备注: Stage 模型的标准页面加载方式，无自定义传参。

### 2.2 Index 页面 → Preferences 存储

**接口**: `dataPreferences.getPreferences()` / `.put()` / `.get()` / `.flush()`

| 方向 | 说明 |
|------|------|
| 调用方 | Index 页面组件 |
| 被调用方 | @kit.ArkData → preferences 模块 |
| 数据 | `saved_url` key → JSON `{url, savedAt}` |

### 2.3 浏览器 Web 组件 ← → 外部网页

**接口**: HTTP/HTTPS (系统 WebView 内核处理)

| 方向 | 说明 |
|------|------|
| 发起方 | ArkUI Web 组件 |
| 目标 | 用户指定的 URL |
| 协议 | HTTP / HTTPS |

## 3. 未来扩展接口

以下接口为预期但未实现的扩展点：

| 接口 | 类型 | 状态 |
|------|------|------|
| 浏览器历史记录 CRUD | 内部接口 | 未实现 |
| 书签管理 | 内部接口 | 未实现 |
| 远程配置下发 | 外部 API | 未实现 |
