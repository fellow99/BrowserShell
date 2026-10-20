/**
 * 浏览器壳控制层：左下角浮动入口按钮 + 底部地址输入面板。
 *
 * 设计约束（对齐参考工程 ElectronShell 的 ShellOverlay）：
 *   - 本组件是覆盖在 ArkWeb 内容之上的「薄」控制层，根节点使用
 *     HitTestMode.Transparent，空白区域不拦截触摸，网页仍可正常交互；
 *   - 组件只负责「取输入、做规整与就地校验、回调父组件」，
 *     真正的导航、持久化与加载错误处理由 pages/Index 承担；
 *   - 布局按窗口宽度分紧凑（手机竖屏）/ 常规（平板）/ 宽屏（2in1）三档，
 *     监听 windowSizeChange，横竖屏切换自动重排。
 */

import window from '@ohos.window';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { BrowserConstants } from '../common/BrowserConstants';
import { UrlHelper } from '../common/UrlHelper';

const DOMAIN: number = 0x0A03;
const TAG: string = 'BrowserOverlay';
const INPUT_ID: string = 'browserUrlInput';
const PANEL_WIDTH_COMPACT: string = '100%';
const PANEL_WIDTH_NORMAL: string = '68%';
const PANEL_WIDTH_WIDE: string = '46%';

@Component
export struct BrowserOverlay {
  /** 输入面板是否展开（由父组件持有，便于系统返回键统一处理） */
  @Prop @Watch('onEditorVisibilityChange') editorVisible: boolean = false;
  /** 当前页面地址，用于展开面板时预填 */
  @Prop currentUrl: string = '';
  /** 用户确认了一个合法地址 */
  onNavigate: (url: string) => void = () => {
  };
  /** 用户要求收起面板 */
  onCloseRequest: () => void = () => {
  };
  /** 用户要求展开面板 */
  onOpenRequest: () => void = () => {
  };

  @State private inputText: string = '';
  @State private inputError: boolean = false;
  @State private compact: boolean = false;
  @State private panelWidth: string = PANEL_WIDTH_NORMAL;
  private hostWindow: window.Window | undefined = undefined;
  private sizeListener: Callback<window.Size> | undefined = undefined;
  private disposed: boolean = false;

  aboutToAppear(): void {
    this.attachSizeListener();
  }

  aboutToDisappear(): void {
    this.disposed = true;
    this.detachSizeListener();
  }

  /** 面板展开时用当前地址预填，并请求输入焦点 */
  onEditorVisibilityChange(propName: string): void {
    hilog.info(DOMAIN, TAG, 'editorVisible -> %{public}s', propName);
    if (!this.editorVisible) {
      this.inputError = false;
      return;
    }
    this.inputText = this.currentUrl;
    this.inputError = false;
    // 面板为条件渲染，节点创建后再请求焦点
    setTimeout(() => this.requestInputFocus(), 0);
  }

  /** 监听窗口尺寸变化，驱动紧凑 / 常规 / 宽屏三档响应式布局 */
  private attachSizeListener(): void {
    const hostContext: common.Context | undefined = this.getUIContext().getHostContext();
    if (hostContext === undefined) {
      hilog.warn(DOMAIN, TAG, 'host context unavailable, keep default layout');
      return;
    }
    window.getLastWindow(hostContext).then((win: window.Window) => {
      if (this.disposed) {
        // 组件已在 promise 兑现前销毁：不再注册监听，避免泄漏
        return;
      }
      this.hostWindow = win;
      this.applyWidth(win.getWindowProperties().windowRect.width);
      this.sizeListener = (size: window.Size): void => {
        this.applyWidth(size.width);
      };
      try {
        win.on('windowSizeChange', this.sizeListener);
      } catch (error) {
        hilog.error(DOMAIN, TAG, 'register windowSizeChange failed: %{public}s', JSON.stringify(error));
      }
    }).catch((error: BusinessError) => {
      hilog.error(DOMAIN, TAG, 'getLastWindow failed, code=%{public}d, message=%{public}s',
        error.code, error.message);
    });
  }

  private detachSizeListener(): void {
    if (this.sizeListener === undefined) {
      return;
    }
    if (this.hostWindow !== undefined) {
      try {
        this.hostWindow.off('windowSizeChange', this.sizeListener);
      } catch (error) {
        hilog.error(DOMAIN, TAG, 'unregister windowSizeChange failed: %{public}s', JSON.stringify(error));
      }
    }
    this.sizeListener = undefined;
    this.hostWindow = undefined;
  }

  private applyWidth(widthPx: number): void {
    if (widthPx <= 0) {
      return;
    }
    const widthVp: number = this.getUIContext().px2vp(widthPx);
    this.compact = widthVp < BrowserConstants.BREAKPOINT_COMPACT;
    if (this.compact) {
      this.panelWidth = PANEL_WIDTH_COMPACT;
    } else if (widthVp < BrowserConstants.BREAKPOINT_WIDE) {
      this.panelWidth = PANEL_WIDTH_NORMAL;
    } else {
      this.panelWidth = PANEL_WIDTH_WIDE;
    }
  }

