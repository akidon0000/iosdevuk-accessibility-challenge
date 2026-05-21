# MythConf26 Accessibility Submission — iOSDevUK 2026

> **TL;DR** — An end-to-end accessibility pass on the bundled SwiftUI conference app, covering every judging category and both bonuses, on **iOS 26 with Liquid Glass**. The submission ships a measurable, defensible improvement on top of an app that was generated and therefore had the usual "looks fine, breaks for AT users" footguns. Highlights worth a second look:
>
> - A **`String.spokenTime` formatter** so VoiceOver never reads "fourteen thirty"
> - A **substituted `Map` accessibility representation** that replaces a 200-element MapKit a11y tree with one "Open in Apple Maps" target
> - A **plural-aware countdown banner** (`1 day until MythConf` / `5 days until MythConf`) that doubles as a live "now playing" indicator with **Marquee text for long talk titles**
> - **Liquid Glass everywhere it earns its keep** — Programme content scrolls under the floating TabBar, the MySchedule pinned headers use `.ultraThinMaterial`, and the SessionDetail venue-link uses a Liquid Glass disclosure chevron
> - A custom **`AStack`** layout that quietly carries 50+ views to **AX5 Dynamic Type**
> - **Offline-cached venue maps** via `MKMapSnapshotter` — because conference Wi-Fi is unreliable when wayfinding matters most
> - **Voice Control aliases that match what users see on screen** ("3 Thursday", not "Day 1")
> - Full **EN ↔ JA in-app language toggle** that re-loads bundled conference data and respects per-locale plural rules

This is one branch with ~60 focused commits on top of `main`. Every commit message starts with a category prefix (`feat(a11y)` / `fix(a11y)` / `fix(Color)` / `feat(Programme)`) so reviewers can audit by topic from `git log`.

---

## How to evaluate quickly

If you have **5 minutes**:

1. **VoiceOver, Programme tab** — swipe down to any session and double-tap the time. You should hear *"2:30 PM"*, not *"fourteen thirty"*. See **Vision → Spoken time**.
2. **Voice Control, Programme picker** — say *"3 Thursday"* exactly as the segmented label reads. See **Speech → Voice Control aliases**.
3. **Switch Control or VoiceOver, Locations detail** — there is exactly **one** focusable map target labelled *"Open in Maps: \<venue\>"*. See **Mobility → Map accessibility representation**.
4. **Airplane mode → Locations** — venue maps still render from the on-disk snapshot cache with an explicit "No network" notice. See **Creativity → Offline venue maps**.
5. **Settings → Accessibility → Larger Text → AX5** — every screen reflows cleanly; nothing clips. See **Vision → AStack / Dynamic Type**.
6. **Full Keyboard Access** — `⌘1`–`⌘4` jump between tabs, `⌘F` focuses search, `⌥⌘←/→` flips Programme days, `⌘D` toggles favourite on detail. See **Mobility → Keyboard**.

If you have **10 minutes**, also try:

7. **Programme banner during a parallel slot** — when two talks run in the same time window, the banner cycles between them every 8 s with a smooth fade. With Reduce Motion on, it switches to a static *"2 parallel talks"* summary instead. **VoiceOver users get the entire parallel-track list in a single utterance** — no waiting for the cycle. See **Cognitive → Reactive conference banner**.
8. **Long-press the banner** — opens an in-app date-override sheet. Set it to *"3 Sep 2026, 11:00"* to see the live state without changing your Mac's clock. See **Quality → Testability of time-based UI**.
9. **Settings → Accessibility → Larger Text → AX5, then look at the banner** — the banner clamps at `.large` because it's a width-fixed overlay, but every other view scales all the way to AX5. See **Vision → Per-surface Dynamic Type policy**.
10. **Rotate to landscape on Programme or My Schedule** — the nav bar disappears entirely to give vertical pixels back. Rotate to landscape on Locations detail — the map and description shift to a side-by-side layout instead of stacked.

---

## Highlights judges may otherwise miss

These are the decisions I'd love judges to look at most closely. Each is small in diff size but disproportionately big in lived experience.

### 1. `String.spokenTime` — VoiceOver never reads a 24h clock

