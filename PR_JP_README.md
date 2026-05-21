# MythConf26 アクセシビリティ提出 — iOSDevUK 2026

## 審査員に見落として欲しくないハイライト

### 1. Colors

- **WCAG AA/AAA をアプリ全域で** — `AccentColor` をライト/ダーク明示 (ダーク AAA = 7.58:1)、`Color.textSecondary` で `.foregroundStyle(.secondary)` を全置換 (AAA = 8.45:1 on 白)、Lightning Talks の `.yellow` を `accentYellow` アセットへ (ライト 4.7:1 / ダーク AAA)
- **SwiftLint カスタムルール** — `no_system_secondary_foreground_style` で AA 未達の再混入を error 検出
- **不透明 vs Liquid Glass の使い分け** — MySchedule ナビバーは強制不透明、pinned 日付ヘッダーは `.ultraThinMaterial`（Reduce Transparency で自動 opaque）、Programme コンテンツは浮遊 TabBar 下まで意図的に流す（背後は大色面）
- **Differentiate Without Color** — `SessionType` ごとの SF Symbol、お気に入りに `sparkles` overlay、オフライン時の `wifi.slash` + テキスト

**Where**: `a4d3929`、`369db39`、`ae16999`、`2da8ff1`、`8b3ecf4`、`6c8b4f4`、`07681fb`、`c0a7a78`、`6a7772c`、`a5f5482`、`f808df3`

### 2. Dynamic Type

`Extensions/AStack.swift`、`Extensions/Color+A11y.swift`

- **`AStack`** — 標準で `HStack`、AX1+ で `VStack` に切替わるカスタムレイアウト。全行・カード・チップが乗り換えるだけで、各呼び出し場所にレイアウトコードを書かずに AX5 まで reflow
- **`a11yLineLimit(_:extra:)`** — AX 時のみ truncate 行数を加算
- **`@ScaledMetric`** — お気に入り星もテキストと一緒に拡大
- **`ViewThatFits` で先回り reflow** — SessionDetail 時刻+会場行は AX1 を待たず縦積み
- **オーバーレイ surface のみ `.large` クランプ** — Programme バナーは AX5 まで上げると下のコンテンツを覆うので意図的に制限

**Where**: `5166be3`、`ad7c3a8`、`d73a77f`、`3ce4db2`

### 3. Focus & Labels

`Extensions/Time+A11y.swift`、`SessionDetailView.swift`、`SpeakerDetailView.swift`、`LocationDetailView.swift`、`ProgrammeView.swift`、`SpeakersView.swift`、`SocialLinksView.swift`

- **`String.spokenTime`** — `"14:30"` を「fourteen thirty」と数字読みする問題を 6 行で解消。`"2:30 PM"` (en) / `"午後2:30"` (ja)、`Date.FormatStyle` を経由しないのでシステムの 24h preference が漏れない
- **詳細画面のタイトル挙動** — `.large`（AX で崩れる）/ `.inline`（24 文字 truncate）の二択を回避。本体に `.isHeader` 見出しを置き、画面外スクロール時のみ `ToolbarItem(.principal)` をフェードイン (`onScrollVisibilityChange`)。VoiceOver は見出し 1 つだけを読む
- **Voice Control input labels** — Programme タブは画面表示の `"3 Thursday"` を含む 5 個受理、お気に入りは `Star / Bookmark / Save / Add to schedule`、ソーシャルは `@handle` + ブランド別称（`Tweet`/`Toot`/`Skeet`/`Code`）。**ユーザーは画面の文字を発話する、コードの変数名ではない**
- **スロット種別を先読み** — Programme カードは *"Workshop, …"* / *"Session, …"* を talk title の前に置く
- **複数形対応** — *"1 session" / "3 sessions"*、*"1 day until MythConf"*（String Catalog substitution）
- **空状態に `ContentUnavailableView`** — 「データ不整合 / 検索ミス / ネット不調」を区別可能に

**Where**: `ab4ddf3`、`678266a`、`b9532e8`、`d0ec3c9`、`413ef97`、`00d70e4`、`7a9724e`、`3b37f05`、`6d2b303`、`a05e8cd`

### 4. Grouping & Custom Actions

