# BrowserShell 整体技术方案

> 最后更新: 2026-07-20

## 1. 技术上下文

### 1.1 运行时环境

| 项目 | 说明 |
|------|------|
| 操作系统 | HarmonyOS 6.1.0 (API 23) |
| 兼容版本 | HarmonyOS 5.1.0 (API 18) |
| 设备类型 | 手机 (phone)、平板 (tablet) |
| 应用模型 | Stage Model |
| UI 框架 | ArkUI (声明式) |
| 开发语言 | ArkTS |
| 构建工具 | hvigor |
| 包管理 | ohpm |

### 1.2 关键依赖

| 包名 | 用途 |
|------|------|
| @kit.AbilityKit | UIAbility 生命周期管理 |
| @kit.ArkUI | 窗口管理与全屏控制 |
| @kit.PerformanceAnalysisKit | 日志 (hilog) |
| @ohos/hypium | 测试框架 |
| @ohos/hamock | 测试 Mock |

## 2. 宪法合规检查

| 原则 | 状态 | 说明 |
|------|------|------|
| Stage 模型 | ✅ | 使用 UIAbility + module.json5 |
| 类型安全 | ✅ | 明确类型声明，无 any |
| 声明式 UI | ✅ | ArkUI @Component |
| 日志规范 | ⚠️ | 当前使用模板常量 DOMAIN=0x0000，需更新为有意义值 |
| 代码组织 | ✅ | pages/ 独立目录 |
| 测试覆盖 | ⚠️ | 仅有模板测试用例，需补充功能测试 |
| 资源管理 | ⚠️ | 字符串硬编码 "Hello World"，需引用资源 |
| 提交规范 | ✅ | Conventional Commits |

## 3. 实现策略

### 3.1 全屏模式实现

使用 `window.WindowStage` API 设置全屏窗口属性：
- `setWindowLayoutFullScreen(true)` 隐藏状态栏和导航栏
- 在 `EntryAbility.onWindowStageCreate()` 中配置

### 3.2 ArtWeb 浏览器组件

使用 ArkUI 的 `Web` 组件实现浏览器内核：
- `Web({ src: this.currentUrl, controller: this.webController })` 
- 通过 `WebController` 控制导航行为

### 3.3 URL 输入交互

- 浮动按钮：使用 `Stack` 布局 + 绝对定位的 `Button` / `FloatingActionButton`
- URL 输入框：使用条件渲染 `if (this.showUrlInput)` 控制显隐
- 输入组件：使用 `TextInput` 组件

### 3.4 数据持久化

使用 `@kit.ArkData` 的 `preferences` API：
- 存储键: `saved_url`
- 存储时机: 用户确认 URL 输入后
- 读取时机: EntryAbility 或 Index 页面 `aboutToAppear()` 生命周期

## 4. 数据模型

详见 [`overall-data-model.md`](./overall-data-model.md)

## 5. 测试策略

| 测试类型 | 框架 | 范围 |
|----------|------|------|
| 单元测试 | @ohos/hypium | 数据持久化逻辑 |
| 集成测试 | @ohos/hypium (ohosTest) | UI 交互流程 |

详见 [`overall-test-cases.md`](./overall-test-cases.md)

## 6. 部署策略

```
源代码 (ArkTS)
    ↓ hvigor 构建
HAP 包 (entry-default-signed.hap)
    ↓ hdc install
模拟器 (MyTablet) / 真机
    ↓
HarmonyOS 运行时
```