`MythConf/MythConf26/Extensions/Time+A11y.swift`

VoiceOver, by default, reads `"14:30"` aloud as **"fourteen thirty"** — not a time of day. The bundled session data is in 24h format. A pure-string extension parses `HH:mm` and emits `"2:30 PM"` (US locale) / `"午後2:30"` (JA locale). It does **not** route through `Date.FormatStyle`, so the system's 24-hour preference never bleeds through. Applied at every session row, the parallel-track grid, and the detail view. Six lines of code, replaces an unfixable VoiceOver complaint. **Where**: `ab4ddf3`.

### 2. Map's accessibility tree is replaced, not patched

`MythConf/MythConf26/Locations/LocationDetailView.swift`

`Map` in SwiftUI exposes a deep panning, zooming a11y tree. For Switch Control / VoiceOver users that tree is essentially noise — you cannot meaningfully pan a map with a single switch. The map is wrapped in `.accessibilityRepresentation { Button("Open in Maps: <venue>") { … } }`, so assistive tech sees **one** crisp target that hands off to Apple Maps (which is itself far more accessible than an embedded MapKit view). Sighted users still get the full interactive map. **Where**: `38ef0fc`.

### 3. Voice Control aliases match what users *see*

Across the app (`Programme/ProgrammeView.swift`, `Speakers/SpeakersView.swift`, `Favourites/FavouriteButtonView.swift`, `Locations/LocationDetailView.swift`, `LanguageToggleButton.swift`, `Speakers/SocialLinksView.swift`, …) every interactive control declares multiple `.accessibilityInputLabels([…])` entries. The principle: **Voice Control users say what's on screen, not what the developer named the variable**:

- The Programme picker tabs accept `"3 Thursday"`, `"3 Thu"`, `"Thursday"`, `"Thu"`, and `"Day 1"`. The first form is what the segmented label literally renders.
- The favourite star accepts `Favourite / Favorite / Star / Bookmark / Save / Add to schedule / Remove from schedule` — covering UK/US spelling and the natural synonyms people reach for under stress.
- Social link buttons accept the actual `@handle` parsed out of the URL plus brand-specific casual nicknames (`Tweet`, `Toot`, `Skeet`, `Code`, `Source`).

Almost every iOS app I tested had either no `accessibilityInputLabels` or only one — and you cannot guess that the visible tab "3 Thursday" was originally coded as `Day 1`. **Where**: `d0ec3c9`, `413ef97`, `00d70e4`.

### 4. Detail screen titles: full body header → inline on scroll

`Programme/SessionDetailView.swift`, `Speakers/SpeakerDetailView.swift`, `Locations/LocationDetailView.swift`

Default SwiftUI navigation either uses a `.large` title (which jumps awkwardly under Dynamic Type) or an `.inline` title that truncates the moment the title is longer than ~24 characters. Talk titles are routinely longer than that. So the title is rendered in the body as a heading (`.accessibilityAddTraits(.isHeader)`), and an inline copy slides into the navigation bar **only after the body title scrolls off-screen** (`onScrollVisibilityChange`). VoiceOver gets exactly one heading, never two; sighted users always know where they are. Speaker detail goes further — the principal slot fades in the speaker's photo + name as a unit. **Where**: `678266a`, `b9532e8`.

### 5. `AStack` — Dynamic Type at AX5 without per-view rewrites

`MythConf/MythConf26/Extensions/AStack.swift`

A view that lays out as `HStack` at standard sizes and switches to `VStack` at AX1+. Every row, card, and chip in the app that pairs an icon with text uses `AStack` instead of `HStack`. They all gracefully reflow at the largest accessibility sizes without bespoke layout code at each call site. Paired with `a11yLineLimit(_:extra:)` in `Color+A11y.swift` for text that should be allowed extra wrapping at AX sizes only. **Where**: `5166be3`.

### 6. The Programme Countdown Banner — a live, parallel-aware, accessible status bar

`MythConf/MythConf26/Programme/ProgrammeCountdownBanner.swift`

A pinned banner at the bottom of the Programme tab that adapts to where the user is on the conference timeline:

- **Before the conference** — *"5 days until MythConf"* (plural-aware via String Catalog `one`/`other` substitutions; `1 day until MythConf` is grammatically correct).
- **Before each day starts** — *"Day 2 · 4 September Friday"* with the actual conference date/weekday.
- **During a session** — the talk title fades in, with the speakers' names below. If the talk title overflows the row width, it scrolls with a **custom `MarqueeText`** view (pure SwiftUI, no UIKit) that respects Reduce Motion (static + truncated) and Bold Text (re-measures on `legibilityWeight` change).
- **During a parallel slot** — cycles through every running talk every 8 seconds with a sequential cross-fade. With Reduce Motion on, it shows a single *"2 parallel talks"* summary instead. **VoiceOver gets the entire list in a single utterance** — *"Now: 2 parallel talks: Talk A by Speaker 1; Talk B by Speaker 2"* — so AT users don't have to wait through cycles.
- **After the conference** — *"Thanks for joining — see you in 2027"*.

Long-press opens an **in-app date-override sheet** so judges (and CI) can verify every state without changing the system clock. **Where**: `34bd581`, `50a3ce7`, `22119db`, `67457cd`, `6d2b303`, `3ce4db2`.

### 7. Force-opaque nav / pinned-header bars where contrast matters; Liquid Glass where it doesn't

`Extensions/NavigationBar+Landscape.swift`, `MySchedule/MyScheduleView.swift`

iOS 26 navigation bars default to translucent material. Over light-coloured talk cards this produces ~3.0:1 contrast for the title and pinned section headers — below WCAG AA. The MySchedule nav bar is forced to `.toolbarBackground(.visible, for: .navigationBar)` over `Color(.systemBackground)` to keep the title readable. The pinned day header (`pinnedViews: .sectionHeaders`) uses `.ultraThinMaterial`, the lightest material that still degrades to opaque when `accessibilityReduceTransparency` is on. The Programme tab content, by contrast, **deliberately scrolls under** the floating Liquid Glass TabBar (`.ignoresSafeArea(.container, edges: .bottom)` on the inner page TabView) because that's what iOS 26 affordances are for, and there the content is large coloured cards — not 14-pt text.

The decision per surface is: **Liquid Glass when content is large enough to survive the contrast hit; opaque when small text would suffer.** **Where**: `2da8ff1`, `8b3ecf4`, `6c8b4f4`, `07681fb`, `c0a7a78`.

### 8. Offline-cached venue maps via `MKMapSnapshotter`

`MythConf/MythConf26/Locations/LocationMapSnapshotCache.swift`

At first launch, `MKMapSnapshotter` pre-renders light + dark map images for every venue and persists them to Application Support. When `NetworkMonitor` reports no connectivity, the Location detail screen swaps the live `Map` for the cached snapshot **and** shows an explicit *"No network — showing a saved snapshot of this map"* notice with a `wifi.slash` icon (Differentiate Without Color). Conference venues with poor Wi-Fi are the norm, not the exception, and **this is the moment users actually need wayfinding**. **Where**: `f808df3`.

---

## By judging criterion

### Vision (HIG)

- **Spoken time formatter** *(see Highlights §1)*.
- **`AStack` + `a11yLineLimit`** for Dynamic Type up to **AX5** *(see Highlights §5)*. The Session detail "time + venue" row goes further with `ViewThatFits`, reflowing to a vertical stack as soon as a long venue name would wrap — well before AX1 kicks in (`d73a77f`).
- **WCAG AA / AAA contrast pass across the app**:
  - `AccentColor` split into explicit light/dark variants. Dark mode reaches AAA (7.58:1) over pure black, AA (6.08:1) over the nav-bar dark grey, and AA (4.86:1) even over `.regularMaterial` dark (`a4d3929`). The original asset was empty and fell through to system blue, which only just passed AA over the nav bar.
  - **All secondary text replaced** with `Color.textSecondary` (light `#4D4D4D`, dark `#A8A8A8`) — 12 call sites converted from `.foregroundStyle(.secondary)`. The system `.secondary` is 3.44:1 over white (fails AA). The new colour is 8.45:1 (AAA) over white and **7.68:1 over the blue-tinted session card backgrounds** worst case (`369db39`).
  - **Lightning talks** dropped `.yellow` (≈1.6:1 over white) for an `accentYellow` asset (`#B07700` light = 4.7:1 AA; `#FFCC00` dark = 14:1 AAA) (`ae16999`).
  - **SwiftLint custom rule** `no_system_secondary_foreground_style` prevents the system `.secondary` from ever sneaking back in (`369db39`).