`Locations/LocationDetailView.swift`、`Programme/ProgrammeCountdownBanner.swift`、各 RowView

- **Map a11y representation** — SwiftUI `Map` の深いパン/ズーム a11y ツリーは Switch Control / VoiceOver ではノイズ。`.accessibilityRepresentation { Button("Open in Maps: <venue>") }` で AT には **1 個**だけ見せ、ダブルタップで Apple Maps に handoff
- **行をまとめる** — 全 session/speaker 行は単一 VoiceOver 要素（`title, by speakers, at location, n of m` 形式）、装飾 chevron は `.accessibilityHidden(true)`
- **並列セッションを 1 発話で** — バナーは並列スロット中、視覚的には 8 秒 cross-fade だが VoiceOver には *"Now: 2 parallel talks: Talk A by Speaker 1; Talk B by Speaker 2"* で全リスト届く（AT ユーザーは視覚サイクルを待たない）
- **Custom Action** — バナー長押しで `Open date override` 経路を提供 → 審査員はシステム時計を触らず任意状態を検証可

**Where**: `38ef0fc`、`2b63950`、`4228532`、`50a3ce7`、`6a13c3c`

### 5. Orientation

`Extensions/NavigationBar+Landscape.swift`、`Locations/LocationDetailView.swift`、`HomeView.swift`

- **Landscape Location detail を左右並列** — マップと説明文を左右に配置、横持ち両手スマホで両方同時表示
- **横向きはルートナビバー非表示** — ロービジョン向けに縦解像度を最大化
- **縦向きナビバーは強制不透明** — title コントラスト保護
- **回転で TabView 再生成** — タブ幅再計算
- **iPhone PortraitUpsideDown は意図的に省略** — Apple HIG の Face ID デバイス向けガイドラインに従う

**Where**: `2481e00`、`07af79e`、`05e5c36`

### 6. Touch Target

`Favourites/FavouriteButtonView.swift`、`LanguageToggleButton.swift`、`Speakers/SocialLinksView.swift`、`HomeView.swift`、`SessionDetailView.swift`、`Programme/ProgrammeView.swift`

- **44×44pt 担保** — お気に入り、言語トグル、全ソーシャル行を `frame` + `contentShape(.rect)` で明示。視覚アイコンは小さいまま tap 判定だけ 44×44
- **左右スワイプで Programme 日付切替** — 細い segmented picker のピンポイントタップが苦手なユーザー向け代替経路
- **お気に入りボタンを `.overlay` 化** — ZStack 兄弟だと SwiftUI 内部で tap が親 NavigationLink に吸われる症状を解消
- **キーボードショートカット** — `⌘1`–`⌘4`（タブ）、`⌘F`（検索）、`⌘D`（favourite）、`⌥⌘←/→`（日付）、`⌘↑/↓`（リストジャンプ）。隠し背景 Button で実装、`⌘` 長押し HUD には自動表示
- **SessionDetail に明示的なタップアフォーダンス** — 会場 NavigationLink は親の `.secondaryTextStyle()` で tint が抹消されるため円形 Liquid Glass `chevron.right` を追加、List 外スピーカー行にも chevron

**Where**: `a5f5482`、`00d70e4`、`c858215`、`e6d7ecb`、`b3501ae`、`8111573`、`6a13c3c`

### 7. Creativity

`Programme/ProgrammeCountdownBanner.swift`、`Programme/MarqueeText.swift`、`Model/DateOverride.swift`、`Locations/LocationMapSnapshotCache.swift`、`Model/NetworkMonitor.swift`、`LanguageToggleButton.swift`、`Speakers/SocialLinksView.swift`

