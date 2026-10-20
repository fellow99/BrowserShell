# 001-browser-shell 技术方案

> 对应规格: [spec.md](./spec.md)
> 最后更新: 2026-07-20

## 1. 技术上下文

### 1.1 运行时环境

| 项目 | 说明 |
|------|------|
| 操作系统 | HarmonyOS 6.1.1 (API 24) |
| 兼容版本 | 6.0.0 (API 20) |
| 设备类型 | phone, tablet |
| UI 框架 | ArkUI |
| 状态管理 | V1 装饰器 (@State) |

### 1.2 直接依赖

| 包 | 用途 |
|------|------|
| @kit.ArkUI | Web 组件、窗口全屏 API |
| @kit.ArkData | preferences 数据持久化 |
| @kit.AbilityKit | UIAbility 生命周期 |
| @kit.PerformanceAnalysisKit | hilog 日志 |

## 2. 宪法合规

| 原则 | 状态 | 说明 |
|------|------|------|
| Stage 模型 | ✅ | 使用 UIAbility |
| 类型安全 | ✅ | 明确类型声明 |
| 声明式 UI | ✅ | ArkUI @Component + @State |
| 日志规范 | ✅ | 使用 hilog |
| 代码组织 | ✅ | 页面/组件分离 |
| 测试覆盖 | ⚠️ | 需新增功能测试用例 |
| 资源管理 | ✅ | 使用 $r() 引用资源 |

## 3. 数据结构

### URL 存储模型

```typescript
// Preferences 存储格式
interface SavedUrlRecord {
  url: string;
  savedAt: number;  // Date.now()
}
// 存储键: 'saved_url'
// 存储值: JSON.stringify(SavedUrlRecord)
```

### 页面状态模型

```typescript
// Index.ets 组件状态
@State currentUrl: string = '';
@State showUrlInput: boolean = false;
@State isLoading: boolean = false;
inputUrl: string = '';  // TextInput 绑定的临时输入值
```

## 4. 接口契约

### 4.1 EntryAbility → 全屏窗口

```typescript
// EntryAbility.onWindowStageCreate()
windowStage.getMainWindow().then((windowClass) => {
  windowClass.setWindowLayoutFullScreen(true);  // 隐藏状态栏和导航栏
});
```

### 4.2 Index 页面 → Preferences

```typescript
// 读取
const prefs = await dataPreferences.getPreferences(context, 'browser_shell');
const saved = await prefs.get('saved_url', '');

// 写入
await prefs.put('saved_url', JSON.stringify({ url, savedAt: Date.now() }));
await prefs.flush();
```

## 5. 实现策略

### 5.1 页面架构

```
Index.ets (主页面)
├── Stack 布局（全屏）
│   ├── Web 组件（底层，100% 宽高）
│   ├── FloatingActionButton（左下角，绝对定位）
│   └── URL 输入面板（底部，条件渲染）
```

### 5.2 全屏实现

在 `EntryAbility.ets` 的 `onWindowStageCreate()` 中调用：
```typescript
windowStage.getMainWindow().then((win) => {
  win.setWindowLayoutFullScreen(true);
});
```

### 5.3 Web 组件使用

```typescript
// ArkUI Web 组件
Web({ src: this.currentUrl, controller: this.webController })
  .width('100%')
  .height('100%')
  .javaScriptAccess(true)
  .domStorageAccess(true)
```

### 5.4 浮动按钮

使用 `Stack` 布局 + `Position` 属性实现：
```typescript
Button() { /* 浮动按钮图标 */ }
  .position({ x: 16, y: 'calc(100% - 72vp)' })
  .onClick(() => { this.showUrlInput = true; })
```

### 5.5 关键算法

**启动时 URL 恢复逻辑**:
```
aboutToAppear() →
  getPreferences() →
    prefs.get('saved_url') →
      有值: parse JSON → this.currentUrl = url → Web 自动加载
      无值: this.showUrlInput = true → 显示输入框
```

### 5.6 错误处理

- preferences 读取失败: 降级为显示空页面 + URL 输入框
- Web 组件加载失败: ArkUI Web 组件自身提供错误页面
- 无效 URL 输入: 添加 URL 格式校验，提示用户

## 6. 文件变更清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `entry/src/main/ets/entryability/EntryAbility.ets` | 修改 | 添加全屏窗口设置 |
| `entry/src/main/ets/pages/Index.ets` | 重写 | 实现浏览器壳主页面 |
| `entry/src/main/resources/base/element/string.json` | 修改 | 添加页面字符串资源 |

## 7. 测试策略

| 测试项 | 方法 | 验证点 |
|--------|------|--------|
| URL 持久化 | 单元测试 | 读写 preferences 正确 |
| 全屏显示 | 集成测试 | 窗口属性设置正确 |
| URL 输入交互 | 集成测试 | 按钮点击 → 输入框展开 → 确认加载 |
| 启动恢复 | 集成测试 | 重启后 URL 正确恢复 |