- **VoiceOver grouping & headings** — every session/speaker row is one combined VoiceOver element with a structured label (`title, by speakers, at location, n of m` for parallel slots); screen titles carry `.isHeader`; decorative icons are `.accessibilityHidden(true)`; the favourite star adds a `sparkles` overlay when filled so the state is visible without relying on colour alone (`a5f5482`).
- **Programme cards announce the slot kind first** — VoiceOver now reads *"Workshop, …"* or *"Session, …"* before the title, so users know what kind of slot they're sitting on before committing to a long talk title (`7a9724e`).
- **Per-surface Dynamic Type policy** — body content reflows up to AX5 via `AStack`. The persistent floating Programme banner is intentionally clamped at `.large` (`3ce4db2`) because it's an overlay with a fixed width: at AX5 it would consume half the screen and hide content beneath it. The same banner is also the densest information area (icon + title + subtitle + chevron), so its Dynamic Type ceiling is the **only** place in the app where readability and overlay obstruction trade off; everywhere else, AX5 wins.
- **Detail title behaviour** *(see Highlights §4)*.
- **Forced-opaque nav and pinned headers; Liquid Glass elsewhere** *(see Highlights §7)*.
- **Differentiate Without Color** — `SessionType` adds per-case SF Symbols (`6a7772c`), shown on talk cards and in the Programme banner. The favourite star adds a `sparkles` overlay when active, signalling state via shape, not just hue (`a5f5482`). The offline-map notice uses `wifi.slash` + text, not just colour (`f808df3`).

### Mobility (HIG)

- **Map accessibility representation** *(see Highlights §2)*.
- **Keyboard shortcuts** — `⌘1`/`⌘2`/`⌘3`/`⌘4` jump between Programme / Speakers / Locations / My Schedule. `⌘F` focuses speaker search. `⌘D` toggles favourite from the session detail screen. `⌥⌘←` / `⌥⌘→` flip Programme days. `⌘↑` / `⌘↓` jump the Speaker list to first/last. All implemented via hidden background buttons so the shortcuts surface in iOS's ⌘ long-press HUD without occupying visible UI (`b3501ae`, `8111573`).
- **44 × 44pt tap targets** — favourite button, language toggle, and every social link row are explicitly framed to 44pt with `contentShape(.rect)`. The favourite button's visible star stays small but the hit area is full 44 × 44 (`a5f5482`, `00d70e4`).
- **Horizontal swipe to switch Programme days** as an alternative to the segmented picker for users who find precise taps hard (`c858215`).
- **Favourite button moved to an overlay** so the parent `NavigationLink` no longer races for the tap event. ZStack siblings used to mean the favourite tap sometimes triggered the session-detail navigation; using `.overlay(alignment: .bottomTrailing)` resolves the race because SwiftUI overlays hit-test independently of the parent (`e6d7ecb`).
- **Explicit "tappable" affordances on SessionDetail** — the venue `NavigationLink` carries a small Liquid Glass disclosure chevron (`chevron.right` inside `.glassEffect(.regular, in: .circle)`) because, sitting inside a `.secondaryTextStyle()` parent, it would otherwise look like plain dim text. The speaker row inside SessionDetail carries the usual `chevron.right` because it's outside any `List` and would otherwise have no disclosure indicator. Both chevrons are `.accessibilityHidden(true)` — the `NavigationLink`'s button trait already speaks for itself (`6a13c3c`).
- **Custom `accessibilityInputLabels` everywhere** *(see Highlights §3)*.

### Cognitive (HIG)