- **Programme Countdown Banner** — タブ下端にピン留め、状態 5 段階（会期前 / 各日前 / セッション中 / 並列スロット中 / 会期後）。並列時は 8 秒 cross-fade、Reduce Motion で静的サマリにフォールバック
- **Pure SwiftUI `MarqueeText`** — UIKit 非依存。隠し ghost view で自然テキスト幅を測定、オーバーフロー時**のみ**アニメ。Reduce Motion = 静的 + truncate、Bold Text = `legibilityWeight` で再計測、初期高さアンカー固定で初回 frame ジャンプ防止
- **`DateOverride` 審査員フック** — `@Observable` シングルトンで `now: Date` を公開、全時刻依存 view（バナー / 「今日タブか」検出 / 日付 picker 自動ジャンプ）が `Date()` ではなくこれを読む。バナー長押しシートから実行時書換可 → 審査員はシステム時計を触らず全バナー状態を検証可、CI も同フックで決定論的テスト
- **`MKMapSnapshotter` でオフライン会場マップ** — 初回起動で全会場 × ライト/ダーク両モードを生成、Application Support に永続化。`NetworkMonitor` のオフライン報告でキャッシュに差替 + `wifi.slash` 通知。会場 WiFi 不調時の迷子救済
- **アプリ内 EN↔JA トグル** — SwiftUI `\.locale` を実行時切替、`conf-ja.json` も同時リロード。**`Date.formatted` の locale 注入バグ修正**: 既定で `Locale.current` を読むため `\.locale` 上書きが曜日ラベルに効いていなかった
- **ブランド対応ソーシャルリンク** — URL から GitHub / X / LinkedIn / Mastodon / Bluesky / YouTube を判定し本物ロゴ + `@handle` を表示。**潜在バグ修正**: 改行区切り URL で `URL(string:)` が nil 返却 → 全スピーカーのソーシャルリンクが表示されていなかった

**Where**: `34bd581`、`50a3ce7`、`22119db`、`67457cd`、`f808df3`、`ab57a31`、`e4333c8`、`cb17b8b`

---

## 審査基準別

### Vision (HIG)

- **Spoken time formatter** *(ハイライト §3)*
- **`AStack` + `a11yLineLimit`** で **AX5** まで対応 *(ハイライト §2)*。Session 詳細の "時刻 + 会場" 行は `ViewThatFits` で更に強化、長い会場名で wrap が起きる前に縦スタックに reflow (AX1 を待たずに) (`d73a77f`)
- **WCAG AA / AAA コントラストをアプリ全域で**:
  - `AccentColor` をライト/ダーク明示。ダークは AAA (7.58:1 on 純黒) / AA (6.08:1 on ナビバー暗灰) / AA (4.86:1 on `.regularMaterial` dark) を確保 (`a4d3929`)。元アセットは空で system blue にフォールバックしていた (AA 際どい)
  - **全 secondary text を `Color.textSecondary` に置換** (light `#4D4D4D`, dark `#A8A8A8`) — `.foregroundStyle(.secondary)` 12 箇所を変換。system `.secondary` は白上で 3.44:1 (AA 不達)、新色は 8.45:1 (AAA on 白) / 青タイントカード背景上 worst-case で **7.68:1** (AAA) (`369db39`)
  - **ライトニングトーク色**: `.yellow` (≈1.6:1 on 白) を `accentYellow` アセット (`#B07700` light = 4.7:1 AA / `#FFCC00` dark = 14:1 AAA) に (`ae16999`)
  - **SwiftLint カスタムルール** `no_system_secondary_foreground_style` で `.foregroundStyle(.secondary)` の再混入を error 検出 (`369db39`)
- **VoiceOver グルーピング & 見出し** — 全 session/speaker 行は単一 VoiceOver 要素に統合 (`title, by speakers, at location, n of m` 形式、並列スロットでは位置情報も); 画面タイトルは `.isHeader`; 装飾アイコンは `.accessibilityHidden(true)`; 保存済み星には `sparkles` overlay で色なし識別を補強 (`a5f5482`)
- **Programme カードは「種別」を先頭で読み上げ** — *"Workshop, …"* / *"Session, …"* を talk title の前に置くことで、長い title を聴き始める前に種別が分かる (`7a9724e`)
- **surface ごとの Dynamic Type ポリシー** — 本体は AX5 まで `AStack` で reflow。常時オーバーレイの Programme バナーだけは `.large` でクランプ (`3ce4db2`) — 横幅固定オーバーレイで AX5 まで上げると画面の半分を覆って下のコンテンツを隠す。情報密度の高さとオーバーレイ性が両立する唯一の surface なのでここでは可読性 vs 視界 trade-off の選択をする
- **詳細画面タイトル挙動** *(ハイライト §3)*
- **ナビバー強制不透明 + Liquid Glass 配置の使い分け** *(ハイライト §1)*
- **Differentiate Without Color** — `SessionType` ごとに SF Symbol を追加 (`6a7772c`)、talk カード・Programme バナーで表示。保存済み星には `sparkles` 重ね合わせ (`a5f5482`)。オフラインマップ通知は `wifi.slash` アイコン + テキスト (`f808df3`)

