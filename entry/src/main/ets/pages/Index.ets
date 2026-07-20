import { webview } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';

const DOMAIN = 0x0A02;
const TAG = 'BrowserShell';
const STORE_NAME = 'browser_shell';
const KEY_SAVED_URL = 'saved_url';

interface SavedUrlRecord {
  url: string;
  savedAt: number;
}

@Entry
@Component
struct Index {
  controller: webview.WebviewController = new webview.WebviewController();
  @State currentUrl: string = '';
  @State showUrlInput: boolean = false;
  @State isLoading: boolean = false;
  @State hasError: boolean = false;
  inputUrl: string = '';
  private dataPreferences: preferences.Preferences | null = null;
  private hostContext: common.Context | null = null;

  aboutToAppear(): void {
    const uiContext = this.getUIContext();
    const ctx = uiContext.getHostContext();
    if (ctx) {
      this.hostContext = ctx;
      this.initAndLoad();
    } else {
      hilog.error(DOMAIN, TAG, 'Host context unavailable, showing input');
      this.showUrlInput = true;
    }
  }

  aboutToDisappear(): void {
    try {
      this.controller.stop();
      hilog.info(DOMAIN, TAG, 'WebviewController stopped');
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to stop controller: %{public}s', JSON.stringify(err));
    }
  }

  /**
   * Initialize preferences storage and load saved URL on startup.
   */
  private async initAndLoad(): Promise<void> {
    try {
      this.dataPreferences = await preferences.getPreferences(this.hostContext!, STORE_NAME);
      const saved: preferences.ValueType = await this.dataPreferences.get(KEY_SAVED_URL, '');
      if (typeof saved === 'string' && saved.length > 0) {
        const record: SavedUrlRecord = JSON.parse(saved);
        this.currentUrl = record.url;
        hilog.info(DOMAIN, TAG, 'Restored URL: %{public}s', record.url);
      } else {
        this.showUrlInput = true;
        hilog.info(DOMAIN, TAG, 'No saved URL found, showing input');
      }
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to load saved URL: %{public}s', JSON.stringify(err));
      this.showUrlInput = true;
    }
  }

  /**
   * Save a URL to preferences storage.
   */
  private async saveUrl(url: string): Promise<void> {
    if (!this.dataPreferences) {
      hilog.warn(DOMAIN, TAG, 'Preferences not initialized, skipping save');
      return;
    }
    try {
      const record: SavedUrlRecord = { url: url, savedAt: Date.now() };
      await this.dataPreferences.put(KEY_SAVED_URL, JSON.stringify(record));
      await this.dataPreferences.flush();
      hilog.info(DOMAIN, TAG, 'Saved URL: %{public}s', url);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to save URL: %{public}s', JSON.stringify(err));
    }
  }

  /**
   * Navigate to the URL entered by the user.
   * Adds https:// prefix if no protocol is specified.
   */
  private navigateToUrl(): void {
    const trimmedUrl: string = this.inputUrl.trim();
    if (!trimmedUrl) {
      return;
    }

    let fullUrl: string = trimmedUrl;
    if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) {
      fullUrl = 'https://' + trimmedUrl;
    }

    this.hasError = false;
    this.currentUrl = fullUrl;
    this.showUrlInput = false;
    this.saveUrl(fullUrl);
    hilog.info(DOMAIN, TAG, 'Navigating to: %{public}s', fullUrl);
  }

  /**
   * Handle the floating button click — show URL input panel with current URL pre-filled.
   */
  private onFabClick(): void {
    this.inputUrl = this.currentUrl;
    this.showUrlInput = true;
  }

  build() {
    Column() {
      // Main content area: WebView + floating button overlay
      Stack() {
        // WebView — fills the content area when a URL is loaded
        if (this.currentUrl && !this.hasError) {
          Web({ src: this.currentUrl, controller: this.controller })
            .width('100%')
            .height('100%')
            .javaScriptAccess(true)
            .domStorageAccess(true)
            .onErrorReceive((event) => {
              if (event) {
                hilog.error(DOMAIN, TAG, 'WebView error: %{public}s', JSON.stringify(event));
                this.hasError = true;
              }
            })
        }

        // Error state — shown when WebView encounters an error
        if (this.hasError) {
          Column() {
            Text($r('app.string.load_error_hint'))
              .fontSize(18)
              .fontColor('#999999')
              .margin({ bottom: 16 })
            Button($r('app.string.retry_button'))
              .width(120)
              .height(44)
              .borderRadius(22)
              .backgroundColor('#1a73e8')
              .fontColor(Color.White)
              .onClick(() => {
                this.hasError = false;
                const retryUrl = this.currentUrl;
                this.currentUrl = '';
                this.currentUrl = retryUrl;
              })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }

        // Empty state — shown when no URL is loaded and input is not displayed
        if (!this.currentUrl && !this.showUrlInput && !this.hasError) {
          Column() {
            Text($r('app.string.empty_page_hint'))
              .fontSize(18)
              .fontColor('#999999')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }

        // Floating action button — bottom-left corner, visible when input is hidden
        if (!this.showUrlInput) {
          Button() {
            Text($r('app.string.fab_label'))
              .fontSize(24)
          }
          .width(48)
          .height(48)
          .borderRadius(24)
          .backgroundColor('#1a73e8')
          .position({ x: 16, y: '100%' })
          .translate({ x: 0, y: -72 })
          .shadow({ radius: 8, color: '#40000000', offsetX: 0, offsetY: 2 })
          .onClick(() => {
            this.onFabClick();
          })
        }
      }
      .layoutWeight(1)
      .width('100%')

      // URL input panel — slides up from bottom
      if (this.showUrlInput) {
        Column() {
          Row() {
            TextInput({ placeholder: $r('app.string.url_placeholder'), text: this.inputUrl })
              .layoutWeight(1)
              .height(48)
              .backgroundColor('#F0F0F0')
              .borderRadius(24)
              .padding({ left: 16, right: 16 })
              .enterKeyType(EnterKeyType.Go)
              .onChange((value: string) => {
                this.inputUrl = value;
              })
              .onSubmit(() => {
                this.navigateToUrl();
              })

            Button($r('app.string.go_button'))
              .width(64)
              .height(48)
              .borderRadius(24)
              .backgroundColor('#1a73e8')
              .fontColor(Color.White)
              .fontSize(16)
              .margin({ left: 8 })
              .onClick(() => {
                this.navigateToUrl();
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })

          Button($r('app.string.cancel_button'))
            .width('100%')
            .height(44)
            .backgroundColor(Color.Transparent)
            .fontColor('#666666')
            .fontSize(14)
            .margin({ top: 8, left: 16, right: 16 })
            .onClick(() => {
              this.showUrlInput = false;
            })
        }
        .width('100%')
        .padding({ top: 16, bottom: 24 })
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 16, topRight: 16 })
        .shadow({ radius: 16, color: '#20000000', offsetX: 0, offsetY: -4 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
