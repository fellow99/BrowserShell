/**
 * BrowserShell 常量定义。
 *
 * 集中放置偏好存储键名、空白页地址、响应式断点与「可忽略的加载错误」判定，
 * 避免魔法字符串与魔法数字散落在各模块。
 */

export class BrowserConstants {
  /** 偏好存储（preferences）实例名，用于持久化最近一次访问的 URL */
  public static readonly PREFERENCES_NAME: string = 'browser_shell';

  /** 偏好存储中最近一次访问 URL 的键 */
  public static readonly KEY_SAVED_URL: string = 'saved_url';

  /** 默认补全的协议前缀 */
  public static readonly HTTPS_SCHEME: string = 'https://';

  /** 未设置任何网址时浏览器组件加载的空白页 */
  public static readonly BLANK_PAGE: string = 'about:blank';

  /** 单条输入的最大长度（与 TextInput.maxLength 保持一致） */
  public static readonly MAX_URL_LENGTH: number = 2048;

  /** 紧凑布局断点（vp）：小于该宽度视为竖屏手机等紧凑场景 */
  public static readonly BREAKPOINT_COMPACT: number = 600;

  /** 宽屏断点（vp）：大于等于该宽度使用更窄（相对）的输入面板 */
  public static readonly BREAKPOINT_WIDE: number = 840;

  /**
   * 判定主文档加载错误是否属于「致命」错误。
   *
   * ArkWeb 的 onErrorReceive 会覆盖主文档与子资源两类请求，其中：
   *   - -3（ERR_ABORTED）：用户主动中断、重定向、下载触发的正常中断，不是故障；
   *   - 0：无错误码（部分转换场景），不应视为致命；
   * 其余错误码（如 -2 连接失败、-105 域名解析失败）才真正意味着主文档无法展示。
   *
   * @param errorCode ArkWeb 上报的错误码
   * @returns true 表示需要向用户展示错误提示
   */
  public static isFatalMainFrameError(errorCode: number): boolean {
    return errorCode !== 0 && errorCode !== -3;
  }
}
