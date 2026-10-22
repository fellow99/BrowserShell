# BrowserShell 技术选型

> 最后更新: 2026-07-20

## 技术栈总览

| 类别 | 技术 | 版本 | 用途 |
|------|------|------|------|
| 操作系统 | HarmonyOS | 6.1.1 (API 24) | 目标运行平台 |
| 兼容版本 | HarmonyOS | 6.0.0 (API 20) | 最低兼容版本 |
| 开发语言 | ArkTS | — | 应用开发语言 (TypeScript 超集) |
| UI 框架 | ArkUI | — | 声明式 UI 组件框架 |
| 应用模型 | Stage Model | — | 现代应用生命周期模型 |
| 构建工具 | hvigor | — | 鸿蒙原生构建系统 |
| 包管理 | ohpm | — | 鸿蒙原生包管理器 |
| 测试框架 | @ohos/hypium | 1.0.25 | 单元测试与集成测试 |
| Mock 框架 | @ohos/hamock | 1.0.0 | 测试 Mock |
| 代码检查 | code-linter | — | DevEco Studio 内置代码检查 |
| IDE | DevEco Studio | 6.x | 官方集成开发环境 |

## 运行时依赖

| 依赖 | 来源 | 用途 |
|------|------|------|
| @kit.AbilityKit | 系统 SDK | UIAbility 生命周期管理 |
| @kit.PerformanceAnalysisKit | 系统 SDK | hilog 日志输出 |
| @kit.ArkUI | 系统 SDK | 窗口管理与 UI 加载 |
| @kit.CoreFileKit | 系统 SDK | 备份恢复扩展能力 |

## 构建环境

| 环境变量 | 路径 | 说明 |
|----------|------|------|
| DEVECO_SDK_HOME | D:\oh-workspace\deveco-studio-6\sdk | DevEco SDK 根目录 |
| OHOS_SDK_HOME | C:\Users\fello\AppData\Local\OpenHarmony\Sdk | OpenHarmony SDK 根目录 |
| NODE_HOME | D:\oh-workspace\deveco-studio-6\tools\node | Node.js 运行时 |
| JAVA_HOME | D:\oh-workspace\deveco-studio-6\jbr | JDK (JetBrains Runtime) |
| HVIGOR_HOME | D:\oh-workspace\deveco-studio-6\tools\hvigor | hvigor 构建工具 |

## 应用配置

| 配置项 | 值 | 说明 |
|--------|-----|------|
| bundleName | org.fellow99.test.BrowserShell | 应用包名 |
| versionCode | 1000000 | 版本号 |
| versionName | 1.0.0 | 版本名 |
| targetSdkVersion | 6.1.0(23) | 目标 SDK |
| compatibleSdkVersion | 6.0.0(20) | 最低兼容 SDK |
| deviceTypes | phone, tablet | 支持设备类型 |