- **Programme tab labels show "3 Thu", "4 Fri", "5 Sat", "6 Sun"**, not just "Day 1" / "Day 2". Users no longer need to remember which day is which (`d6c63ca`).
- **Pluralised VoiceOver session counts** — *"1 session"* / *"3 sessions"* via String Catalog substitutions (`3b37f05`).
- **Plural-aware countdown** — *"1 day until MythConf"* / *"5 days until MythConf"*; JA *"MythConfまであと%lld日"* (no plural inflection). Tied into Voice Control input labels too (`6d2b303`).
- **Empty-state for speaker search** — a `ContentUnavailableView` appears when a query returns nothing, rather than an inexplicably blank list (`a05e8cd`). VoiceOver reads "No search results. No speakers match \"<query>\"." instead of nothing.
- **Reactive conference banner** *(see Highlights §6)* — the user always knows *now what?* without computing time from the clock. During parallel slots, VoiceOver gets the entire track list in a single utterance so the user doesn't have to wait through the visual cycle.
- **Marquee text for overflowing titles** (`MarqueeText.swift`) — full-precision pure-SwiftUI implementation. Measures the natural text width with a hidden ghost view, animates only when the text actually overflows, **respects Reduce Motion** (static + truncate), respects Bold Text (`legibilityWeight` change re-measures), and uses a stable initial height anchor so the banner doesn't jump on first render (`22119db`).
- **Consistent terminology** — every favourite control accepts the same vocabulary; every "Open in Maps" affordance reads the same way; every external-link surface (social links, in-app browser) shows the same `arrow.up.right.square` indicator with the same VoiceOver hint *"Opens in browser"* (`b2b6f35`).
- **Title behaviour reduces "where am I?" friction** *(see Highlights §4)*.
- **In-app language toggle (EN ↔ JA)** *(see Cognitive → Localization below)*.

### Creativity

- **Offline venue maps via `MKMapSnapshotter`** *(see Highlights §8)*.
- **Programme Countdown Banner with parallel-talk cycling, Marquee text, and Reduce-Motion fallback** *(see Highlights §6)*.
- **Landscape-aware Location detail** — in landscape, the map and venue description sit side-by-side instead of one long vertical scroll, so two-handed users with a phone in landscape see both at once (`2481e00`).
- **Brand-aware social links** — `SocialLinksView` parses each URL, recognises GitHub / X / LinkedIn / Mastodon / Bluesky / YouTube, displays the real brand logo (with light/dark asset variants), and surfaces the *account handle* (e.g. `@alice`) rather than the bare hostname. VoiceOver announces *"GitHub account, alice"* instead of *"github.com slash alice"*. **Fixes a latent bug**: the bundled `conf.json` packs multiple URLs into a single newline-separated string, which `URL(string:)` returns nil for — so every speaker's social links were silently failing to render until this change (`cb17b8b`).
- **In-app language toggle (EN ↔ JA)** — `LanguageToggleButton` flips the SwiftUI `\.locale` environment at runtime, reloading both UI strings (`Localizable.xcstrings`) and the bundled session data (`conf-ja.json`). Hidden when the system language is already English so English users never see a no-op button. Voice Control accepts `"Japanese" / "日本語" / "Switch language" / "Toggle language" / "English" / "EN"` (`ab57a31`, `00d70e4`, `e4333c8`).
- **Date.formatted locale-injection fix** — `Date.formatted(.dateTime…)` defaults to `Locale.current` (the *device* locale), so the SwiftUI `\.locale` environment override was being ignored for weekday labels. Fixed by threading `@Environment(\.locale)` into `.locale(locale)` at every formatter call site — a one-line fix per site that single-handedly made the language toggle actually work for date strings (`e4333c8`).

### Quality

