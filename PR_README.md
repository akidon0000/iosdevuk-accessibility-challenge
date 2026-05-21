# MythConf26 Accessibility Submission — iOSDevUK 2026

> **TL;DR** — Inclusive design across **Vision · Mobility · Cognitive**, with bonus coverage for **Hearing · Speech**. Highlights worth a second look: a **spoken-time formatter** so VoiceOver never says "fourteen thirty", a **substituted Map accessibility representation** that replaces an unusable MapKit a11y tree with one tappable target, **offline-cached venue maps**, **Voice Control aliases that match what users see on screen**, and a custom **`AStack`** layout that quietly carries 50+ views to **AX5** Dynamic Type.

This PR is intentionally one squashed commit so the surface area is easy to review. A few choices look small at a glance but materially change how the app works with assistive tech — those are called out first under each rubric so they don't get missed.

---

## How to evaluate quickly

1. **VoiceOver, Programme tab** — swipe down a session, then double-tap the time. You should hear *"two thirty PM"*, not *"fourteen thirty"*. See **Vision → Spoken time**.
2. **Voice Control** — say *"3 Thursday"* on the Programme picker (you'll see those exact words on screen). See **Speech → Aliases that match the visible label**.
3. **Switch Control or VoiceOver, Locations detail** — there is exactly **one** focusable map target labelled *"Open in Maps: \<venue\>"*. See **Mobility → Map accessibility representation**.
4. **Airplane mode → Locations** — the venue map is still visible from a cached snapshot. See **Creativity → Offline venue maps**.
5. **Settings → Accessibility → Larger Text → AX5** — every screen reflows cleanly; nothing clips. See **Vision → AStack / Dynamic Type**.
6. **Full Keyboard Access + Hardware keyboard** — `⌘1`–`⌘4` jump tabs, `⌘F` focuses search. See **Mobility → Keyboard**.

---

## Highlights judges may otherwise miss

These are the four or five decisions I'd love judges to look at most closely. They are small in diff size but disproportionately big in lived experience.

### 1. `String.spokenTime` — VoiceOver never reads a 24h clock

`MythConf/MythConf26/Extensions/Time+A11y.swift`

VoiceOver, by default, reads `"14:30"` aloud as **"fourteen thirty"** — not a time. The bundled session data is in 24h format. A one-line `.accessibilityLabel(time.spokenTime)` rewrites it to `"2:30 PM"` regardless of the user's locale or 24-hour setting, so the screen reader always says a real time-of-day. This applies to every session row, the parallel-track grid, and the detail view.

### 2. Map's accessibility tree is replaced, not patched

`MythConf/MythConf26/Locations/LocationDetailView.swift` (`accessibilityRepresentation`)

`Map` in SwiftUI exposes a deep, panning, zooming a11y tree. For Switch Control / VoiceOver users that tree is essentially noise — they cannot meaningfully pan a map with a single switch. The map is therefore wrapped in `.accessibilityRepresentation { Button("Open in Maps: <venue>") { … } }`, so assistive tech sees **one** crisp target that hands off to Apple Maps (which is itself accessible). Sighted users still get the full interactive map.

### 3. Voice Control aliases match what users *see*

Across the app (`Programme/ProgrammeView.swift`, `Speakers/SpeakersView.swift`, `Favourites/FavouriteButtonView.swift`, `Locations/LocationDetailView.swift`, `LanguageToggleButton.swift`, …) every interactive control has multiple `.accessibilityInputLabels([…])` entries. The principle is **Voice Control users say what's on screen, not what the developer named it**:

- Programme picker tabs accept `"3 Thursday"`, `"3 Thu"`, `"Thursday"`, `"Thu"`, and `"Day 1"` — the first form is what the segmented label literally renders.
- The favourite star accepts `Favourite / Favorite / Star / Bookmark / Save / Add to schedule / Remove from schedule`.
- Social link buttons accept the actual `@handle` parsed out of the URL.

Almost every iOS app I tested either has no `accessibilityInputLabels` or has only one — and you cannot guess that the visible tab "3 Thursday" was originally coded as `Day 1`.

### 4. Detail screen titles: large body header → inline on scroll

`Programme/SessionDetailView.swift`, `Speakers/SpeakerDetailView.swift`, `Locations/LocationDetailView.swift`

Default SwiftUI navigation either gives a `.large` title (which jumps awkwardly under Dynamic Type) or an `.inline` title that gets lost when the user can't fit the whole title in the nav bar. The title is therefore rendered in the **body** as a heading (`.accessibilityAddTraits(.isHeader)`), and an inline copy slides into the nav bar **only after the body title scrolls off-screen** (`onScrollVisibilityChange`). VoiceOver gets one heading, never two; sighted users always know where they are.

### 5. `AStack` — Dynamic Type at AX5 without per-view rewrites

`MythConf/MythConf26/Extensions/AStack.swift`

A view that lays out as `HStack` at standard sizes and switches to `VStack` at AX1+. Every row, card, and chip in the app that has an icon + text pair uses `AStack` instead of `HStack`, so they all gracefully reflow at the largest accessibility sizes without bespoke layout code at each call site. Paired with `a11yLineLimit(_:extra:)` in `Color+A11y.swift` for text that should be allowed extra wrapping at AX sizes.

### 6. Force-opaque nav / tab bars when content scrolls underneath

`Extensions/NavigationBar+Landscape.swift`, `MySchedule/MyScheduleView.swift`

iOS 26 navigation bars default to translucent material. Over light-coloured cards this produces ~3.0:1 contrast for the title and pinned headers — below WCAG AA. Both the My Schedule pinned-day header and root-tab nav bars are forced to `.toolbarBackground(.visible)` (opaque) so titles remain legible while scrolling. In landscape, root-tab nav bars are hidden entirely (`landscapeHidesNavigationBar`) to give low-vision users every available vertical pixel.

---

## By judging criterion

### Vision (HIG)

- **Spoken time formatter** *(see Highlights §1)*.
- **`AStack` + `a11yLineLimit`** for Dynamic Type up to **AX5** *(see Highlights §5)*. The Session detail "time + venue" row goes a step further with `ViewThatFits`, reflowing to a vertical stack as soon as a long venue name would wrap — well before AX1 kicks in (`d73a77f`).
- **WCAG AA / AAA contrast** — `AccentColor` is split into light/dark variants (`a4d3929`) so the brand colour reaches AAA on dark mode; secondary text is replaced with a `textSecondary` colour that passes AA (`369db39`); lightning-talk yellow uses an `accentYellow` asset rather than `Color.yellow`.
- **VoiceOver grouping & headings** — every session/speaker row is one combined VoiceOver element with a structured label; screen titles are `.isHeader`; decorative icons are `.accessibilityHidden(true)`.
- **Programme cards announce the slot kind first** — VoiceOver now reads *"Workshop, …"* or *"Session, …"* before the title, so users know what kind of slot they're sitting on before committing to listen to a long talk title (`7a9724e`).
- **Differentiate without colour** — the favourite star adds a `sparkles` overlay when filled, so the on/off state is visible without relying on colour alone.
- **Detail title behaviour** *(see Highlights §4)*.
- **Forced-opaque bars** *(see Highlights §6)*.

### Mobility (HIG)

- **Map a11y representation** *(see Highlights §2)*.
- **Keyboard shortcuts** — `⌘1`/`⌘2`/`⌘3`/`⌘4` jump between Programme / Speakers / Locations / My Schedule (`HomeView.swift`). `⌘F` focuses search in Speakers. Implemented via hidden background buttons so the shortcuts work app-wide without occupying any visible UI.
- **44×44pt tap targets** — favourite button, language toggle, and all social link rows are explicitly framed to 44pt with `contentShape(.rect)`.
- **Horizontal swipe to switch Programme days** *(`c858215`)* as an alternative to the segmented picker for users who find precise taps hard.
- **Custom `accessibilityInputLabels` everywhere** *(see Highlights §3)*.

### Cognitive (HIG)

- **Programme tab labels show "3 Thu", "4 Fri"…**, not just "Day 1" / "Day 2" — users no longer need to remember which day is which (`d6c63ca`).
- **Pluralised VoiceOver session counts** — *"1 session"* / *"3 sessions"* rather than *"3 session"* (`3b37f05`).
- **Empty-state for speaker search** — a `ContentUnavailableView` appears when a query returns nothing, instead of an inexplicably blank list (`a05e8cd`).
- **Consistent terminology** — every favourite-related control accepts the same alias vocabulary (`Favourite / Favorite / Star / Bookmark / Save / Add to schedule / Remove from schedule`), and every "Open in Maps" affordance reads the same way.
- **Title behaviour reduces "where am I?" friction** *(see Highlights §4)*.

### Creativity

- **Offline venue maps via `MKMapSnapshotter`** — `LocationMapSnapshotCache` pre-renders light + dark map images at first launch and persists them to Application Support. When `NetworkMonitor` reports no connectivity, the Location detail screen swaps the live `Map` for the cached snapshot **and** shows an explicit "No network — showing a saved snapshot" notice. Conference venues with poor Wi-Fi are the norm, not the exception, and this is the moment users actually need wayfinding.
- **Landscape-aware Location detail** — in landscape, the map and venue description sit side-by-side instead of one long vertical scroll, so two-handed users with a phone in landscape mode see both at once (`2481e00`).
- **Brand-aware social links** — `SocialLinksView` parses each URL, recognises GitHub / X / LinkedIn / Mastodon / Bluesky / YouTube, displays the real brand logo (with light/dark asset variants), and surfaces the *account handle* (e.g. `@alice`) rather than the bare hostname. VoiceOver announces *"GitHub account, alice"* instead of *"github.com slash alice"*.
- **In-app language toggle (EN ↔ JA)** — `LanguageToggleButton` flips the SwiftUI `\.locale` environment at runtime, reloading both UI strings (`Localizable.xcstrings`) and the bundled session data (`conf-ja.json`). The control is hidden when the system language is already English, so English users never see a no-op button. Voice Control accepts `"Japanese" / "日本語" / "Switch language" / "Toggle language" / "English" / "EN"`.

### Quality

- **All accessibility logic lives behind small, reusable helpers** — `AStack`, `secondaryTextStyle()`, `a11yLineLimit(_:extra:)`, `String.spokenTime`, `landscapeHidesNavigationBar(_:)`, `languageToggleToolbar()`. Adding a new screen does not require re-deriving these patterns.
- **No third-party dependencies.** Every change is plain SwiftUI / MapKit on the iOS 26 SDK.
- **Scope discipline** — the only non-a11y edits are `conf.json` date shifts to 2026-09-03..06 (otherwise the "is the conference now" detection breaks) and a one-line MythConf year fix. No incidental refactors.
- **SwiftLint config added** so the codebase has a baseline style guard going forward.

### Overall experience

The app feels the same to a user with no assistive tech enabled — but unlocks an entirely different app for someone using VoiceOver, Voice Control, Switch Control, Full Keyboard Access, or AX5 Dynamic Type. The animations, gestures, and visual language are unchanged; only the labels, focus order, and adaptive layout shift.

Per `git diff --shortstat`: **+3,109 / −335** across **50 files**, but the cognitive surface for the original author is small — most of the change is *parameterising* existing views with a11y modifiers, not rewriting them.

---

## Bonus categories

### Hearing (+1)

- **Haptic feedback** — `.sensoryFeedback(.success, trigger: isFavourite)` on the favourite button so deaf/HoH users get a tactile confirmation that an action succeeded (`9d84aa8`).
- **Visual confirmation, not just colour** — the favourite star adds a `sparkles` overlay when active, signalling state via shape, not hue (`a5f5482`).
- **Offline notice** — when the cached map is shown, the screen displays an explicit captioned `Label` rather than a silent state change (`f808df3`).

### Speech (+1)

- **Voice Control aliases that match the visible label** *(see Highlights §3)*. The Programme picker accepts `"3 Thursday"` because that's literally what users see and what they will say — most apps would only register `"Day 1"`.
- **Brand-specific aliases for social links** — Voice Control accepts `"Twitter"` and `"Tweet"` for an X URL, `"Skeet"` and `"Bsky"` for Bluesky, `"Code"` and `"Source"` for GitHub. These are non-obvious but match how people actually speak about these services.

---

## What's intentionally not included

- **VoiceOver Rotor custom items** — explored but cut. The bundled programme is small enough that a Rotor adds navigation noise rather than removing it; the existing heading-based VoiceOver structure is faster for the data volume in this app. Happy to add if judges feel otherwise.
- **Custom Actions on favourite rows** — same reason: the favourite control is a single, 44×44pt button on every row, so wrapping it in a Custom Action duplicates rather than simplifies.
- **Switch Control automated tests** — manual verification only; not enough time to wire up an automated harness this round.

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
├── Localizable.xcstrings                  ← full JA localisation
├── Locations/
│   ├── LocationDetailView.swift           ← Map a11y representation, landscape split
│   └── LocationMapSnapshotCache.swift     ← offline map cache (MKMapSnapshotter)
├── Model/
│   ├── NetworkMonitor.swift               ← drives the offline-map fallback
│   └── conf-ja.json                       ← Japanese session/speaker copy
├── Programme/                             ← swipe to switch days, spoken times,
│                                            grouped VoiceOver rows
├── Speakers/SocialLinksView.swift         ← brand-aware social link rendering
└── HomeView.swift                         ← ⌘1–⌘4 tab shortcuts, rotation rebuild
```

---

Thank you for considering this submission. Every change here exists because I tried the app with the matching assistive technology enabled and found something that was less than dignified — the goal was to fix the friction, not to tick boxes.
