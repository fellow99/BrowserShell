# BrowserShell

基于 HarmonyOS / OpenHarmony 的 ArtWeb 浏览器壳应用。

## 功能特性

- **全屏浏览器**: 应用全屏展示 WebView 浏览器，覆盖状态栏和导航栏
- **URL 输入与导航**: 左下角浮动按钮触发 URL 输入框，输入网址即可浏览
- **URL 持久化**: 自动保存上次访问的 URL，下次启动自动恢复
- **沉浸式体验**: 简洁无干扰的全屏浏览界面

## 技术栈

- **操作系统**: HarmonyOS 6.1.0 (API 23)，兼容 5.1.0 (API 18)
- **开发语言**: ArkTS
- **UI 框架**: ArkUI (声明式)
- **应用模型**: Stage Model
- **构建工具**: hvigor
- **测试框架**: @ohos/hypium

## 项目结构

```
BrowserShell/
├── AppScope/           # 应用全局配置
├── entry/              # 主入口模块
│   └── src/main/ets/
│       ├── entryability/    # UIAbility 入口
│       ├── pages/           # 页面组件
│       └── entrybackupability/  # 备份扩展
├── hvigor/             # 构建工具配置
├── specs/              # 规范文档
└── README.md
```

详见 [specs/STRUCTURE.md](specs/STRUCTURE.md)

## 规范文档

完整的技术规格、架构设计、测试用例等文档见 [specs/](specs/) 目录。

| 文档 | 说明 |
|------|------|
| [功能规格](specs/001-browser-shell/spec.md) | 浏览器壳功能规格 |
| [技术方案](specs/001-browser-shell/plan.md) | 实现技术方案 |
| [任务分解](specs/001-browser-shell/tasks.md) | 开发任务清单 |
| [测试用例](specs/001-browser-shell/test-cases.md) | 功能测试用例 |

## 构建与运行

### 环境要求

- DevEco Studio 6.x
- HarmonyOS SDK API 23
- Node.js (DevEco Studio 自带)

### 构建

在 DevEco Studio 中打开项目，点击 Build → Build HAP(s)。

或使用命令行：

```bash
hvigorw assembleHap
```

### 运行

1. 启动 HarmonyOS 模拟器（如 MyTablet）
2. 在 DevEco Studio 中点击 Run
3. 或使用 `hdc install` 安装 HAP 包

## 开发规范

本项目遵循 [specs/constitution.md](specs/constitution.md) 中定义的编码规范。