- **All accessibility logic lives behind small, reusable helpers** — `AStack`, `secondaryTextStyle()`, `a11yLineLimit(_:extra:)`, `String.spokenTime`, `landscapeHidesNavigationBar(_:)`, `languageToggleToolbar()`, `MarqueeText`, `glassEffect`. Adding a new screen does not require re-deriving these patterns.
- **No third-party dependencies.** Every change is plain SwiftUI / MapKit on the iOS 26 SDK.
- **Scope discipline** — the only non-a11y edits are `conf.json` date shifts to 2026-09-03..06 (otherwise the "is the conference now" detection breaks) and a one-line "MythConf 2027 → 2026" fix. No incidental refactors.
- **SwiftLint custom rule** prevents regression of the secondary-text contrast fix.
- **Testability of time-based UI** — `DateOverride` is a singleton `@Observable` that exposes a `now: Date` property. Every time-sensitive view (Programme banner, "is today's tab" detection, the day-picker auto-jump) reads `dateOverride.now` instead of `Date()`. A debug sheet (long-press the banner) lets you set the override at runtime — judges can verify every banner state without touching the system clock, and CI can write deterministic tests against the same hook (`34bd581`).
- **`MarqueeText` first-render height anchor fix** — the marquee was using `GeometryReader` for height measurement, which returns 0 on the first body evaluation, causing a one-frame collapse before settling. Fixed by anchoring the height to the natural text height via a hidden ghost (`22119db`).

### Overall experience

The app feels the same to a user with no assistive tech enabled — but unlocks an entirely different app for someone using VoiceOver, Voice Control, Switch Control, Full Keyboard Access, or AX5 Dynamic Type. The animations, gestures, and visual language are unchanged; the labels, focus order, adaptive layout, and content reactivity shift. The iOS 26 Liquid Glass surfaces have been placed deliberately: where they help (Programme content scrolls under the floating tab bar; the SessionDetail venue link uses a glass-effect chevron; MySchedule pinned headers use `.ultraThinMaterial`) and where they would hurt (the MySchedule nav bar stays opaque to protect title contrast).

Per `git diff --shortstat main..HEAD`: **+4,145 / −347** across **57 files**, but the cognitive surface for the original author is small — most of the change is *parameterising* existing views with a11y modifiers, not rewriting them.

---

## Bonus categories

### Hearing (+1)

- **Haptic feedback** — `.sensoryFeedback(.success, trigger: isFavourite)` on the favourite button so deaf/HoH users get a tactile confirmation that an action succeeded (`9d84aa8`).
- **Visual confirmation, not just colour** — the favourite star adds a `sparkles` overlay when active, signalling state via shape, not hue (`a5f5482`).
- **Offline notice** — when the cached map is shown, the screen displays an explicit captioned `Label` (`wifi.slash` icon + text) rather than a silent state change (`f808df3`).
- **External-link indicator** — social links carry an `arrow.up.right.square` icon next to the brand name to signal "this leaves the app" without an audio cue, paired with a VoiceOver `accessibilityHint("Opens in browser")` (`b2b6f35`).

### Speech (+1)

- **Voice Control aliases that match the visible label** *(see Highlights §3)*. The Programme picker accepts `"3 Thursday"` because that's literally what users see and what they will say — most apps would only register `"Day 1"`.
- **Brand-specific aliases for social links** — Voice Control accepts `"Twitter"` and `"Tweet"` for an X URL, `"Skeet"` and `"Bsky"` for Bluesky, `"Code"` and `"Source"` for GitHub. These are non-obvious but match how people actually speak about these services.
- **Bilingual aliases on the language toggle** — `"Japanese" / "日本語" / "English" / "EN" / "Switch language" / "Toggle language"` so users can speak the target language ("Tap Japanese" in English mode) or the action ("Tap Switch language") interchangeably (`00d70e4`).

---

## Changes, by commit (newest first)

Every entry in `git log main..HEAD` belongs to one of the rubric categories above. The order below is reverse-chronological so the most recent work surfaces first.

