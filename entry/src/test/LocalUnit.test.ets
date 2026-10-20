import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { UrlHelper } from '../main/ets/common/UrlHelper';
import { BrowserConstants } from '../main/ets/common/BrowserConstants';

export default function localUnitTest() {
  describe('UrlHelperTest', () => {
    beforeAll(() => {
    });
    beforeEach(() => {
    });
    afterEach(() => {
    });
    afterAll(() => {
    });

    // 规整：省略协议自动补 https://
    it('normalize_addsHttpsScheme', 0, () => {
      expect(UrlHelper.normalize('www.baidu.com')).assertEqual('https://www.baidu.com');
      expect(UrlHelper.normalize('  example.com/path?q=1  ')).assertEqual('https://example.com/path?q=1');
    });

    // 规整：已带 scheme 的原样保留
    it('normalize_keepsExistingScheme', 0, () => {
      expect(UrlHelper.normalize('http://example.com')).assertEqual('http://example.com');
      expect(UrlHelper.normalize('https://example.com')).assertEqual('https://example.com');
    });

    // 规整：空输入返回空串
    it('normalize_emptyInput', 0, () => {
      expect(UrlHelper.normalize('')).assertEqual('');
      expect(UrlHelper.normalize('   ')).assertEqual('');
    });

    // 校验：合法地址
    it('isSupported_acceptsValidUrls', 0, () => {
      expect(UrlHelper.isSupported('https://www.baidu.com')).assertTrue();
      expect(UrlHelper.isSupported('http://192.168.1.1:8080/index.html')).assertTrue();
      expect(UrlHelper.isSupported('https://localhost')).assertTrue();
      expect(UrlHelper.isSupported('https://[::1]:8443')).assertTrue();
      expect(UrlHelper.isSupported('https://example.com.')).assertTrue();
      expect(UrlHelper.isSupported('https://user:pass@example.com/a')).assertTrue();
    });

    // 校验：非法地址不得放行
    it('isSupported_rejectsInvalidUrls', 0, () => {
      expect(UrlHelper.isSupported('')).assertFalse();
      expect(UrlHelper.isSupported('ftp://example.com')).assertFalse();
      expect(UrlHelper.isSupported('https://')).assertFalse();
      expect(UrlHelper.isSupported('https://exa mple.com')).assertFalse();
      expect(UrlHelper.isSupported('https://a.comhttps://b.com')).assertFalse();
      expect(UrlHelper.isSupported('https://example.com:70000')).assertFalse();
      expect(UrlHelper.isSupported('https://256.1.1.1')).assertFalse();
      expect(UrlHelper.isSupported('https://example')).assertFalse();
    });

    // 恢复场景：只有合法非空地址才可直接复用
    it('isRestorable_checksSavedUrl', 0, () => {
      expect(UrlHelper.isRestorable('')).assertFalse();
      expect(UrlHelper.isRestorable('about:blank')).assertFalse();
      expect(UrlHelper.isRestorable('https://www.baidu.com')).assertTrue();
    });

    // 展示地址：空白页视为「未访问」
    it('toDisplayUrl_hidesBlankPage', 0, () => {
      expect(UrlHelper.toDisplayUrl(BrowserConstants.BLANK_PAGE)).assertEqual('');
      expect(UrlHelper.toDisplayUrl('')).assertEqual('');
      expect(UrlHelper.toDisplayUrl('https://example.com')).assertEqual('https://example.com');
    });
  });

  describe('LoadErrorClassifyTest', () => {
    // 修复点：只有主文档的真实故障才算致命错误
    it('isFatalMainFrameError_filtersAbortedAndNone', 0, () => {
      expect(BrowserConstants.isFatalMainFrameError(-3)).assertFalse();
      expect(BrowserConstants.isFatalMainFrameError(0)).assertFalse();
      expect(BrowserConstants.isFatalMainFrameError(-2)).assertTrue();
      expect(BrowserConstants.isFatalMainFrameError(-105)).assertTrue();
    });
  });
}