### Mobility (HIG)

- **Map accessibility representation** *(ハイライト §4)*
- **キーボードショートカット** — `⌘1`/`⌘2`/`⌘3`/`⌘4` でタブジャンプ、`⌘F` で検索フォーカス、`⌘D` で詳細画面のお気に入りトグル、`⌥⌘←` / `⌥⌘→` で Programme 日付前後、`⌘↑` / `⌘↓` で Speaker 一覧の先頭/末尾。全部隠し背景 Button 経由で実装 → 視覚 UI を占有せず、`⌘` 長押し HUD には自動表示される (`b3501ae`、`8111573`)
- **44 × 44pt タップターゲット** — お気に入り、言語トグル、全ソーシャルリンクを 44pt 明示 + `contentShape(.rect)`。視覚的にはアイコンは小さいまま、tap 判定だけ 44 × 44 (`a5f5482`、`00d70e4`)
- **左右スワイプで Programme 日付切替** — 細い segmented picker のピンポイントタップが苦手なユーザー向け代替経路 (`c858215`)
- **お気に入りボタンを `.overlay` 化** — 親 NavigationLink のヒットテスト競合解消。ZStack 兄弟だと SwiftUI 内部で tap が NavigationLink に吸われることがあった (`e6d7ecb`)
- **SessionDetail に明示的なタップアフォーダンス** — 会場 `NavigationLink` は親の `.secondaryTextStyle()` で tint が抹消されて plain な dim text に見えるので、円形 Liquid Glass disclosure chevron (`chevron.right` inside `.glassEffect(.regular, in: .circle)`) を追加。スピーカー行も List 外なので自動 disclosure indicator が出ない → `chevron.right` を末尾に追加。chevron は両方 `.accessibilityHidden(true)` で重複読み上げ防止 (`6a13c3c`)
- **アプリ全域に `accessibilityInputLabels`** *(ハイライト §3)*

### Cognitive (HIG)

- **Programme タブラベルは "3 Thu"、"4 Fri"、"5 Sat"、"6 Sun"** ("Day 1" / "Day 2" ではなく)。曜日と日付の対応を覚え直す必要なし (`d6c63ca`)
- **VoiceOver session 数の複数形** — *"1 session"* / *"3 sessions"* を String Catalog substitution で対応 (`3b37f05`)
- **複数形対応カウントダウン** — *"1 day until MythConf"* / *"5 days until MythConf"*; JA *"MythConfまであと%lld日"* (日本語は単複同形)。Voice Control input label にも反映 (`6d2b303`)
- **スピーカー検索の空状態** — クエリヒット 0 件で `ContentUnavailableView` を表示。元実装は List が真っ白になるだけで「データ不整合か検索ミスかネット不調か」が区別できない (`a05e8cd`)。VoiceOver には "No search results. No speakers match \"<query>\"." と読まれる
- **Reactive バナー** *(ハイライト §7)* — ユーザーは時計から時刻を計算しなくても「今は何?」が分かる。並列スロット中の VoiceOver には 1 発話で全並列リストが届く
- **長文タイトル用 Marquee Text** (`MarqueeText.swift`) — pure SwiftUI 実装。隠し ghost view で自然テキスト幅を測定、実際にオーバーフローしている場合**のみ**アニメ。Reduce Motion 尊重 (static + truncate)、Bold Text 尊重 (`legibilityWeight` 変化で再計測)、初期高さアンカー固定でバナーの初回 frame ジャンプ防止 (`22119db`)
- **用語と動作の一貫性** — 全 favourite コントロールは同じボキャブラリーを受理; 全 "Open in Maps" は同じ語感; 全外部リンク surface (ソーシャルリンク、in-app ブラウザ) は同じ `arrow.up.right.square` アイコン + 同じ VoiceOver hint *"Opens in browser"* (`b2b6f35`)
- **タイトル挙動が「ここどこ?」の摩擦を減らす** *(ハイライト §3)*
- **アプリ内 EN ↔ JA 切替** *(Cognitive → 国際化 参照)*