| Commit | Category | Summary |
|---|---|---|
| `07681fb` | Vision / Liquid Glass | MySchedule pinned day-header → `.ultraThinMaterial` (subtle frosted bar; degrades to opaque under Reduce Transparency) |
| `6d2b303` | Cognitive / i18n | Plural-aware "X days until MythConf" + JA translation (was "X days to go", which read "1 days to go" at d=1) |
| `b2b6f35` | Hearing / Mobility | Social links carry `arrow.up.right.square` external-link icon + VoiceOver hint `"Opens in browser"` |
| `6a13c3c` | Mobility | SessionDetail: explicit chevron disclosure on speaker rows; Liquid Glass circular chevron on venue link (sits inside `.secondaryTextStyle()`, so default tint is suppressed) |
| `3ce4db2` | Vision | Programme banner clamped to `.large` Dynamic Type (overlay surface; everywhere else stays up to AX5) |
| `c0a7a78` | Vision / Liquid Glass | Programme content scrolls under the floating Liquid Glass TabBar (was VStack-stacked; now ZStack-style overlap) |
| `67457cd` | Cognitive | Banner title shows "Day X · 4 September Friday" (was just "Day X") |
| `22119db` | Quality | `MarqueeText` initial-height anchor fix (one-frame collapse before settling) |
| `50a3ce7` | Cognitive / Creativity | Banner cycles through parallel talks; Reduce Motion → static "N parallel talks" summary; VoiceOver gets the full list in one utterance |
| `34bd581` | Quality / Creativity | Programme Countdown Banner + `DateOverride` debug sheet (long-press the banner) |
| `ad7c3a8` | Vision | Favourite star follows Dynamic Type via `@ScaledMetric` |
| `6a7772c` | Vision / DWC | Programme cards add per-`SessionType` SF Symbol (was colour-only) |
| `7a9724e` | Cognitive | Talk cards announce "Workshop, …" / "Session, …" before the title |
| `d73a77f` | Vision | SessionDetail time/venue row reflows when venue name overflows (`ViewThatFits`) |
| `2b31c19` | (merge) | merge `akidon0000/iosdevuk-a11y-2026` |
| `84ab3e4` | Speech / i18n | Voice Control input labels: JA translations |
| `e6d7ecb` | Mobility | Favourite button → `.overlay` instead of ZStack sibling (fixes the NavigationLink hit-test race) |
| `7615f55` | Cognitive / i18n | Programme tab date labels follow the in-app locale toggle |
| `5631e72` | Comprehensive | (squashed) baseline comprehensive accessibility pass |
| `c87c273` | (merge) | merge language-toggle 44pt work |
| `af34c63` | Speech / i18n | Pick up auto-extracted strings from language toggle |
| `e4333c8` | Cognitive / i18n | `Date.formatted` now respects the SwiftUI `\.locale` override at every weekday/month site |
| `6c8b4f4` | Vision | MySchedule nav bar opaque (preserves title contrast over light cards) |
| `8b3ecf4` | Vision | MySchedule pinned day header opaque (re-apply) |
| `2da8ff1` | Vision | MySchedule nav bar forced opaque |
| `a05e8cd` | Cognitive | `ContentUnavailableView` for empty speaker search |
| `413ef97` | Speech | Programme picker accepts `"3 Thursday"` as Voice Control input |
| `d6c63ca` | Cognitive | Programme tab labels show day-of-month + weekday (`3 Thu`) |
| `8111573` | Mobility | `⌘1–⌘4` tabs, `⌘F` search, `⌘D` favourite, `⌥⌘←/→` days, `⌘↑/↓` list jump |
| `3b37f05` | Cognitive | Pluralise VoiceOver session count |
| `00d70e4` | Mobility / Speech | Language toggle 44×44pt + Voice Control labels |
| `e546078` | Quality | Session timestamps shifted to 2026-09-03..06 |
| `05e5c36` | Mobility | TabView rebuild on rotation (re-computes tab item widths) |
| `d739a83` | Quality | Year inconsistency 2027 → 2026 |
| `ab57a31` | Cognitive / i18n | In-app EN/JA toggle + JA content (`conf-ja.json`) |
| `2bdcf90` | Cognitive / i18n | Localize UI + a11y labels to JA |
| `cb17b8b` | Cognitive / Creativity | Brand logos + account handles in speaker social links (also fixes the newline-separated URL bug) |
| `f808df3` | Creativity / Hearing | Cache venue maps offline via `MKMapSnapshotter`; explicit "no network" notice |
| `d0ec3c9` | Speech | Voice Control input labels across the app |
| `a4d3929` | Vision | `AccentColor` light/dark for AAA on dark mode |
| `2481e00` | Creativity | LocationDetail map + description side-by-side in landscape |
| `07af79e` | Mobility | Landscape hides root tab nav bars; portrait forces opaque background |
| `c858215` | Mobility | Swipe to switch Programme days |
| `a5f5482` | Mobility / DWC | Favourite tap target 44×44 + `sparkles` overlay for "saved" without colour |
| `9d84aa8` | Hearing | Favourite haptic + shorter VoiceOver label |
| `4228532` | Vision | Complete VoiceOver row-grouping polish |
| `b9532e8` | Vision / Cognitive | Detail-screen titles fade into the nav bar on scroll |
| `678266a` | Vision / Cognitive | Detail-screen titles move into the body header |
| `ab4ddf3` | Vision | Speak times as 12h AM/PM via `String.spokenTime` |
| `38ef0fc` | Mobility | Replace Map VoiceOver representation with Open-in-Maps button |
| `2b63950` | Vision / Cognitive | VoiceOver row grouping + heading navigation |
| `5166be3` | Vision | Dynamic Type up to AX5 (`AStack`, `a11yLineLimit`, `@ScaledMetric`) |
| `369db39` | Vision | Secondary text → WCAG AAA (`textSecondary` asset + SwiftLint guard) |

