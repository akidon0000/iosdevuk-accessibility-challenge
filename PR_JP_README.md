# MythConf26 アクセシビリティ応募 — iOSDevUK 2026



## Vision

### Dynamic Type

`Extensions/AStack.swift`

- **`AStack`** — 標準サイズでは `HStack`、AX1 以上では `VStack` に切り替わるカスタム適応レイアウトを実装。
- **`a11yLineLimit`** — `.lineLimit(_:)` の AX 対応版を実装。AX1 以上のときだけ末尾に追加行を許可し、グリフ拡大による truncate を緩和。
- **`ViewThatFits`** — Session 詳細の「時刻 + 会場」行は、AX1 を待たず、長い会場名で折り返しそうな時点で自動的に縦積みに切り替わります。
- **`@ScaledMetric`** — お気に入りスター・タップ領域・余白などの数値も Dynamic Type と連動して拡大。
- **Banner の意図的キャップ** — Programme バナーだけは下のコンテンツを覆い隠さないよう意図的に上限を設定。

### Color Contrast

`Assets.xcassets`、`Extensions/Color+A11y.swift`

**WCAG 2.1 のコントラスト基準（以下に出てくる AA / AAA の参照先）**

| レベル | 通常テキスト | 大きいテキスト / UI 部品 |
|---|---|---|
| **AA**（1.4.3 / 1.4.11） | **4.5:1** 以上 | **3:1** 以上 |
| **AAA**（1.4.6） | **7:1** 以上 | **4.5:1** 以上 |

- **`AccentColor` をライト/ダーク明示** — ブランドカラーをライト時 `#0050D8`（白背景で **6.77:1**）、ダーク時 `#4B9DFF`（黒背景で **7.8:1**）に分離。
- **`Color.textSecondary` アセット** — システムの `.secondary` は白背景で **3.44:1** しか出ず **WCAG 2.1 AA の通常テキスト基準（4.5:1）** 未達のため、**AAA 基準（7:1）** を満たす `#4D4D4D`（白背景で **8.47:1**）/ `#A8A8A8`（黒背景で **8.84:1**）のアセットを作成し、`.secondaryTextStyle()` モディファイア経由で全画面に展開。





### Convey information with more than color alone

- **SessionType ごとの SF Symbol** — Workshop は `hammer.fill`、Talk は `mic.fill`、Panel は `person.3.fill`、Lightning は `bolt.fill`。色覚特性で青系の Workshop/Talk が見分けづらいケースでも、形で識別できます。
- **お気に入りスターの `sparkles` オーバーレイ** — アクティブ時は星に `sparkles` 装飾が乗るため、色相だけでなく形でも状態が伝わります。
- **ソーシャルリンクに外部アプリ起動アイコン** — `SocialLinksView` の各行末尾に `arrow.up.right.square` を表示。X / GitHub / Bluesky / Mastodon などのリンクが「タップで別アプリに遷移する」ことを、リンク色や下線だけでなく形でも伝えます。
- **SessionDetail の会場・登壇者行にタップ可能アフォーダンス** — `SessionDetailView` の会場行および登壇者行の末尾に `chevron.right` を表示し、視覚的に「ここはタップ可能な行＝ボタンである」ことを色や配置以外の形で示します。視覚的なリンク色に頼れないユーザーでも、行が押せることがアイコンの形だけで分かるようになります。


### VoiceOver

各 View の `.accessibilityLabel` / `.accessibilityHint` / `.accessibilitySortPriority`