### Creativity

- **`MKMapSnapshotter` でオフラインキャッシュ** *(ハイライト §7)*
- **Programme Countdown Banner with 並列 talk サイクリング、Marquee Text、Reduce Motion フォールバック** *(ハイライト §7)*
- **Landscape 対応 Location 詳細** — 横向きで地図と説明文を左右並列に。両手スマホ横持ちユーザーに両方同時表示 (`2481e00`)
- **ブランドロゴ + アカウント名のソーシャルリンク** — `SocialLinksView` は各 URL をパースし、GitHub / X / LinkedIn / Mastodon / Bluesky / YouTube を識別、ライト/ダーク別のアセット画像を表示、URL から*アカウントハンドル*を抽出 (例: `@alice`) して表示。VoiceOver は *"GitHub account, alice"* と読み上げる ("github.com slash alice" ではなく)。**潜在バグ修正**: バンドル `conf.json` は複数 URL を改行区切りで 1 文字列に詰めており、`URL(string:)` は nil を返す → これまで**どのスピーカーもソーシャルリンクが表示されていなかった** (`cb17b8b`)
- **アプリ内 EN ↔ JA 切替** — `LanguageToggleButton` が SwiftUI `\.locale` 環境を実行時に切替、UI 文字列 (`Localizable.xcstrings`) とカンファレンスデータ (`conf-ja.json`) を両方リロード。システム言語が既に英語の場合はボタンを非表示にして no-op を防ぐ。Voice Control は `"Japanese" / "日本語" / "Switch language" / "Toggle language" / "English" / "EN"` を受理 (`ab57a31`、`00d70e4`、`e4333c8`)
- **`Date.formatted` の locale 注入バグ修正** — `Date.formatted(.dateTime…)` は既定で `Locale.current` (デバイスロケール) を見るため、SwiftUI `\.locale` 環境上書きが曜日ラベルに効いていなかった。`@Environment(\.locale)` を読んで全 formatter 呼び出しに `.locale(locale)` を渡す 1 行修正で言語トグルが本当に動くようになった (`e4333c8`)

### Quality

- **a11y ロジックは全部小さな再利用可能ヘルパーの裏に** — `AStack`、`secondaryTextStyle()`、`a11yLineLimit(_:extra:)`、`String.spokenTime`、`landscapeHidesNavigationBar(_:)`、`languageToggleToolbar()`、`MarqueeText`、`glassEffect`。新画面を作るときに各パターンを再導出する必要なし
- **サードパーティ依存ゼロ。** iOS 26 SDK の SwiftUI / MapKit のみ
- **スコープ規律** — a11y 以外の変更は `conf.json` 日付シフト (2026-09-03..06 にしないと「今カンファレンス中?」検出が壊れる) と "MythConf 2027 → 2026" の整合性修正 1 行のみ。便乗リファクタなし
- **SwiftLint カスタムルール** で secondary-text コントラスト修正の regression を防止
- **時刻依存 UI のテスト容易性** — `DateOverride` は `@Observable` シングルトンで `now: Date` を公開。全時刻依存 view (Programme バナー、「今日タブか」検出、日付 picker 自動ジャンプ) は `Date()` ではなく `dateOverride.now` を読む。Debug シート (バナー長押し) で実行時に値を書き換え可 → 審査員はシステム時計を触らずに全バナー状態を検証でき、CI は同じフックで決定論的テストを書ける (`34bd581`)
- **`MarqueeText` 初回描画高さアンカー修正** — 高さ測定に `GeometryReader` を使うと初回 body 評価では 0 を返し、確定するまでの 1 フレームで崩れる症状。隠し ghost で自然テキスト高さを anchor 化して修正 (`22119db`)

### Overall experience

