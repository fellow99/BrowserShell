# BrowserShell 系统架构

> 最后更新: 2026-07-20

## 架构概览

BrowserShell 采用 HarmonyOS Stage 模型架构，是一个**单模块、单 Ability** 的轻量应用。

## 分层架构

```
┌─────────────────────────────────────────────┐
│              Presentation Layer              │
│  ┌───────────────────────────────────────┐  │
│  │  ArkUI Pages (pages/)                  │  │
│  │  - Index.ets (主页)                    │  │
│  └───────────────────────────────────────┘  │
├─────────────────────────────────────────────┤
│           Application Logic Layer            │
│  ┌───────────────────────────────────────┐  │
│  │  UIAbility (entryability/)             │  │
│  │  - EntryAbility.ets (应用入口)         │  │
│  └───────────────────────────────────────┘  │
│  ┌───────────────────────────────────────┐  │
│  │  ExtensionAbility                      │  │
│  │  - EntryBackupAbility.ets (备份恢复)   │  │
│  └───────────────────────────────────────┘  │
├─────────────────────────────────────────────┤
│              Platform Layer                  │
│  ┌───────────────────────────────────────┐  │
│  │  HarmonyOS SDK (API 23)                │  │
│  │  @kit.AbilityKit, @kit.ArkUI, etc.    │  │
│  └───────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

## Stage 模型组件

| 组件 | 类型 | 职责 |
|------|------|------|
| EntryAbility | UIAbility | 应用主入口，管理窗口生命周期，加载首页 |
| EntryBackupAbility | BackupExtensionAbility | 处理应用数据备份与恢复 |

## 数据流

```
用户操作 → ArkUI Page (Index.ets)
              ↓
         UIAbility (EntryAbility.ets)
              ↓  onWindowStageCreate()
         windowStage.loadContent('pages/Index')
              ↓
         ArkUI 渲染引擎 → 屏幕显示
```

当前版本的页面为静态 "Hello World" 模板，通过 `@State` 管理组件内部状态（点击切换文案），不涉及外部数据源或跨组件通信。

## 模块结构

```
BrowserShell (应用)
  └── entry (HAP 模块)
       ├── main (主入口)
       │   ├── ets/entryability/     — UIAbility
       │   ├── ets/pages/            — 页面组件
       │   └── ets/entrybackupability/ — 扩展 Ability
       ├── ohosTest (集成测试)
       └── test (单元测试)
```

## 部署模型

```
DevEco Studio 编译
    ↓
HAP 包 (entry-default-signed.hap)
    ↓
hdc install → 模拟器 / 真机
    ↓
HarmonyOS 运行时加载
```

## 关键架构决策

1. **Stage 模型**: 使用 Stage 模型替代已废弃的 FA 模型，符合 HarmonyOS 官方推荐
2. **单模块结构**: 应用功能简单，使用单一 entry 模块，避免过度工程化
3. **声明式 UI**: 全部使用 ArkUI 声明式组件，无需命令式 DOM 操作
4. **hilog 日志**: 使用系统 hilog 替代 console.log，支持生产环境日志过滤
