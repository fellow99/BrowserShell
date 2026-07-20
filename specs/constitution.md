# BrowserShell 项目宪法

> 最后更新: 2026-07-20

## 原则一：Stage 模型优先

- 所有 Ability MUST 使用 Stage 模型（UIAbility / ExtensionAbility）
- FA 模型（PageAbility）MUST NOT 使用
- 应用配置 MUST 使用 `module.json5`，NOT 已废弃的 `config.json`

## 原则二：ArkTS 类型安全

- 所有变量 MUST 有明确类型声明
- `any` 类型 MUST NOT 使用
- 类型断言 (`as`) MUST 避免，优先使用接口和类型守卫
- 动态属性访问 MUST NOT 使用，应使用 `Record` 类型

## 原则三：声明式 UI

- UI 构建 MUST 使用 ArkUI 声明式组件
- 复杂 build 方法 SHOULD 拆分为独立 `@Component`
- 组件状态 MUST 通过 V1 装饰器 (`@State` / `@Prop` / `@Link`) 管理

## 原则四：日志规范

- 生产日志 MUST 使用 `hilog`，NOT `console`
- 日志 TAG SHOULD 使用模块名标识
- 日志级别 MUST 合理使用 (info / warn / error)
- 敏感信息 MUST NOT 输出到日志

## 原则五：代码组织

- 页面组件 MUST 放在 `pages/` 目录
- 可复用组件 SHOULD 独立抽取到 `components/` 目录
- 业务逻辑 SHOULD 从 UI 组件中分离到独立的 service 层

## 原则六：测试覆盖

- 核心业务逻辑 MUST 有单元测试
- UI 交互 SHOULD 有集成测试（ohosTest）
- 测试框架 MUST 使用 `@ohos/hypium`

## 原则七：资源管理

- 字符串 MUST 引用 `$r('app.string.*')`，NOT 硬编码
- 颜色 SHOULD 引用 `$r('app.color.*')` 支持暗色模式
- 图标 SHOULD 使用分层图标 (layered_image) 支持主题自适应

## 原则八：提交规范

- 提交信息 MUST 遵循 Conventional Commits 格式
- 提交 MUST 包含结构化变更列表（中文，动词开头）
- Author MUST 标记 AI 工具身份（用于代码渗透率统计）