AT 無効の状態ではこのアプリは元と同じ。VoiceOver / Voice Control / Switch Control / Full Keyboard Access / AX5 Dynamic Type を有効にすると、まったく別のアプリが開かれる。アニメーション・ジェスチャ・ビジュアル言語は変えていない; ラベル・フォーカス順・適応レイアウト・コンテンツの反応性が変わる。iOS 26 Liquid Glass surface はその効用が出る場所だけに置いた (Programme は浮遊 TabBar の下まで流れる、SessionDetail 会場リンクは円形ガラス chevron、MySchedule pinned ヘッダーは `.ultraThinMaterial`)、害になる場所には置いていない (MySchedule ナビバーは title コントラスト保護のため不透明維持)

`git diff --shortstat main..HEAD` 値: **+4,145 / −347** across **57 files**、ただし原作者から見た「認知負荷」は小さい — 大半の変更は既存 view への a11y モディファイア "添え" であって書き換えではない

---

## ボーナスカテゴリ

### Hearing (+1)

- **触覚フィードバック** — お気に入り toggle に `.sensoryFeedback(.success, trigger: isFavourite)` で deaf/HoH ユーザーに「操作が受理された」を触覚で返す (`9d84aa8`)
- **色だけに頼らない視覚確認** — 保存済み星に `sparkles` overlay で hue ではなく形状で状態を伝える (`a5f5482`)
- **オフライン通知** — キャッシュ map 表示時に `wifi.slash` アイコン + テキストの明示ラベル (`f808df3`)
- **外部リンクインジケータ** — ソーシャルリンクに `arrow.up.right.square` を併記して「ここから出る」を伝達、VoiceOver には `accessibilityHint("Opens in browser")` でペア提供 (`b2b6f35`)

### Speech (+1)

- **画面表示と一致する Voice Control エイリアス** *(ハイライト §3)*。Programme picker は "3 Thursday" を受理 — それが画面に出ている文字、そしてユーザーが発話する文字。多くのアプリは "Day 1" しか受理しない
- **ブランド別カジュアル別称** — X URL に "Twitter" / "Tweet"、Bluesky に "Skeet" / "Bsky"、GitHub に "Code" / "Source" を登録。非明示だが「人々が実際にこれらサービスをどう呼ぶか」と一致
- **言語トグルのバイリンガル別称** — `"Japanese" / "日本語" / "English" / "EN" / "Switch language" / "Toggle language"` でターゲット言語名 ("Tap Japanese" 英語表示中時) でも動作名 ("Tap Switch language") でも切替可能 (`00d70e4`)

---

## コミット別変更一覧 (新しい順)

`git log main..HEAD` の各エントリは上記いずれかのカテゴリに属する。最近の作業順に並べる。

