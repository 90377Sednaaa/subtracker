# Subly Design System & UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the placeholder UI from the architecture plan with the Subly identity: a **monochrome dark ledger** (warm white on near-black, light "warm paper" as secondary) with cinematic-calm motion, three hand-built animation set pieces, and a Lucide/monogram brand layer.

**Architecture relationship:** This plan implements the design phase promised in `2026-09-06-subly-mvp.md`. It touches **only** `lib/core/theme.dart`, `lib/core/brand/`, UI files, and `pubspec.yaml` — no logic or data-layer rewrites. Exactly one schema addition is required (a nullable `brandColor` field, D5), which is backward-compatible with the architecture plan's Firestore model.

**Tech Stack (added):** google_fonts · flutter_animate · flutter_svg · flutter_lucide · flutter_launcher_icons (dev)

**Spec:** The design grill of 2026-09-06 (11 decisions, recorded in "Locked Decisions" below).

## Locked Decisions

| Area | Decision |
|---|---|
| Personality | **Quiet luxury ledger** — calm, spacious, editorial; NOT fintech control room, NOT playful consumer |
| Theme | **Dark default** (fresh install opens dark); light "warm paper" theme ships alongside; both from one token sheet |
| Color voice | **Monochrome: dark & white.** No emerald, no gold. Subly's own "accent" is warm white ink; hierarchy via light-vs-shadow |
| The one thread of color | Per-subscription **brand colors** (Netflix red, Spotify green…) as small marks + **muted status tints** — the only chroma in the UI |
| Typography | **Space Grotesk** (display, money numbers) + **Inter** (body, tabular figures) via google_fonts |
| Motion engine | **Pure Flutter** — flutter_animate choreography + CustomPainter set pieces + flutter_svg statics. No Rive, no Lottie |
| Motion feel | **Cinematic calm**: 250–700ms ease-out, no bounce, 40ms stagger + **haptic ticks** on save/limit/unlock |
| Ambience | **Flat surfaces + hairlines + exactly one glow** (faint white radial behind the hero number) |
| Hero moments | 3 set pieces: **SP1** count-up hero total + pace ring, **SP2** staggered list + card morph, **SP3** paywall reveal |
| Layout | Dashboard = **hero total → renewal strip → ledger list** (story order: what I spend → what's about to hit → everything I own) |
| Icons & mark | **Lucide** 2px-stroke icons + code-drawn **monogram mark** + programmatic app icon |

## Design Principles (anti-slop guardrails)

1. **Monochrome discipline.** If a screen needs color to work, the layout is wrong. Color appears only as brand dots and status tints.
2. **Hierarchy by light, not by hue.** Near-black surface steps + warm-white text tiers do all the work a rainbow would do in a generic app.
3. **No glass, no gradient cards, no neon.** Flat surfaces, 1px hairlines at 6–8% opacity, one radial glow on the whole app.
4. **Space is the luxury.** Generous padding (24px screen margins), tall list rows (72px+), nothing cramped.
5. **Money is set in Space Grotesk with tabular figures** — always aligned, never comic, never tiny.
6. **Motion reveals, never entertains.** Every animation answers "what changed?" — nothing loops for attention except nothing.
7. **One font pair, one radius story, one elevation story.** Consistency is the premium signal.
8. **Both themes from one token sheet.** A screen that hardcodes a hex is a bug.

## Color Tokens

### Dark (default) — "the night ledger"

| Token | Value | Usage |
|---|---|---|
| `surface.base` | `#0A0A0C` | Scaffold background |
| `surface.step1` | `#131316` | Cards |
| `surface.step2` | `#1A1A1F` | Elevated cards, sheets |
| `surface.step3` | `#232329` | Dialogs, paywall card |
| `hairline` | `#FFFFFF` @ 7% | 1px borders, dividers |
| `ink.primary` | `#F2F0EB` | Headlines, money numbers (warm white) |
| `ink.secondary` | `#A6A399` | Body, subtitles (warm gray) |
| `ink.tertiary` | `#6E6B63` | Captions, disabled |
| `ink.inverse` | `#141412` | Text on filled-white CTAs |
| `cta.fill` | `#F2F0EB` | Primary buttons (white fill, `ink.inverse` label) |
| `glow` | `#F2F0EB` @ 8% | The single radial behind the hero |
| `status.renewalSoon` | `#D9B380` | "Renews in 2 days" tint (muted amber) |
| `status.trial` | `#C77E6E` | Trial-ending tint (muted clay) |
| `status.settled` | `#8FA98F` | Paid/active tint (muted sage) |

### Light (secondary) — "warm paper"

| Token | Value | Usage |
|---|---|---|
| `surface.base` | `#F5F3EE` | Scaffold background |
| `surface.step1` | `#FBFAF7` | Cards |
| `surface.step2` | `#FFFFFF` | Elevated cards |
| `surface.step3` | `#FFFFFF` | Dialogs (add hairline) |
| `hairline` | `#141412` @ 8% | 1px borders, dividers |
| `ink.primary` | `#1A1915` | Headlines, money numbers |
| `ink.secondary` | `#6B6860` | Body |
| `ink.tertiary` | `#A19D93` | Captions, disabled |
| `ink.inverse` | `#F5F3EE` | Text on filled-black CTAs |
| `cta.fill` | `#1A1915` | Primary buttons (black fill) |
| `glow` | `#1A1915` @ 4% | Hero radial (barely there in light) |
| `status.renewalSoon` | `#9A7434` | Muted amber-ink |
| `status.trial` | `#A65445` | Muted clay-ink |
| `status.settled` | `#5E7A5E` | Muted sage-ink |

### Brand colors (the one thread of chroma)

Used ONLY as: an 8px dot on ledger cards, a 3px left edge on renewal-strip chips, and tiny segments in the totals ring. Never as fills, never as text.

| Service | Hex | | Category fallback | Hex |
|---|---|---|---|---|
| Netflix | `#E50914` | | Streaming | `#C96B6B` |
| Spotify | `#1DB954` | | Music | `#6FA97C` |
| Disney+ | `#113CCF` | | Productivity | `#7C93BE` |
| YouTube Premium | `#FF0033` | | Gaming | `#A08BC0` |
| Amazon Prime | `#00A8E1` | | Books | `#C09878` |
| Microsoft 365 | `#D83B01` | | Storage | `#78A0AC` |
| Adobe CC | `#FA0F00` | | Shopping | `#B8A878` |
| Xbox Game Pass | `#52B043` | | Design | `#78A8A0` |
| Dropbox | `#0061FF` | | Other | `#8C8C8C` |
| Canva | `#00C4CC` | | | |
| Audible | `#F8991C` | | | |
| iCloud+ | `#A2AAAD` | | | |

Matching is **case-insensitive substring match on the subscription name** at save time (`netflix` → Netflix red); no match → category fallback; no category → `Other` gray. Result is stored as `brandColor` (nullable `String` hex) on the subscription document — see D5.

## Typography (Space Grotesk + Inter)

| Role | Font | Size/Weight | Notes |
|---|---|---|---|
| Hero money | Space Grotesk | 56 / w500, ls −1.5% | Tabular figures (`FontFeature.tabularFigures()`), the app's face |
| Title L | Space Grotesk | 24 / w500 | Screen titles, paywall headline |
| Title M | Space Grotesk | 20 / w500 | Card totals |
| Money row | Inter | 16 / w500, tabular | Right-aligned card costs |
| Body | Inter | 15 / w400 | Descriptions, subtitles |
| Label | Inter | 13 / w500, ls +2% | Section labels ("THIS MONTH", "NEXT 7 DAYS"), uppercase |
| Caption | Inter | 11 / w400 | Footnotes, trial fine print |

Loaded via `google_fonts` (bundled at build time with `GoogleFonts.config.allowRuntimeFetching = false` for offline demos).

## Spacing, Radius, Elevation

- **Spacing scale:** 4 / 8 / 12 / 16 / 24 / 32 / 48 / 64. Screen margin 24, card padding 16, list-row height 76.
- **Radius:** cards 16, sheets 24, buttons/fields 14, chips & dots pill.
- **Elevation: zero shadows.** Depth = surface steps + hairlines only (both themes).

## Motion Tokens

| Token | Value | Used for |
|---|---|---|
| `dur.instant` | 100ms | State feedback (switches, presses) |
| `dur.quick` | 250ms | Hovers, chips, small fades |
| `dur.base` | 320ms | Screen transitions, card entrance |
| `dur.slow` | 480ms | Paywall reveal stages |
| `dur.hero` | 700ms | Count-up (SP1) |
| `curve.standard` | `Curves.easeOutCubic` | Everything default |
| `curve.emphasized` | `Curves.easeInOutCubicEmphasized` | Card morph (SP2) |
| `stagger` | 40ms | List entrance |
| Haptics | `HapticFeedback.selectionClick` | Save success, add-sub tapped; `heavyImpact` limit-reached; `mediumImpact` premium-unlocked |

Screen transitions: `fade-through` feel via flutter_animate (out 100ms fade, in 250ms fade+4dp slide). No bounce anywhere.

## Set-Piece Specs

### SP1 — Count-up hero + pace ring (dashboard)
- **Composition:** full-width header block: label "THIS MONTH" (Label style, tertiary) → hero money (animating) → caption "≈ {annual}/year across {n} subscriptions" → pace ring 120px at the right edge behind/next to the number → faint radial glow (8% white, radius ~160dp) centered on the number.
- **Ring:** `CustomPainter`, background arc = `hairline` 3px stroke; foreground arc = `ink.primary` 3px round-cap stroke sweeping the fraction of the billing month elapsed; 480ms `easeOutCubic` sweep on load. If all subs are annual-only, ring shows days-into-current-year fraction.
- **Count-up:** `TweenAnimationBuilder<double>` 0→monthlyTotal, `dur.hero`, `easeOutCubic`; format with `NumberFormat.simpleCurrency(decimalDigits: 2)`; tabular figures prevent layout jitter.
- **Acceptance:** number visibly counts; ring draws once; zero layout shift when count-up ends; glow is subtle (barely-there on light theme).

### SP2 — Staggered ledger + card morph (dashboard → edit)
- **Entrance:** on dashboard data-load, cards fade+slide-up 12dp, `dur.base`, 40ms stagger, first card starts immediately after SP1's ring (choreographed handoff).
- **Morph:** ledger card and edit screen share a `Hero` tag `sub-{id}`; the card's name/cost block morphs into the edit screen's header. Edit screen background is `surface.base`, giving a seamless expansion feel.
- **Acceptance:** 60fps on a mid-range device (`flutter run --profile`, check DevTools timeline); stagger total ≤ 400ms for 5 cards; morph doesn't flash the scaffold.

### SP3 — Paywall reveal
- **Stages (all `easeOutCubic`):** (1) headline "Subly Premium" fades up at 0ms, `dur.slow`; (2) feature rows cascade 60ms apart from 150ms (each: fade + 8dp slide); (3) a white light-sweep (linear gradient band, 15% white, 24° tilt) travels across the premium badge once at 500ms, 600ms duration; (4) CTA (white fill, black "Unlock — $1.99/mo") fades up last at 700ms + `mediumImpact` haptic on tap.
- **Acceptance:** sweep runs exactly once (not looping); stages total ≤ 1.2s; nothing bounces.

### Everything else (subtle standard motion)
Empty state: fade+slide (no self-drawing set piece — not selected). Form: fields stay static, segmented cycle selector slides thumb `dur.instant`. Directory/settings: default transitions only.

## Brand Layer

- **Icons:** `flutter_lucide` 2px-stroke, 20dp in lists / 24dp in app bars, `ink.secondary` (primary actions `ink.primary`). Mapping: add→`plus`, dashboard→`layout-list`, directory→`link-2`, settings→`settings-2`, edit→`pencil-line`, delete→`trash-2`, trial→`hourglass`, renewal→`calendar-clock`, premium→`gem`, export→`download`.
- **Monogram mark:** ledger-style "S" — an S-path drawn as a 2.5dp stroke with a horizontal baseline rule crossing under it (the "ledger line"), `ink.primary` on `surface.base`. Implemented once as `SublyMark` (`CustomPainter`, ~40 lines, parameterized size/stroke) so it renders crisply at any size.
- **Sign-in screen:** mark at 96dp centered → "Subly" in Space Grotesk Title L below → caption "Know where your money recurs." → white CTA "Continue with Google" 56dp tall, full-width, 24dp margins.
- **App icon:** black `#0A0A0C` rounded-square, white S-mark centered at 60% size. Generate all densities with `flutter_launcher_icons` (dev dependency) from a single 1024px SVG→PNG render; splash disabled (not in scope).

## Component Specs (key geometry)

- **Ledger card:** `surface.step1`, hairline border, radius 16, padding 16, height ~76. Left: 8px brand dot (2px off-center top) above service name (Title M weight 400). Subtitle (Body, secondary): "Renews {date} · {cycle}" or trial variant with `status.trial` tint. Right: cost (Money row) + caption cycle. Tap → SP2 morph.
- **Renewal strip:** label "NEXT 7 DAYS" → horizontal row of chips (`surface.step2`, radius pill, 12px padding): weekday letter (tertiary) + day number (Title M) + name (caption) + amount (money row, tabular). Chip gets a 3px left brand-color edge; chips <3 days out get a `status.renewalSoon` hairline instead of white. Empty state: single caption "Nothing renews this week."
- **Segmented cycle selector (form):** 3 segments (Weekly/Monthly/Annual), `surface.step1` track, selected segment = `cta.fill` fill with `ink.inverse` text, thumb slides `dur.instant`.
- **Totals presentation:** when multiple currencies exist, hero shows the currency with the largest total; additional currencies appear as secondary rows ("EUR 9.99/mo") in Title M — per architecture plan, no conversion ever.

## Implementation Tasks

Each task ends with `flutter analyze` clean + tests passing + commit. All tasks also require the **theme checklist**: screen renders correctly in BOTH themes (toggle via settings debug switch added in D1).

### D1: Token foundation — `lib/core/theme.dart` rewrite
Create `SublyColors` ThemeExtension (all color tokens above), `SublyTypography` (the 7 text roles via google_fonts), `SublyMotion` (duration/curve/stagger constants), dark + light `ThemeData` factories wired to `MaterialApp.router`, theme-mode controller (Provider, dark default, debug toggle in Settings). **Verify:** both themes compile; fonts render offline (airplane-mode test); zero hardcoded colors remain in existing screens (fix dashboard/pass-throughs to read tokens).

### D2: Brand layer — package + mark + icon
`flutter pub add google_fonts flutter_animate flutter_svg flutter_lucide` + `flutter pub add -d flutter_launcher_icons`. Build `SublyMark` painter + `BrandDot` widget; sign-in screen restyle per spec; app icon generation + `flutter_launcher_icons.yaml`. **Verify:** mark renders at 24/96/512dp without jaggies; launcher icon visible on device.

### D3: SP1 hero header
`lib/features/subscriptions/ui/hero_spend_header.dart`: `SpendRingPainter` + count-up + glow; integrate at dashboard top (replacing `TotalsHeader`); renewal strip `lib/features/subscriptions/ui/renewal_strip.dart` fed by a `next7DaysProvider`. **Verify:** acceptance criteria SP1; totals math identical to `monthlyAndAnnualByCurrency` (existing widget test extended).

### D4: SP2 ledger cards + morph
Restyle `SubscriptionCard` → `LedgerCard` (brand dot, hairline, geometry above); stagger entrance via flutter_animate; `Hero` tag morph into the form's header; form restyle (segmented selector, monochrome fields, trial tint). **Verify:** SP2 acceptance; existing form tests still pass.

### D5: Brand colors end-to-end (the one schema addition)
Add `lib/core/brand/brand_colors.dart` (match table + fallback logic as pure, unit-tested functions: `Color? brandColorFor(String name, {String? category})`); add nullable `brandColor` (`String?` hex) to `Subscription`/draft/repository maps + one auto-mapping at save; small color-override row in the form (12 brand swatches, monochrome frame on selected). Update tests (`fake_cloud_firestore` round-trip). **Verify:** Netflix entry shows red dot; "Bob's Gym" shows `Other` gray; existing docs without the field render gray (null-safe).

### D6: SP3 paywall + directory/settings restyle + QA
Paywall per SP3 spec; directory list (brand dots, category grouping); settings restyle (theme toggle, plan row, export). Final QA pass: WCAG AA contrast on both themes for ink tiers (spot-check with a contrast tool: `ink.secondary` on `surface.step1` ≥ 4.5:1), 1.3× text scaling walkthrough, `--profile` 60fps check on SP1/SP2, screenshot pair (dark+light) for the report. **Verify:** demo checklist from architecture plan Task 14 still passes end-to-end.

## Out of Scope

- Rive/Lottie, custom full icon sets, user-selectable accents, per-screen palettes, splash screen, tablet layouts, animated illustrations beyond the three set pieces.
- The monogram/wordmark stays "Subly"-based until the name is final; all brand assets route through `SublyMark`/token files so a rename is one-file.
