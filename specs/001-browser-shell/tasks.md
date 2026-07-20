# 001-browser-shell 任务分解

> 对应规格: [spec.md](./spec.md)
> 对应方案: [plan.md](./plan.md)
> 最后更新: 2026-07-20

## 任务列表

| # | 任务 | 优先级 | 预估 | 状态 |
|---|------|--------|------|------|
| T-01 | EntryAbility: 配置全屏窗口模式 | 🔴 高 | 小 | pending |
| T-02 | Index.ets: 重写为浏览器主页面（Web + 浮动按钮 + URL 输入框） | 🔴 高 | 中 | pending |
| T-03 | Index.ets: 实现 URL 输入交互逻辑（展开/隐藏） | 🔴 高 | 小 | pending |
| T-04 | Index.ets: 实现 Web 组件 URL 加载与导航 | 🔴 高 | 小 | pending |
| T-05 | Index.ets: 实现 preferences 数据持久化（保存/读取 URL） | 🔴 高 | 中 | pending |
| T-06 | Index.ets: 实现启动时 URL 恢复逻辑 | 🔴 高 | 小 | pending |
| T-07 | 资源文件: 更新 string.json 添加字符串资源 | 🟡 中 | 小 | pending |
| T-08 | 测试: 编写单元测试（preferences 持久化） | 🟡 中 | 中 | pending |
| T-09 | 测试: 编写集成测试（UI 交互流程） | 🟡 中 | 中 | pending |
| T-10 | README.md: 完善项目 README | 🟡 中 | 小 | pending |

## 依赖关系

```
T-01 (全屏窗口)
  ↓
T-02 (主页面布局)
  ├── T-03 (URL 输入交互)
  ├── T-04 (Web 加载导航)
  └── T-05 (数据持久化)
        └── T-06 (启动恢复)
              ↓
T-07 (资源文件)
T-08 (单元测试)
T-09 (集成测试)
T-10 (README)
```

## 执行顺序

1. **第一批（并行）**: T-01, T-02 → 核心架构
2. **第二批（并行）**: T-03, T-04, T-05 → 功能实现
3. **第三批**: T-06 → 依赖 T-05 完成
4. **第四批（并行）**: T-07, T-08, T-09, T-10 → 收尾