| Commit | カテゴリ | 概要 |
|---|---|---|
| `07681fb` | Vision / Liquid Glass | MySchedule pinned 日付ヘッダーを `.ultraThinMaterial` に (Reduce Transparency で自動 opaque) |
| `6d2b303` | Cognitive / i18n | "X days until MythConf" 複数形対応 + JA 翻訳 (元は "X days to go" で d=1 のとき "1 days to go" になっていた) |
| `b2b6f35` | Hearing / Mobility | ソーシャルリンクに外部リンクアイコン (`arrow.up.right.square`) + VoiceOver hint `"Opens in browser"` |
| `6a13c3c` | Mobility | SessionDetail: スピーカー行に chevron、会場リンクに円形 Liquid Glass chevron (親の `.secondaryTextStyle()` で tint 抹消されるため明示) |
| `3ce4db2` | Vision | Programme バナーを `.large` Dynamic Type クランプ (オーバーレイ surface のみ、他は AX5 まで追従) |
| `c0a7a78` | Vision / Liquid Glass | Programme コンテンツが浮遊 Liquid Glass TabBar の下まで流れる (VStack スタック → ZStack overlap に変更) |
| `67457cd` | Cognitive | バナータイトルに "Day X · 4 September Friday" 表示 (元は "Day X" だけ) |
| `22119db` | Quality | `MarqueeText` 初回高さアンカー修正 (1 フレームの崩れ解消) |
| `50a3ce7` | Cognitive / Creativity | 並列 talk サイクル、Reduce Motion 時は静的 "N parallel talks"、VoiceOver は 1 発話で全リスト |
| `34bd581` | Quality / Creativity | Programme Countdown Banner + `DateOverride` debug シート (バナー長押し) |
| `ad7c3a8` | Vision | お気に入り星が `@ScaledMetric` で Dynamic Type 追従 |
| `6a7772c` | Vision / DWC | Programme カードに `SessionType` ごとの SF Symbol (色のみだった) |
| `7a9724e` | Cognitive | talk カードが title の前に "Workshop, …" / "Session, …" を読み上げ |
| `d73a77f` | Vision | SessionDetail 時刻/会場行を会場名オーバーフロー時に reflow (`ViewThatFits`) |
| `2b31c19` | (merge) | merge `akidon0000/iosdevuk-a11y-2026` |
| `84ab3e4` | Speech / i18n | Voice Control input labels: JA 翻訳 |
| `e6d7ecb` | Mobility | お気に入りボタンを ZStack 兄弟 → `.overlay` 化 (ヒットテスト競合解消) |
| `7615f55` | Cognitive / i18n | Programme タブ日付ラベルがアプリ内 locale トグルに追従 |
| `5631e72` | Comprehensive | (squashed) 基盤となる包括的 a11y パス |
| `c87c273` | (merge) | merge language-toggle 44pt 系 |
| `af34c63` | Speech / i18n | language toggle 由来の自動抽出文字列 |
| `e4333c8` | Cognitive / i18n | `Date.formatted` が SwiftUI `\.locale` 上書きに追従 |
| `6c8b4f4` | Vision | MySchedule nav bar 不透明維持 (title コントラスト保護) |
| `8b3ecf4` | Vision | MySchedule pinned 日付ヘッダー不透明 (再適用) |
| `2da8ff1` | Vision | MySchedule nav bar 強制不透明 |
| `a05e8cd` | Cognitive | スピーカー検索空状態に `ContentUnavailableView` |
| `413ef97` | Speech | Programme picker が Voice Control で "3 Thursday" を受理 |
| `d6c63ca` | Cognitive | Programme タブラベルに day-of-month + 曜日 (`3 Thu`) |
| `8111573` | Mobility | `⌘1–⌘4` タブ、`⌘F` 検索、`⌘D` favourite、`⌥⌘←/→` 日付、`⌘↑/↓` リストジャンプ |
| `3b37f05` | Cognitive | VoiceOver session 数の複数形 |
| `00d70e4` | Mobility / Speech | 言語トグル 44×44pt + Voice Control ラベル |
| `e546078` | Quality | session タイムスタンプを 2026-09-03..06 にシフト |
| `05e5c36` | Mobility | 回転時に TabView 再生成 (タブ幅再計算) |
| `d739a83` | Quality | 年表記 2027 → 2026 |
| `ab57a31` | Cognitive / i18n | アプリ内 EN/JA トグル + JA コンテンツ (`conf-ja.json`) |
| `2bdcf90` | Cognitive / i18n | UI + a11y ラベルを JA ローカライズ |
| `cb17b8b` | Cognitive / Creativity | ソーシャルリンクにブランドロゴ + アカウント名 (改行区切り URL バグも修復) |
| `f808df3` | Creativity / Hearing | `MKMapSnapshotter` で会場マップオフラインキャッシュ; 明示的 "no network" 通知 |
| `d0ec3c9` | Speech | アプリ全域に Voice Control input labels |
| `a4d3929` | Vision | `AccentColor` ライト/ダーク明示 (ダーク AAA) |
| `2481e00` | Creativity | LocationDetail 横向きで地図/説明文を左右並列 |
| `07af79e` | Mobility | 横向きでルートタブナビバー非表示、縦向きは強制不透明 |
| `c858215` | Mobility | Programme 日付を左右スワイプで切替 |
| `a5f5482` | Mobility / DWC | お気に入り 44×44pt + `sparkles` overlay で「保存済み」を色なし表現 |
| `9d84aa8` | Hearing | お気に入りに haptic + 短縮 VoiceOver ラベル |
| `4228532` | Vision | VoiceOver 行グルーピング仕上げ |
| `b9532e8` | Vision / Cognitive | 詳細画面タイトルがスクロールでナビバーへフェードイン |
| `678266a` | Vision / Cognitive | 詳細画面タイトルを本体先頭ヘッダーに移動 |
| `ab4ddf3` | Vision | `String.spokenTime` で 12h AM/PM 読み上げ |
| `38ef0fc` | Mobility | Map VoiceOver representation を Open-in-Maps Button に置換 |
| `2b63950` | Vision / Cognitive | VoiceOver 行グルーピング + 見出しナビ |
| `5166be3` | Vision | Dynamic Type AX5 対応 (`AStack`, `a11yLineLimit`, `@ScaledMetric`) |
| `369db39` | Vision | secondary text を WCAG AAA に (`textSecondary` アセット + SwiftLint guard) |