- **LocationMap のアクセシビリティ表現で Apple Maps に引き渡す** — VoiceOver でのマップ操作（パン・ズーム・ピン読み上げ）は SwiftUI `Map` の a11y ツリーをそのまま渡しても事実上ナビ不能。`accessibilityRepresentation { Button("Open in Maps: <venue>") }` で支援技術からは **1 つのタップ可能ターゲット** に集約し、ユーザーが日常的に慣れているアクセシブルな純正 Apple Maps に引き渡します。視覚操作ユーザーには対話的マップを維持。
- **要素のグルーピングと見出し** — セッション/スピーカー行は `.accessibilityElement(children: .combine)` で 1 要素に統合、画面タイトルには `.accessibilityAddTraits(.isHeader)`、装飾アイコンは `.accessibilityHidden(true)`。
- **読み上げ順を `.accessibilitySortPriority` で制御** — Programme カードは「種別 → タイトル → 登壇者 → 会場 → お気に入り」の順で読み上げ、長いトーク名の前にスロット種別が分かるように。
- **Programme カードのお気に入りスターを VoiceOver で選択可能に** — `NavigationLink` 内にスターがネストされて到達できなかった問題を、`.accessibilityElement(children: .contain)` + `.accessibilitySortPriority(1/0)` で「セッション本体」と「お気に入り」を **独立した 2 つの focusable target** に分離して解消。
- **ソーシャルリンクはサービス名で読み上げる** — `SocialLinksView` が URL を `SocialBrand` で解析し、`.accessibilityLabel` を「GitHub account, alice」のようにブランド名 + アカウントで構築。ホスト名読み（"github.com slash alice"）を回避。未認識 URL は「Website, davidkowalski.dev」にフォールバック。

---

## Mobility

### Offer sufficiently sized controls

- **44×44pt 以上のタップ領域** — お気に入りスター、ソーシャルリンク行、Programme カードはいずれも `.frame(minWidth: 44, minHeight: 44)` + `.contentShape(.rect)` で Apple HIG の最小サイズを保証。
- **`@ScaledMetric` でターゲットサイズも拡大** — Dynamic Type を上げるとタップ領域自体も比例して大きくなります。

### Offer alternatives to gestures

- **横スワイプで Programme の日付切替** — segmented picker の精密なタップが苦手なユーザー向けに、左右スワイプで日付を切り替え可能。
- **スワイプバックジェスチャを有効化** — `NavigationStack` で iOS 標準の右スワイプ戻るが効きます。

### Integrate with Siri and Shortcuts to let people perform tasks using voice alone

- **Voice Control 用に `.accessibilityInputLabels`** をアプリ全体に展開:
  - Programme ピッカー: `"3 Thursday"` / `"3 Thu"` / `"Thursday"` / `"Thu"` / `"Day 1"`
  - お気に入り: `Favourite / Favorite / Star / Bookmark / Save / Add to schedule / Remove from schedule`
  - ソーシャルリンク: URL から解析した実際の `@handle`、加えて `"Twitter"`/`"Tweet"`（X）、`"Skeet"`/`"Bsky"`（Bluesky）など人々が実際に発話する言葉。
  など複数ワードで検知できる仕組み


### Support mobility-related assistive technologies

#### VoiceOver

- **要素のグルーピング** — `.accessibilityElement(children: .combine)` で 1 行 1 要素に統合し、スワイプ移動の回数を最小化。
- **読み上げ順を `.accessibilitySortPriority` で制御** — お気に入りボタンを後回しにして、タイトル → 登壇者 → 会場 を先に聞けるように。
- **`accessibilityRespondsToUserInteraction(false)`** — 休憩行は VoiceOver には読まれるが Switch Control / フルキーボードアクセスからはフォーカス対象外に。

#### フルキーボードアクセス

- **`⌘1` / `⌘2` / `⌘3` / `⌘4`** — Programme / Speakers / Locations / My Schedule に直接ジャンプ（`HomeView.swift`）。`.background { Button(...).keyboardShortcut(...) }` + `.hidden()` でアプリ全域に効くショートカットを、見える UI を占有せず実装。
- **`⌘F`** — Speakers の検索欄にフォーカス。
- **`⌘D`** — SessionDetail でお気に入りをトグル（`SessionDetailView.swift`）。toolbar の star ボタンに直接フォーカスせずに保存／解除できるので、Tab を何度も押す必要がありません。
- **すべての NavigationLink / Button** が `.focusable()` で順次フォーカス可能。

---

## Cognitive

### Keep actions simple and intuitive

