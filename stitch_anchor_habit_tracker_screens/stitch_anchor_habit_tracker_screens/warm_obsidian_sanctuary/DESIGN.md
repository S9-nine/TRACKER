---
name: Warm Obsidian Sanctuary
colors:
  surface: '#161310'
  surface-dim: '#161310'
  surface-bright: '#3c3835'
  surface-container-lowest: '#100e0b'
  surface-container-low: '#1e1b18'
  surface-container: '#221f1c'
  surface-container-high: '#2d2926'
  surface-container-highest: '#383431'
  on-surface: '#e9e1dc'
  on-surface-variant: '#dbc1ba'
  inverse-surface: '#e9e1dc'
  inverse-on-surface: '#33302c'
  outline: '#a38b86'
  outline-variant: '#55423e'
  surface-tint: '#ffb4a1'
  primary: '#ffb4a1'
  on-primary: '#5d1805'
  primary-container: '#e07a5f'
  on-primary-container: '#5b1604'
  inverse-primary: '#9a442d'
  secondary: '#9fd1b8'
  on-secondary: '#023826'
  secondary-container: '#1f4f3c'
  on-secondary-container: '#8ec0a7'
  tertiary: '#e6c185'
  on-tertiary: '#422c00'
  tertiary-container: '#b3915a'
  on-tertiary-container: '#402b00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdbd2'
  primary-fixed-dim: '#ffb4a1'
  on-primary-fixed: '#3c0800'
  on-primary-fixed-variant: '#7c2e19'
  secondary-fixed: '#bbeed4'
  secondary-fixed-dim: '#9fd1b8'
  on-secondary-fixed: '#002115'
  on-secondary-fixed-variant: '#1f4f3c'
  tertiary-fixed: '#ffdeab'
  tertiary-fixed-dim: '#e6c185'
  on-tertiary-fixed: '#271900'
  on-tertiary-fixed-variant: '#5c4212'
  background: '#161310'
  on-background: '#e9e1dc'
  surface-variant: '#383431'
typography:
  display-lg:
    fontFamily: Newsreader
    fontSize: 48px
    fontWeight: '400'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Newsreader
    fontSize: 36px
    fontWeight: '400'
    lineHeight: 44px
    letterSpacing: -0.015em
  headline-lg:
    fontFamily: Newsreader
    fontSize: 32px
    fontWeight: '500'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Newsreader
    fontSize: 24px
    fontWeight: '500'
    lineHeight: 32px
    letterSpacing: 0em
  headline-sm:
    fontFamily: Newsreader
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: 0em
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
    letterSpacing: -0.01em
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0em
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.03em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-md: 1.5rem
  gutter-lg: 2rem
  margin: 1.25rem
  margin-md: 2rem
  margin-lg: 3rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system embodies warm minimalism, deliberate focus, and restorative calm. Built to support grounding rituals, habit retention, and unhurried progress, it avoids clinical digital aesthetics in favor of a tactile, dusk-lit environment that honors cognitive ease during morning and evening routines.

The visual ethos blends Scandinavian stillness with organic warmth. Deep, embers-and-stone charcoal surfaces provide a quiet canvas where habit loops and milestone progressions feel tangible yet quiet. Interaction is deliberate, tactile, and free of artificial friction or sensory overload.

## Colors

The palette is tuned for high-contrast nighttime and early-morning legibility while protecting dark adaptation.

- **Canvas & Backing (`#1A1714`)**: Deepest warm charcoal. Sets the atmospheric foundation for wake/sleep modes and the persistent app background.
- **Surface Level 1 (`#24201C`)**: Resting elevated container for grouped habit clusters, timeline modules, and persistent bottom sheets.
- **Surface Level 2 (`#2C2723`)**: Active interactive cards, floating quick-log dialogs, and nested sub-items.
- **Structural Outlines (`#332C26`)**: Hairline boundaries applied strictly to establish optical structure without clutter.
- **Primary Accent (`#E07A5F`)**: Terracotta clay. Reserved for primary calls-to-action, key habit completion rings, and current active progress indicators.
- **Supporting Accents**: Sage Green (`#81B29A`) denotes completed habit streaks and calming confirmations; Soft Ochre (`#F2CC8F`) signals reminders and milestone milestones.
- **Typography & Icons**: Crisp Warm White (`#F5F0EB`) drives primary titles and unread indicators; Soft Warm Gray (`#A89F96`) handles secondary descriptive text, streak counts, and subtle states.

## Typography

The typographic pairing balances thoughtful contemplation with clear utilitarian data delivery.