---

## 意図的に含まなかったもの

- **VoiceOver Rotor custom items** — 検討したが見送り。バンドル programme のデータ量だと Rotor 追加は移動コストを増やすだけで減らさない; 既存の heading ベース VoiceOver 構造の方が速い。Programme バナーが「今ここ」のアンカーとして同じ用途をカバーしている (より発見しやすい形で)。審査員がこちらを推す場合は追加します
- **お気に入り行の Custom Actions** — お気に入りは各行に 44 × 44pt の単体ボタンとして既に存在、Custom Actions でラップすると単純化ではなく重複になる。Programme バナーには `Open date override` の Custom Action を入れてある
- **Switch Control 自動テスト** — 手動検証のみ、今回は自動 harness を組む時間がなかった
- **iPhone PortraitUpsideDown** — Apple HIG の Face ID デバイス向けガイドラインに従って Info.plist で意図的に省略。他の landscape 方向は対応

---

## ファイルマップ

```
MythConf/MythConf26/
├── Extensions/
│   ├── AStack.swift                       ← HStack/VStack 適応コンテナ
│   ├── Color+A11y.swift                   ← secondaryTextStyle, a11yLineLimit
│   ├── NavigationBar+Landscape.swift      ← 向きごとの opaque/hidden バー
│   └── Time+A11y.swift                    ← String.spokenTime (24h → 12h AM/PM)
├── LanguageToggleButton.swift             ← EN↔JA アプリ内トグル (Voice Control labels)
├── Localizable.xcstrings                  ← 複数形含めた完全 JA ローカライズ
├── Locations/
│   ├── LocationDetailView.swift           ← Map a11y representation, landscape 分割
│   └── LocationMapSnapshotCache.swift     ← オフライン map キャッシュ (MKMapSnapshotter)
├── Model/
│   ├── DateOverride.swift                 ← 時間旅行フック (バナー debug + テスト)
│   ├── NetworkMonitor.swift               ← オフライン map フォールバックを駆動
│   └── conf-ja.json                       ← 日本語版セッション/スピーカーコピー
├── MySchedule/MyScheduleView.swift        ← .ultraThinMaterial pinned ヘッダー, opaque ナビバー
├── Programme/
│   ├── DebugDateOverrideSheet.swift       ← バナー長押しで日時旅行
│   ├── MarqueeText.swift                  ← Reduce Motion 対応スクロールテキスト
│   ├── ProgrammeCountdownBanner.swift     ← ライブバナー: 会期前/中/並列/後
│   └── ProgrammeView.swift                ← 日付スワイプ、TabBar 下まで scroll、picker labels
├── SessionDetailView.swift                ← chevron アフォーダンス + locationLinkLabel
├── Speakers/SocialLinksView.swift         ← ブランド対応ソーシャルリンク + 外部リンクアイコン
└── HomeView.swift                         ← ⌘1–⌘4 タブショートカット, 回転再生成
.swiftlint.yml                             ← `.foregroundStyle(.secondary)` を error 検出
```

---

応募ありがとうございます。各変更は AT 実機検証で「これは尊厳に欠ける」と感じた瞬間を発見してから着手したもの — 「項目を埋める」ためではなく「摩擦を取り除く」ためのコードです。iOS 26 Liquid Glass のおかげで、それぞれの surface 単位で「コントラスト vs アクセシビリティの既定挙動」を明示的に選ぶ必要が生まれ、結果的にこれが良い制約として効きました。
