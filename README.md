# Iceland 冰島探索

以 SwiftUI 開發的冰島旅遊介紹 App（iOS 17+）。

| 分頁 | 內容 |
| --- | --- |
| 探索 | 精選景點輪播、主題篩選（瀑布／冰與海／地熱／山岳／城市）、13 個景點卡片 |
| 地圖 | MapKit 地圖上的照片標記，點選卡片後鏡頭飛到景點並可進入介紹 |
| 收藏 | 在景點頁按愛心加入，資料存在 UserDefaults |
| 認識冰島 | 基本資訊、旅遊季節、旅遊小提醒與照片來源 |

## 專案結構

```
Iceland/                 App 原始碼（Models、Views、Assets.xcassets、credits.json）
IcelandUITests/          UI 測試：自動操作 App 一輪，並輸出截圖與起訖時間點
scripts/fetch_images.py  從 Wikimedia Commons 下載景點照片（含授權資訊）
scripts/make_icon.py     繪製 App Icon（極光＋草帽山）
scripts/process_capture.py  剪輯／壓縮操作影片、產生 App Store 截圖
Deliverables/            操作影片、App Store 截圖、App Icon
```

## GitHub Actions

- `fetch-images.yml`：在 runner 上下載 `scripts/image_selection.json` 指定的照片並提交到資產目錄。
- `ipa.yml`：建置未簽名的 `Iceland-unsigned.ipa`（給 AltStore／Sideloadly 側載），放在 `ipa-output` 分支與 Actions artifact。
- `appstore.yml`：以 App Store Connect API 金鑰自動簽名，封存並匯出可上架的 IPA，或直接上傳到 App Store Connect（TestFlight）。
  需要付費的 Apple Developer Program 帳號，並在 repo 的 Actions secrets 設定 `APPLE_TEAM_ID`、`ASC_KEY_ID`、`ASC_ISSUER_ID`、`ASC_KEY_P8`。
- `record.yml`：在 `xcode-27` runner 以 Xcode 27 建置，建立 iPhone 18 Pro Max 模擬器，
  執行 UI 測試的同時用 `simctl io recordVideo` 錄影，結果推到 `capture-output` 分支。

取得錄影結果後產生成品：

```sh
cat raw.mov.part-* > raw.mov
python3 scripts/process_capture.py <capture 目錄> Deliverables <Noto Sans TC 字型目錄>
```

## 照片來源

所有景點照片皆來自 Wikimedia Commons，依各自的創用 CC 授權使用，作者與授權列於
`Iceland/Resources/credits.json`，App 內「認識冰島」頁面底部也有完整列表。
