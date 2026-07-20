# BrowserShell 目录结构

> 最后更新: 2026-07-20
> 项目: BrowserShell (浏览器壳)

## 完整目录树

```
BrowserShell/
├── .gitignore                          # Git 忽略配置
├── .hvigor/                            # hvigor 构建缓存
├── .idea/                              # IDE 配置 (DevEco Studio)
├── .codegraph/                         # 代码知识图谱索引
├── .omo/                               # 工作流计划目录
│
├── AppScope/                           # 应用全局配置
│   ├── app.json5                       # 应用级配置 (bundleName, version, icon, label)
│   └── resources/
│       └── base/
│           ├── element/
│           │   └── string.json         # 应用名: "BrowserShell"
│           └── media/
│               ├── layered_image.json  # 分层图标配置
│               ├── foreground.png      # 前台图标
│               └── background.png      # 后台图标
│
├── entry/                              # 主入口模块 (HAP)
│   ├── .gitignore                      # 模块级 Git 忽略
│   ├── build-profile.json5             # 模块构建配置 (Stage 模式, 混淆规则)
│   ├── hvigorfile.ts                   # 模块 hvigor 构建入口
│   ├── oh-package.json5                # 模块依赖声明
│   ├── obfuscation-rules.txt           # 混淆规则文件
│   │
│   └── src/
│       ├── main/                       # 主源码
│       │   ├── module.json5            # 模块清单 (Ability 声明, 页面路由, 权限)
│       │   ├── ets/                    # ArkTS 源代码
│       │   │   ├── entryability/
│       │   │   │   └── EntryAbility.ets        # 主 UIAbility 入口
│       │   │   ├── entrybackupability/
│       │   │   │   └── EntryBackupAbility.ets   # 备份恢复扩展 Ability
│       │   │   └── pages/
│       │   │       └── Index.ets               # 首页 (Hello World)
│       │   └── resources/              # 模块资源
│       │       ├── base/
│       │       │   ├── element/
│       │       │   │   ├── string.json  # 模块字符串
│       │       │   │   ├── color.json   # 颜色定义
│       │       │   │   └── float.json   # 浮点数值
│       │       │   ├── media/
│       │       │   │   ├── layered_image.json
│       │       │   │   ├── foreground.png
│       │       │   │   ├── background.png
│       │       │   │   └── startIcon.png       # 启动图标
│       │       │   └── profile/
│       │       │       ├── main_pages.json     # 页面路由清单
│       │       │       └── backup_config.json  # 备份配置
│       │       └── dark/
│       │           └── element/
│       │               └── color.json  # 暗色模式颜色
│       │
│       ├── ohosTest/                   # 集成测试 (on device)
│       │   ├── module.json5            # 测试模块清单
│       │   └── ets/test/
│       │       ├── Ability.test.ets    # Ability 集成测试
│       │       └── List.test.ets       # 列表测试
│       │
│       ├── test/                       # 单元测试 (local)
│       │   ├── LocalUnit.test.ets      # 本地单元测试
│       │   └── List.test.ets           # 列表示例测试
│       │
│       └── mock/
│           └── mock-config.json5       # Mock 数据配置
│
├── hvigor/                             # hvigor 构建工具配置
│   └── hvigor-config.json5             # hvigor 配置
│
├── build-profile.json5                 # 项目级构建配置 (SDK 版本, 产品定义)
├── hvigorfile.ts                       # 项目级 hvigor 构建入口
├── oh-package.json5                    # 项目级依赖清单
├── oh-package-lock.json5               # 依赖锁定
├── code-linter.json5                   # 代码检查配置
├── local.properties                    # 本地环境配置 (SDK/Node/JDK 路径)
│
├── specs/                              # 规范文档
│   ├── README.md                       # 文档索引导航
│   ├── SPECS_CHECKLIST.md              # 文档完成跟踪
│   ├── STRUCTURE.md                    # 本文件
│   ├── API.md                          # API 清单
│   ├── TECH.md                         # 技术选型
│   ├── ARCHITECTURE.md                 # 整体架构
│   ├── constitution.md                 # 宪法原则
│   ├── overall-spec.md                 # 整体规格
│   ├── overall-plan.md                 # 整体技术方案
│   ├── overall-data-model.md           # 数据模型
│   ├── overall-api.md                  # 对外接口
│   ├── overall-test-cases.md           # 测试用例索引
│   └── 001-browser-shell/              # 浏览器壳功能规格
│       ├── spec.md                     # 功能规格
│       ├── plan.md                     # 技术方案
│       ├── tasks.md                    # 任务分解
│       └── test-cases.md               # 测试用例
│
├── oh_modules/                         # 依赖包 (npm)
└── README.md                           # 项目 README
```

## 页面路由清单

| 路由路径 | 页面组件 | 文件路径 | 说明 |
|---------|---------|---------|------|
| `pages/Index` | `Index` | `entry/src/main/ets/pages/Index.ets` | 应用首页，当前为 Hello World 模板 |