- **Editorial Headings (`Newsreader`)**: Anchors routines, daily focus banners, and introspective journal views with an organic, humanistic presence. The italic variants are used sparingly for daily reflections and motivational cues.
- **Interface & Metrics (`Plus Jakarta Sans`)**: Provides crisp legibility for completion trackers, timestamps, metrics, and actionable labels.
- **Hierarchy Rules**: Numerical metric highlights (such as streak totals) combine bold weights with tighter tracking, whereas contextual labels maintain slightly expanded letter-spacing to sustain clarity on dark substrates.

## Layout & Spacing

A rhythmic, column-based layout adapts fluidly across personal devices:

- **Mobile (< 640px)**: 4-column layout with 20px (`1.25rem`) side margins and 16px (`1rem`) gutters. Content is vertically stacked, emphasizing single-thumb reachability.
- **Tablet (641px - 1024px)**: 8-column layout with 32px (`2rem`) margins. Allows split-view habit lists alongside completion calendar rings.
- **Desktop (> 1025px)**: 12-column layout maxed at 1160px container width with 48px (`3rem`) margins. Daily view and deep habit analytics sit side-by-side.

Spacing follows an organic 4px/8px modular rhythm, prioritizing generous vertical padding (`space-lg` to `space-xl`) between distinct categories to ensure an uncluttered, peaceful flow.

## Elevation & Depth

Visual hierarchy is maintained via warm surface layering rather than harsh directional dropshadows.

1. **Base Layer (`#1A1714`)**: Absolute canvas level.
2. **First Tier (`#24201C`)**: Resting card containers. Bound with a crisp 1px stroke of `#332C26`. No shadow applied in default states.
3. **Second Tier (`#2C2723`)**: Active, hovered, or child items within cards. A soft, warm ambient glow (`box-shadow: 0 8px 24px -4px rgba(10, 8, 7, 0.45)`) separates this level from underlying surfaces.
4. **Floating / Dialog Layer**: Modals, alarm overlays, and bottom action sheets float above the canvas with a backdropped blur (`backdrop-filter: blur(12px)`) tinted with 85% opacity of `#24201C`, bordered by 1px `#332C26`.

## Shapes

The design system uses a pronounced, smooth corner language to foster an approachable, non-punitive aesthetic.

- **Primary Cards & Modals**: Fixed at `24px` (`1.5rem` / `rounded-xl`), creating smooth organic tiles that soften the perimeter of habit records.
- **Buttons & Pill Badges**: Fixed at fully rounded pills (`9999px`) to invite thumb contact and signify quick-tap operations.
- **Input Fields & Secondary Wells**: Standardized at `12px` to `16px` (`rounded-lg`) corner radii for structured alignment with internal typography.

## Components

### Buttons
- **Primary Button**: Solid terracotta fill (`#E07A5F`) with deep warm charcoal text (`#1A1714`) in `label-lg`. Height: 52px. Border-radius: 9999px. On tap/hover: brightness shifts to 108% with subtle scale (0.99 active press).
- **Secondary Button**: Surface-filled (`#24201C`), 1px hairline border (`#332C26`), crisp white text (`#F5F0EB`). 
- **Ghost/Tertiary**: No background, warm gray text (`#A89F96`), turns `#F5F0EB` on active hover.

### Habit Cards
- **Architecture**: Elevated background `#24201C`, 24px corner radius, internal padding of `space-lg` (24px). Framed by a 1px border of `#332C26`.
- **States**: 
  - *Default*: Card surface `#24201C`.
  - *Completed*: Subtle terracotta background tint (`rgba(224, 122, 95, 0.08)`) with matching border accentuation.
  - *Active/Focus*: Surface rises to `#2C2723`.

### Habit Ring Checkbox
- Circular tracker (32px diameter).
- Incomplete: 2px border outline in `#332C26`, interior transparent.
- Complete: Fill transforms into `#E07A5F` housing a bold `#1A1714` checkmark, accompanied by a micro-spring animation.

### Chips & Filter Pills
- Compact tracking tags (routine tags, morning/night filters).
- Unselected: `#24201C` surface, 1px border `#332C26`, text `#A89F96`.
- Selected: `#2C2723` surface, text `#F5F0EB`, 1px solid border `#E07A5F`.

### Input Fields
- Surface fill `#24201C`, 1px border `#332C26`, 16px corner radius, height 48px.
- Typographic input set in `#F5F0EB`, placeholder set in `#A89F96`.
- Focus state: Border transitions to `#E07A5F` with zero shadow glow.

### Alarm & Timer Ring Screen
- Central circular display tracking remaining hours/routine intervals using `#E07A5F` on a muted `#2C2723` orbital track.
- Time readout set in `display-lg` (`Newsreader`), centered on `#1A1714` full-screen blackout mode.