- **Programme タブラベルを「3 Thu」「4 Fri」表示に** — 「Day 1 / Day 2」は並び順から推測でき情報として冗長、逆に「Thursday」だけだと何日か分かりません。日にち + 曜日の組み合わせにすることで、両方の手がかりが 1 ラベルに収まり、ユーザーがカレンダーと頭の中で対応付けやすくなりました。
- **用語の一貫性** — お気に入り関連はどこでも `Favourite / Save / Add to schedule` の同じ語彙、「Open in Maps」のアフォーダンスも全画面で同じ文言を使用。
- **複数形対応の VoiceOver セッション数** — `1 session` / `3 sessions` を正しく分岐（Localizable.xcstrings の plural variation）。`3 session` のような違和感は出ません。
- **空状態を明示** — スピーカー検索でヒット 0 件のときは `ContentUnavailableView` で「該当なし」を視覚 + VoiceOver の両方に伝えるため、説明のない空白リストにはなりません。
- **詳細タイトルの挙動** — `.large` タイトルの不自然なジャンプも `.inline` タイトルの迷子化も避けるため、本文側に大見出しを置き、スクロールアウト時のみインライン版がナビバーへ移行。常に「自分がどこにいるか」が分かります。

### Be cautious with fast-moving and blinking animations

- **Programme バナー を Reduce Motion に追従** — Programme タブ下部に常駐する案内バナー（現在進行中のセッション情報を表示し、パラレル開催時は 8 秒ごとに複数トーク間を切り替え、長いトーク名は横スクロールで全文を見せる仕組み）は、`@Environment(\.accessibilityReduceMotion)` が ON のとき、バナー本体は「N parallel talks」の静止サマリーに、`MarqueeText` はスクロール停止 + 末尾省略表示に同時に切り替わり、画面が勝手に動かなくなります。読みかけのテキストを失わず、前庭障害があるユーザーにも安心です。
- **オートディスミスゼロ** — シート・アラート・通知バナーは自動で閉じるものを一切置かず、ユーザー操作でのみ閉じます。

---

## Hearing

### Use haptics in addition to audio cues

- **`.sensoryFeedback(.success, trigger: isFavourite)`** — お気に入り追加/削除のたびに成功ハプティクスを発火。聴覚に依存しない確認手段。

---

## Speech

### Let people use the keyboard alone to navigate and interact with your app

フルキーボードアクセスを有効にした状態で、`⌘1`–`⌘4` でタブ間ジャンプ、`⌘F` で検索フォーカス、Tab/方向キーで個別コントロール間を移動、Space/Enter で起動できます（`HomeView.swift`、`SpeakersView.swift`）。発話が困難なユーザーが Switch / 外付けキーボード / Mac の Sidecar 経由でも、音声入力に頼らず全機能を操作可能です。

### スイッチコントロールに対応する

- **Map の representation を 1 ターゲットに集約** — Switch Control はスイッチ 1〜2 個で操作するため、パン可能な MapKit ツリーは事実上ナビ不能でした。これを `Button("Open in Maps: <venue>")` 1 つに置き換えたので、1〜2 アクションで Apple Maps に引き渡せます。
- **要素統合でホップ数を減らす** — `.accessibilityElement(children: .combine)` で行を 1 要素化、`.accessibilitySortPriority` で予測可能な順番、`.accessibilityRespondsToUserInteraction(false)` で非操作要素（休憩・空のサマリー）をスキャンから除外。
- **Voice Control エイリアスの語彙が豊富** — Switch Control のユーザーは Voice Control を併用するケースも多く、画面表示と一致する複数エイリアスがそのまま使えます。




## Other Improvements

HIG カテゴリには綺麗に収まらないものの、体験を底上げしている変更をここにまとめます。

### スピーカー詳細のナビゲーションタイトルをアイコン + 人物名に

`Speakers/SpeakerDetailView.swift`（`ToolbarItem(placement: .principal)` + `SpeakerPhotoView`）

