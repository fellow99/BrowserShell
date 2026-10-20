import webview from '@ohos.web.webview';
import { preferences } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BrowserConstants } from '../common/BrowserConstants';
import { UrlHelper } from '../common/UrlHelper';
import { BrowserOverlay } from '../components/BrowserOverlay';

const DOMAIN: number = 0x0A02;
const TAG: string = 'BrowserShell';

interface SavedUrlRecord {
  url: string;
  savedAt: number;
}

/**
 * 浏览器壳主页面。
 *
 * 关键设计：
 *   - Web 组件常驻，不随加载状态卸载：加载错误只叠加提示层，
 *     避免「子资源 404 / 图片失败」这类错误把整个页面销毁；
 *   - onErrorReceive 区分主文档与子资源，并过滤 -3(ERR_ABORTED) 等非致命错误码，
 *     只有主文档真正无法展示时才进入错误态；
 *   - 系统返回键优先用于 ArkWeb 历史回退（面板展开时先收起面板），
 *     无历史可退时才交还系统（应用退到后台）；
 *   - 导航统一走 WebviewController.loadUrl，失败可原地重试。
 */
@Entry
@Component
struct Index {
  private controller: webview.WebviewController = new webview.WebviewController();
  @State bootReady: boolean = false;
  @State webSrc: string = BrowserConstants.BLANK_PAGE;
  @State currentUrl: string = '';
  @State editorVisible: boolean = false;
  @State showPageError: boolean = false;
  @State pageErrorDetail: string = '';
  private controllerAttached: boolean = false;
  private pendingUrl: string = '';
  private dataPreferences: preferences.Preferences | null = null;
  private hostContext: common.Context | null = null;

  aboutToAppear(): void {
    const uiContext = this.getUIContext();
    const ctx = uiContext.getHostContext();
    if (ctx) {
      this.hostContext = ctx;
      this.initAndLoad();
    } else {
      hilog.error(DOMAIN, TAG, 'Host context unavailable, showing address panel');
      this.bootReady = true;
      this.editorVisible = true;
    }
  }

  aboutToDisappear(): void {
    try {
      this.controller.stop();
      hilog.info(DOMAIN, TAG, 'WebviewController stopped');
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to stop controller: %{public}s', JSON.stringify(error));
    }
  }

  /**
   * 启动流程：读取上次确认的地址 -> 决定首屏是「加载该地址」还是「展开地址面板」。
   * 只有解析完成后才渲染 Web，保证首屏 src 与地址面板状态一致。
   */
  private async initAndLoad(): Promise<void> {
    let restored: string = '';
    try {
      if (this.hostContext !== null) {
        this.dataPreferences =
          await preferences.getPreferences(this.hostContext, BrowserConstants.PREFERENCES_NAME);
        const saved: preferences.ValueType =
          await this.dataPreferences.get(BrowserConstants.KEY_SAVED_URL, '');
        if (typeof saved === 'string' && saved.length > 0) {
          restored = Index.parseSavedUrl(saved);
        }
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to load saved URL: %{public}s', JSON.stringify(error));
    }

    if (UrlHelper.isRestorable(restored)) {
      this.currentUrl = restored;
      this.webSrc = restored;
      this.editorVisible = false;
      hilog.info(DOMAIN, TAG, 'Restored URL: %{public}s', restored);
    } else {
      this.currentUrl = '';
      this.webSrc = BrowserConstants.BLANK_PAGE;
      this.editorVisible = true;
      hilog.info(DOMAIN, TAG, 'No usable saved URL, showing address panel');
    }
    this.bootReady = true;
  }

  /**
   * 解析持久化的地址记录，兼容两种历史格式：
   *   - `{"url":"...","savedAt":...}`（当前格式）
   *   - 直接存放 URL 字符串（早期格式）
   */
  private static parseSavedUrl(raw: string): string {
    if (!raw.startsWith('{')) {
      return raw.trim();
    }
    try {
      const record: SavedUrlRecord = JSON.parse(raw);
      if (typeof record.url === 'string') {
        return record.url;
      }
      return '';
    } catch (error) {
      hilog.warn(DOMAIN, TAG, 'Malformed saved record: %{public}s', JSON.stringify(error));
      return '';
    }
  }

  /** 持久化最近一次确认的地址 */
  private async saveUrl(url: string): Promise<void> {
    if (!this.dataPreferences) {
      hilog.warn(DOMAIN, TAG, 'Preferences not initialized, skipping save');
      return;
    }
    try {
      const record: SavedUrlRecord = { url: url, savedAt: Date.now() };
      await this.dataPreferences.put(BrowserConstants.KEY_SAVED_URL, JSON.stringify(record));
      await this.dataPreferences.flush();
      hilog.info(DOMAIN, TAG, 'Saved URL: %{public}s', url);
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'Failed to save URL: %{public}s', JSON.stringify(error));
    }
  }

