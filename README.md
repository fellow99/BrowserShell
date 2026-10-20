# BrowserShell

基于 HarmonyOS / OpenHarmony 的 ArtWeb 浏览器壳应用。

## 功能特性

- **浏览器内核**: ArkWeb 组件常驻窗口全尺寸渲染，开启 JavaScript 与 DOM Storage
- **底部导航入口 + 地址面板**: 左下角渐变圆形入口按钮，点击在底部展开胶囊式地址面板
  （输入框 /「前往」/ 关闭），展开即请求焦点，非法地址就地提示、不跳转
- **响应式布局**: 按窗口宽度分紧凑 / 常规 / 宽屏三档（面板 100% / 68% / 46%，最大 760vp），
  监听 `windowSizeChange`，横竖屏切换实时重排
- **URL 持久化**: 自动保存上次确认的 URL，下次启动自动恢复
- **加载容错**: 子资源加载失败（图片 / 脚本 404、字体被拒等）不再中断页面；仅主文档真实
  失败时叠加错误提示并支持重试，Web 组件不会被卸载
- **返回键语义**: 系统返回键优先让 ArkWeb 回退历史，地址面板展开时先收起面板，
  无历史可退时交还系统（应用退到后台）

## 技术栈

- **操作系统**: HarmonyOS 6.1.1 (API 24)，兼容 6.0.0 (API 20)
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
- HarmonyOS SDK API 24（DevEco Studio 内置 6.1.1）
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