  /**
   * 让输入框获得焦点。
   * defaultFocus 只在页面首次获焦时生效，动态展开的面板必须显式请求焦点。
   */
  private requestInputFocus(): void {
    try {
      this.getUIContext().getFocusController().requestFocus(INPUT_ID);
    } catch (error) {
      hilog.warn(DOMAIN, TAG, 'requestFocus failed: %{public}s', JSON.stringify(error));
    }
  }

  /** 确认输入：规整 -> 校验 -> 交给父组件导航；非法输入就地提示、不跳转 */
  private submit(): void {
    const url: string = UrlHelper.normalize(this.inputText);
    if (!UrlHelper.isSupported(url)) {
      this.inputError = true;
      hilog.warn(DOMAIN, TAG, 'reject unsupported url: %{public}s', this.inputText);
      return;
    }
    this.inputError = false;
    this.inputText = url;
    this.onNavigate(url);
  }

  build() {
    Column() {
      if (!this.editorVisible) {
        this.FloatingButton()
      }
      if (this.editorVisible) {
        this.UrlPanel()
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)
    .hitTestBehavior(HitTestMode.Transparent)
  }

  /** 左下角浮动入口按钮 */
  @Builder
  FloatingButton() {
    Stack() {
      Text($r('app.string.fab_label'))
        .fontSize(this.compact ? 10 : 11)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .letterSpacing(0.6)
    }
    .width(this.compact ? 46 : 52)
    .height(this.compact ? 46 : 52)
    .borderRadius(this.compact ? 23 : 26)
    .linearGradient({
      angle: 135,
      colors: [[$r('app.color.brand_gradient_start'), 0.0], [$r('app.color.brand_gradient_end'), 1.0]]
    })
    .shadow({ radius: 18, color: $r('app.color.fab_shadow'), offsetX: 0, offsetY: 6 })
    .margin({ left: this.compact ? 16 : 24, bottom: this.compact ? 18 : 24 })
    .alignSelf(ItemAlign.Start)
    .onClick(() => {
      this.onOpenRequest();
    })
  }

  /** 底部地址输入面板 */
  @Builder
  UrlPanel() {
    Row() {
      Column({ space: this.compact ? 6 : 8 }) {
        Row({ space: this.compact ? 8 : 10 }) {
          TextInput({ text: this.inputText, placeholder: $r('app.string.url_placeholder') })
            .id(INPUT_ID)
            .layoutWeight(1)
            .height(this.compact ? 38 : 40)
            .fontSize(this.compact ? 14 : 15)
            .fontColor($r('app.color.text_primary'))
            .backgroundColor(Color.Transparent)
            .placeholderColor($r('app.color.text_placeholder'))
            .caretColor($r('app.color.brand_gradient_end'))
            .enterKeyType(EnterKeyType.Go)
            .maxLines(1)
            .maxLength(BrowserConstants.MAX_URL_LENGTH)
            .onAppear(() => {
              // 面板节点挂载后再请求焦点，避免 setTimeout 抢在渲染之前（见 onEditorVisibilityChange）
              this.requestInputFocus();
            })
            .onChange((value: string) => {
              this.inputText = value;
              this.inputError = false;
            })
            .onSubmit(() => {
              this.submit();
            })

          Button($r('app.string.go_button'))
            .type(ButtonType.Capsule)
            .height(this.compact ? 32 : 34)
            .padding({ left: this.compact ? 12 : 16, right: this.compact ? 12 : 16 })
            .fontSize(this.compact ? 13 : 14)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.brand_gradient_end'))
            .onClick(() => {
              this.submit();
            })

          Text($r('app.string.close_button'))
            .fontSize(this.compact ? 15 : 16)
            .fontColor($r('app.color.text_secondary'))
            .padding(6)
            .onClick(() => {
              this.onCloseRequest();
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        if (this.inputError) {
          Text($r('app.string.invalid_url_hint'))
            .fontSize(12)
            .fontColor($r('app.color.text_error'))
            .width('100%')
            .textAlign(TextAlign.Start)
        }
      }
      .width(this.panelWidth)
      .constraintSize({ maxWidth: 760 })
      .padding({
        left: this.compact ? 12 : 16,
        right: this.compact ? 8 : 12,
        top: this.compact ? 8 : 10,
        bottom: this.compact ? 8 : 10
      })
      .borderRadius(this.compact ? 20 : 22)
      .backgroundColor($r('app.color.panel_background'))
      .border({ width: 1, color: $r('app.color.panel_border') })
      .shadow({ radius: 24, color: $r('app.color.panel_shadow'), offsetX: 0, offsetY: 8 })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({
      left: this.compact ? 4 : 16,
      right: this.compact ? 4 : 16,
      bottom: this.compact ? 14 : 20
    })
    .transition(TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: 24 })))
  }
}