ナビゲーションバーのタイトル領域に、本文側のヒーロー写真がスクロールアウトしたあと「小さな丸い顔写真サムネイル + 氏名」を表示するようにしました。複数のスピーカー詳細を行き来していると「いま誰のページだっけ？」と迷いがちですが、ナビバーに顔があれば一目で確認できます。視覚に頼れないユーザーには `.accessibilityAddTraits(.isHeader)` 付きの本文タイトルが届くので、両方を犠牲にしません。

### 日時に応じてバナーのステータスが自動で切り替わる

`Programme/ProgrammeCountdownBanner.swift`、`Model/ConfTimeType.swift`

下部に常駐する案内バナーが `ConfTimeType` の判定に応じて 4 つの状態を切り替えます:

- **開催前** — 「N days until MythConf」とカウントダウン
- **開催日のセッション間 / 開始前 / 終了後** — 「Day X · 日付 曜日」をタイトルに、補足ステータスをサブタイトルに表示
- **開催中のトーク進行中** — 現在進行中のトーク名と登壇者を表示、パラレル開催時は 8 秒ごとに巡回（Reduce Motion 時は静的サマリーへ）
- **開催終了後** — 「Thanks for joining — see you in 2027」のアナウンス

会期中のユーザーが画面を見るだけで「今がカンファレンスのどの瞬間か」が分かり、Programme リストとの突き合わせを頭でやる必要がなくなります。

### オフライン会場マップ

`Locations/LocationMapSnapshotCache.swift`、`Model/NetworkMonitor.swift`、`Locations/LocationDetailView.swift`

`MKMapSnapshotter` で会場ごとのライト/ダーク両モードのマップ画像を初回起動時に事前生成し、Application Support に永続化します。`NetworkMonitor` がオフラインを検知したら、対話的な `Map` の代わりにこのキャッシュ画像を表示し、`wifi.slash` アイコン + 「オフライン — 保存済みスナップショットを表示しています」のキャプション付き `Label` も合わせて出します。カンファレンス会場の Wi-Fi が貧弱なのは例外ではなく日常で、道案内が必要になるまさにその瞬間に画面が真っ白になる、という最悪のケースを潰しています。

### SNS リンクにブランドアイコンを追加

`Speakers/SocialLinksView.swift`、`Model/SocialBrand.swift`

`SocialBrand` が URL を解析して GitHub / X / LinkedIn / Mastodon / Bluesky / YouTube を判別し、ライト/ダーク両対応のブランドロゴアセット（`Image(brand.assetName)`）を行頭に表示します。未認識 URL は SF Symbol `link` にフォールバック。視認だけで「これは GitHub」「これは Bluesky」とブランドが伝わり、URL のホスト名を読まなくても済みます。

### MyScheduleのセクションヘッダーを半透明 material に

`MySchedule/MyScheduleView.swift`

ピン留めされる日付ヘッダーに `.ultraThinMaterial` を適用し、下のセッションリストがうっすら透けて見える Liquid Glass 風の表現を採用しました。Reduce Transparency が ON のときは iOS が自動的に不透明背景へ切り替えるので、半透明が苦手なユーザーや前庭障害ユーザーを置き去りにしません。

### 日本語ローカライズ

`Localizable.xcstrings`、`Model/conf-ja.json`、`LanguageToggleButton.swift`

日本人開発者として、UI 文字列と同梱セッションデータ（スピーカー紹介・トーク説明・会場情報など）の両方を日本語化しました。実装は SwiftUI の `\.locale` 環境を実行時に書き換える方式（`LanguageToggleButton` のトグル）で、`Localizable.xcstrings` の翻訳と `conf-ja.json` の和訳セッションデータが同時に切り替わります。

この仕組みは locale 識別子を差し替えるだけの汎用設計なので、LTR 言語（英 / 仏 / 独 / 西 / 中 / 韓 など）への拡張は翻訳ファイルを追加するだけで対応できます。アラビア語 / ヘブライ語などの RTL 言語のみ、レイアウト方向の再検証が追加で必要です。




