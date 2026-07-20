# BrowserShell 数据模型

> 最后更新: 2026-07-20

## 1. 实体定义

### 1.1 URL 存储

用户访问的 URL 记录，保存到本地 Preferences 存储。

| 属性 | 类型 | 说明 |
|------|------|------|
| url | string | 用户输入的完整 URL |
| savedAt | number | 保存时间戳 (毫秒) |

**存储方式**: `preferences` (键值对)

**存储键**: `saved_url`

**存储格式**: JSON 字符串 `{ "url": "...", "savedAt": 1234567890 }`

### 1.2 浏览器状态（内存）

| 属性 | 类型 | 说明 |
|------|------|------|
| currentUrl | string | 当前加载的 URL |
| isLoading | boolean | 是否正在加载 |
| showUrlInput | boolean | 是否显示 URL 输入框 |

## 2. 状态流转

### URL 输入状态机

```
[初始] ──无存储 URL──▶ [显示空白页 + URL 输入框]
   │
   └──有存储 URL──────▶ [加载 URL]
                            │
                    点击浮动按钮
                            │
                            ▼
                     [展开 URL 输入框]
                            │
                     用户确认 URL
                            │
                            ▼
                     [加载新 URL + 隐藏输入框 + 保存 URL]
```

### 组件状态 (Index 页面)

```typescript
interface BrowserState {
  currentUrl: string;        // 当前加载的 URL
  isLoading: boolean;        // 页面加载状态
  showUrlInput: boolean;     // URL 输入框显隐
  inputUrl: string;          // 输入框中暂存的 URL
}
```

## 3. 存储操作

| 操作 | 方法 | 触发时机 |
|------|------|----------|
| 读取 URL | preferences.get('saved_url') | 应用启动 / 页面 aboutToAppear |
| 写入 URL | preferences.put('saved_url', value) | 用户确认 URL 输入后 |
| 删除 URL | preferences.delete('saved_url') | 可选：清除历史时 |
| 持久化 | preferences.flush() | 写入操作后 |