  /** 展开地址面板（由覆盖层按钮触发；面板自行用当前地址预填并请求焦点） */
  private openEditor(): void {
    this.editorVisible = true;
  }

  /** 收起地址面板，不改变已保存的地址 */
  private closeEditor(): void {
    this.editorVisible = false;
  }

  /** 用户确认了一个合法地址：持久化 + 收起面板 + 导航 */
  private navigate(url: string): void {
    this.clearPageError();
    this.currentUrl = url;
    this.editorVisible = false;
    this.saveUrl(url);
    this.loadUrl(url);
  }

  /** 统一的导航入口：控制器未就绪时先入队，就绪后再加载 */
  private loadUrl(url: string): void {
    if (!this.controllerAttached) {
      this.pendingUrl = url;
      hilog.info(DOMAIN, TAG, 'Controller not attached yet, queue URL: %{public}s', url);
      return;
    }
    try {
      this.controller.loadUrl(url);
      hilog.info(DOMAIN, TAG, 'loadUrl: %{public}s', url);
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'loadUrl failed: %{public}s', JSON.stringify(error));
      this.showPageError = true;
      this.pageErrorDetail = '';
    }
  }

  private onControllerAttached(): void {
    this.controllerAttached = true;
    hilog.info(DOMAIN, TAG, 'Controller attached');
    if (this.pendingUrl.length > 0) {
      const url: string = this.pendingUrl;
      this.pendingUrl = '';
      this.loadUrl(url);
    }
  }

  /**
   * 页面开始加载：同步地址。
   *
   * 这里刻意不清除加载错误提示：主文档失败后 ArkWeb 仍会渲染自己的错误页并再次触发
   * onPageBegin，若在此清除，刚弹出的错误提示会被错误页自身立刻抹掉。
   * 错误提示只在用户主动动作（确认新地址、重试、历史回退成功）时清除。
   */
  private onPageBegin(url: string): void {
    const displayUrl: string = UrlHelper.toDisplayUrl(url);
    this.currentUrl = displayUrl;
    hilog.info(DOMAIN, TAG, 'Page begin: %{public}s', displayUrl);
  }

  /** 清除加载错误提示 */
  private clearPageError(): void {
    this.showPageError = false;
    this.pageErrorDetail = '';
  }

  /**
   * 资源加载错误回调（修复点）：
   *   - 子资源（图片 / 脚本 / 样式 / 字体等）失败只记录日志，不影响页面；
   *   - 主文档的 -3(ERR_ABORTED)、0 等错误码属于正常中断，同样不进入错误态；
   *   - 只有主文档真正失败时才叠加错误提示，且不卸载 Web 组件。
   */
  private handleResourceError(isMainFrame: boolean, errorCode: number, errorInfo: string,
    url: string): void {
    if (!isMainFrame) {
      hilog.warn(DOMAIN, TAG, 'Subresource load error ignored: code=%{public}d, url=%{public}s',
        errorCode, url);
      return;
    }
    if (!BrowserConstants.isFatalMainFrameError(errorCode)) {
      hilog.info(DOMAIN, TAG, 'Non-fatal main frame error ignored: code=%{public}d, url=%{public}s',
        errorCode, url);
      return;
    }
    hilog.error(DOMAIN, TAG, 'Main frame load failed: code=%{public}d, info=%{public}s, url=%{public}s',
      errorCode, errorInfo, url);
    this.pageErrorDetail = errorInfo.length > 0 ? `${errorInfo} (${errorCode})` : '';
    this.showPageError = true;
  }

  /** 重试当前地址 */
  private retry(): void {
    this.clearPageError();
    if (this.currentUrl.length > 0) {
      this.loadUrl(this.currentUrl);
      return;
    }
    hilog.info(DOMAIN, TAG, 'Nothing to retry, opening address panel');
    this.editorVisible = true;
  }

  /** 尝试让 ArkWeb 历史回退；无历史或控制器未就绪时返回 false */
  private goBackInHistory(): boolean {
    if (!this.controllerAttached) {
      return false;
    }
    try {
      if (!this.controller.accessBackward()) {
        return false;
      }
      this.controller.backward();
      // 回退是用户主动动作：离开失败页面后清掉错误提示
      this.clearPageError();
      hilog.info(DOMAIN, TAG, 'Webview went backward in history');
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, 'backward failed: %{public}s', JSON.stringify(error));
      return false;
    }
  }

  /**
   * 系统返回键：先收面板，再让网页回退；都不可用时交还系统（应用退到后台）。
   * 返回值 true 表示事件已被消费，应用不退出。
   */
  onBackPress(): boolean {
    if (this.editorVisible) {
      hilog.info(DOMAIN, TAG, 'Back pressed: closing address panel');
      this.closeEditor();
      return true;
    }
    if (this.goBackInHistory()) {
      return true;
    }
    hilog.info(DOMAIN, TAG, 'Back pressed: no web history left, fall through to system');
    return false;
  }

  build() {
    Stack() {
      if (!this.bootReady) {
        // 启动期占位，避免 Web 组件以错误的 src 首帧创建
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor($r('app.color.page_background'))
      } else {
        Web({ src: this.webSrc, controller: this.controller })
          .width('100%')
          .height('100%')
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .onControllerAttached(() => {
            this.onControllerAttached();
          })
          .onPageBegin((event: OnPageBeginEvent) => {
            this.onPageBegin(event.url);
          })
          .onErrorReceive((event: OnErrorReceiveEvent) => {
            this.handleResourceError(event.request.isMainFrame(), event.error.getErrorCode(),
              event.error.getErrorInfo(), event.request.getRequestUrl());
          })
          .onHttpErrorReceive((event: OnHttpErrorReceiveEvent) => {
            // HTTP 4xx/5xx 由服务端页面自行呈现，不作为致命错误处理
            hilog.warn(DOMAIN, TAG, 'HTTP error ignored: status=%{public}d, url=%{public}s',
              event.response.getResponseCode(), event.request.getRequestUrl());
          })

        // 空页面提示：没有可展示的网址且未展开面板时给出引导
        if (this.currentUrl.length === 0 && !this.showPageError) {
          Column() {
            Text($r('app.string.empty_page_hint'))
              .fontSize(16)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .hitTestBehavior(HitTestMode.Transparent)
        }

        // 主文档加载失败提示：叠加在 Web 之上，不销毁 Web
        if (this.showPageError) {
          Column({ space: 12 }) {
            Text($r('app.string.load_error_hint'))
              .fontSize(17)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
            if (this.pageErrorDetail.length > 0) {
              Text(this.pageErrorDetail)
                .fontSize(12)
                .fontColor($r('app.color.text_placeholder'))
                .textAlign(TextAlign.Center)
            }
            Button($r('app.string.retry_button'))
              .type(ButtonType.Capsule)
              .height(38)
              .padding({ left: 24, right: 24 })
              .fontSize(14)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.brand_gradient_end'))
              .margin({ top: 4 })
              .onClick(() => {
                this.retry();
              })
          }
          .width('100%')
          .height('100%')
          .padding({ left: 24, right: 24 })
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('app.color.page_background'))
        }

        // 底部浮动入口按钮 + 地址输入面板
        BrowserOverlay({
          editorVisible: this.editorVisible,
          currentUrl: this.currentUrl,
          onOpenRequest: () => {
            this.openEditor();
          },
          onCloseRequest: () => {
            this.closeEditor();
          },
          onNavigate: (url: string) => {
            this.navigate(url);
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
