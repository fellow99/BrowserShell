# BrowserShell 规范文档

> 版本: 1.0.0 | 最后更新: 2026-07-20

## 项目简介

BrowserShell 是一个基于 HarmonyOS / OpenHarmony 的轻量级浏览器壳应用，使用 ArkUI 框架和 ArtWeb 组件实现全屏 WebView 浏览器功能。

- **技术栈**: HarmonyOS 6.1.0 + ArkTS + ArkUI + Stage Model
- **目标设备**: 手机 (phone)、平板 (tablet)
- **应用包名**: org.fellow99.BrowserShell

## 文档索引

### 项目级文档

| 文档 | 说明 |
|------|------|
| [SPECS_CHECKLIST.md](./SPECS_CHECKLIST.md) | 规范文档完成情况跟踪 |
| [STRUCTURE.md](./STRUCTURE.md) | 完整项目目录结构及页面路由清单 |
| [API.md](./API.md) | API 端点清单（当前无 REST API） |
| [TECH.md](./TECH.md) | 技术栈、依赖、构建环境 |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | 系统分层架构、Stage 模型组件、数据流 |
| [constitution.md](./constitution.md) | 项目宪法原则（编码规范与约束） |
| [overall-spec.md](./overall-spec.md) | 系统级功能规格（技术无关） |
| [overall-plan.md](./overall-plan.md) | 系统级技术方案 |
| [overall-data-model.md](./overall-data-model.md) | 数据模型：实体定义与状态流转 |
| [overall-api.md](./overall-api.md) | 模块间接口契约 |
| [overall-test-cases.md](./overall-test-cases.md) | 测试用例索引 |

### 功能模块文档

| 模块 | 编号 | 规格 | 方案 | 任务 | 测试 |
|------|------|------|------|------|------|
| 浏览器壳 | 001 | [spec.md](./001-browser-shell/spec.md) | [plan.md](./001-browser-shell/plan.md) | [tasks.md](./001-browser-shell/tasks.md) | [test-cases.md](./001-browser-shell/test-cases.md) |