---

## What's intentionally not included

- **VoiceOver Rotor custom items** — explored but cut. The bundled programme is small enough that a Rotor adds navigation noise rather than removing it; the existing heading-based VoiceOver structure is faster for the data volume. The Programme banner *does* effectively act as a "now playing" anchor, which covers the same use case in a more discoverable form. Happy to add if judges feel otherwise.
- **Custom Actions on favourite rows** — the favourite control is a single 44 × 44pt button on every row, so wrapping it in a Custom Action duplicates rather than simplifies. Custom Actions *are* used on the Programme banner for `Open date override`.
- **Switch Control automated tests** — manual verification only; not enough time to wire up an automated harness this round.
- **iPhone PortraitUpsideDown** — explicitly omitted in the Info.plist per Apple's HIG guidance for Face ID devices. Other landscape orientations are supported.

---

## File map

```
MythConf/MythConf26/
├── Extensions/
│   ├── AStack.swift                       ← HStack/VStack adaptive container
│   ├── Color+A11y.swift                   ← secondaryTextStyle, a11yLineLimit
│   ├── NavigationBar+Landscape.swift      ← opaque/hidden bars per orientation
│   └── Time+A11y.swift                    ← String.spokenTime (24h → 12h AM/PM)
├── LanguageToggleButton.swift             ← EN↔JA in-app toggle (Voice Control labels)
├── Localizable.xcstrings                  ← full JA localisation incl. plurals
├── Locations/
│   ├── LocationDetailView.swift           ← Map a11y representation, landscape split
│   └── LocationMapSnapshotCache.swift     ← offline map cache (MKMapSnapshotter)
├── Model/
│   ├── DateOverride.swift                 ← time-travel hook (banner debug + tests)
│   ├── NetworkMonitor.swift               ← drives the offline-map fallback
│   └── conf-ja.json                       ← Japanese session/speaker copy
├── MySchedule/MyScheduleView.swift        ← .ultraThinMaterial pinned header, opaque navbar
├── Programme/
│   ├── DebugDateOverrideSheet.swift       ← long-press banner to time-travel
│   ├── MarqueeText.swift                  ← Reduce-Motion-aware scrolling text
│   ├── ProgrammeCountdownBanner.swift     ← live banner: before/during/parallel/after
│   └── ProgrammeView.swift                ← swipe days, scroll under TabBar, picker labels
├── SessionDetailView.swift                ← chevron affordances + locationLinkLabel
├── Speakers/SocialLinksView.swift         ← brand-aware social link rendering + external-link icon
└── HomeView.swift                         ← ⌘1–⌘4 tab shortcuts, rotation rebuild
.swiftlint.yml                             ← custom rule blocks `.foregroundStyle(.secondary)`
```

---

Thank you for considering this submission. Every change exists because I tried the app with the matching assistive technology enabled and found something that was less than dignified — the goal was to fix the friction, not to tick boxes. The fact that iOS 26 ships with Liquid Glass turned out to be a useful constraint: it forced explicit per-surface contrast decisions instead of leaving them to defaults.
