# 红底头像图标重绘 v2

日期：2026-11-19。用户要求将现有日历图标中的主席头像换成所附红底图片里的黑白版画头像，抠出后高清重绘。

- 用户附件：292 × 236 JPEG；临时附件的副本保存在仓库外 `~/.cache/MaoStyleCalendar/icon-red-portrait-20261119/reference.jpg`，SHA-256 `76a0755b859822e227915404c19c348edf995d9655dfda0c07d6ac61ce552fb2`。
- [透明高清人物层](app-icon-portrait-red-source-v2.png)：1169 × 1345 PNG，有 Alpha；保留向左仰视的脸部、军帽与红星、黑白版画线条和红领口。SHA-256 `5f30ad4cfd421976c9acb6c9010d6aa45f5838feb7541396421d9f84745bb670`。
- [完整图标候选](app-icon-portrait-red-candidate-v2.png)：1254 × 1254 不透明 PNG；将人物放入既有朱红页眉、双装订孔、米白纸面布局。按用户反馈进一步放大头像，并在米白纸面内做视觉水平、垂直居中。SHA-256 `c2fcd2bd3d2b3140b0b3e33e3995bb132c832864a3716671b45556268ae526d3`。
- `AppIconChinese`、`AppIconEnglish` 各自的 `Any.png` 由候选等比缩至 1024 × 1024，不透明且字节一致；SHA-256 `d5c07aa8200bf80f89432d352dec069eccff681cd3cf7b3f5843deab69d35254`。Dark/Tinted 槽位继续交给系统处理。

透明抠图与高清重绘、完整图标合成及位置修订均使用内置 ImageGen。缩到 96 px 对照原图标后，人物更大，帽形、五官、红星仍可辨认。原图仅为用户提供的参考图；AI 重绘不证明原图或肖像的商用权利已获得许可，发布前仍需确认来源与使用范围。

最终两张图标的尺寸、Alpha 与哈希检查通过；无签名 iOS 模拟器 Debug 构建通过。构建日志与旧图标备份均位于仓库外 `~/.cache/MaoStyleCalendar/icon-red-portrait-20261119/`。尚未在真机主屏幕验收新图标。
