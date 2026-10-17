---
name: Anchor Calm Health
colors:
  surface: '#fdf9f4'
  surface-dim: '#ddd9d5'
  surface-bright: '#fdf9f4'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f7f3ee'
  surface-container: '#f1ede8'
  surface-container-high: '#ebe8e3'
  surface-container-highest: '#e6e2dd'
  on-surface: '#1c1c19'
  on-surface-variant: '#55423e'
  inverse-surface: '#31302d'
  inverse-on-surface: '#f4f0eb'
  outline: '#88726d'
  outline-variant: '#dbc1ba'
  surface-tint: '#9a442d'
  primary: '#9a442d'
  on-primary: '#ffffff'
  primary-container: '#e07a5f'
  on-primary-container: '#5b1604'
  inverse-primary: '#ffb4a1'
  secondary: '#645d58'
  on-secondary: '#ffffff'
  secondary-container: '#ebe1da'
  on-secondary-container: '#6a635e'
  tertiary: '#326a3c'
  on-tertiary: '#ffffff'
  tertiary-container: '#6aa470'
  on-tertiary-container: '#003813'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdbd2'
  primary-fixed-dim: '#ffb4a1'
  on-primary-fixed: '#3c0800'
  on-primary-fixed-variant: '#7c2e19'
  secondary-fixed: '#ebe1da'
  secondary-fixed-dim: '#cec5bf'
  on-secondary-fixed: '#1f1b17'
  on-secondary-fixed-variant: '#4c4641'
  tertiary-fixed: '#b4f1b7'
  tertiary-fixed-dim: '#99d59d'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#185126'
  background: '#fdf9f4'
  on-background: '#1c1c19'
  surface-variant: '#e6e2dd'
typography:
  display-hero:
    fontFamily: Inter
    fontSize: 56px
    fontWeight: '800'
    lineHeight: 60px
    letterSpacing: -0.03em
  display-hero-mobile:
    fontFamily: Inter
    fontSize: 44px
    fontWeight: '800'
    lineHeight: 48px
    letterSpacing: -0.025em
  headline-metric:
    fontFamily: Inter
    fontSize: 38px
    fontWeight: '700'
    lineHeight: 42px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-tablet: 1.5rem
  gutter-desktop: 2rem
  margin: 1.25rem
  margin-tablet: 2rem
  margin-desktop: 3rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.25rem
---

## Brand & Style

The design system embodies a calm, warm, and intentional health-tracking experience. It avoids clinical coldness in favor of a soothing sanctuary aesthetic, pairing the precision of Apple Health with the tactile comfort of warm paper and grounded pottery.

### Audience & Mood
- **Audience:** Individuals seeking sustainable, mindful habit building and holistic vitality tracking without visual anxiety or notification fatigue.
- **Tone:** Grounded, reflective, encouraging, and clear.
- **Design Movement:** Warm Minimalist Tactile. Generous whitespace, serene cream canvas layers, quiet structural hierarchy, and focused terracotta accents that direct purposeful interactions. The companion mascot ("Ember") maintains clean, flat geometric contours to offer understated warmth without gamified distraction.

## Colors

The palette establishes an organic, quiet atmosphere anchored by natural tones:

- **Canvas & Surfaces:**
  - Base canvas: `#FAF6F1` (Cream)
  - Card & sheet surface: `#FFFFFF` (Pure warm white for subtle separation)
  - Muted container fill: `#F3ECE2` (For badges, inset trackers, and segmented pill backgrounds)
- **Typography & Structure:**
  - Primary text & glyphs: `#2B2622` (Warm Charcoal)
  - Secondary/Caption text: `#766E65` (Muted Warm Umber)
  - Hairline borders & dividers: `rgba(43, 38, 34, 0.08)`
- **Interactive Accent:**
  - Terracotta (`#E07A5F`): Exclusively restricted to primary action buttons, active tab indicators, and live focus rings. Never overused as general container tinting.
- **Metrics & Band Accents:**
  - Positive / On Track: `#6EA874` (Sage Green)
  - Warning / Moderate: `#F2C14E` (Soft Amber)
  - Needs Attention / Alert: `#E85D4A` (Muted Coral Red)

## Typography

Typography relies entirely on **Inter**, celebrating stark structural hierarchy with oversized typographic scores, weighted metrics, and generous line spacing.

- **Numerics & Vital Scores:** Numbers represent progress and calm clarity. Hero stats use `display-hero` and `headline-metric` at weights 700 and 800 with tight letter-spacing to form graphic landmarks within cards.
- **Titles & Sections:** Page headlines and card titles use semi-bold and bold weights, keeping titles short and definitive.
- **Metadata & Units:** Measurement units (e.g., `bpm`, `hrs`, `steps`) sit adjacent to numerals using `label-md` or `label-sm` in secondary text `#766E65`.

## Layout & Spacing

The layout is built for fluid touch ergonomics on mobile while neatly anchoring to centered columns on larger viewports.

- **Mobile (Default):** Fluid single-column layout with `1.25rem` (20px) outer edge margins. Card groups use `space-md` gaps. Large section transitions use `space-xl`.
- **Tablet / Desktop:** 
  - Tablet (600px–1024px): 8-column layout with `margin-tablet: 2rem` and `gutter-tablet: 1.5rem`.
  - Desktop (>1024px): Max-width fixed container (720px for personal tracking view, 1080px for dashboard views) with 12-column grid.
- **Rhythm:** Spacing around metric cards is generous to prevent visual clutter, allowing each metric card breathing room to be digested in isolation.

## Elevation & Depth

Visual hierarchy is attained via warm ambient diffusion and surface lightness rather than high drop shadows or stark outlines.

- **Base Ambient Shadow:** All floating cards and interaction modules use:
  `box-shadow: 0 4px 20px -2px rgba(43, 38, 34, 0.05);`
- **Surface Elevation:**
  - **Level 0 (Canvas):** `#FAF6F1`
  - **Level 1 (Cards, Modules):** `#FFFFFF` paired with the base ambient shadow.
  - **Level 2 (Modals, Overlays):** `#FFFFFF` paired with `0 12px 32px -4px rgba(43, 38, 34, 0.08)`.
- **Top Glow Accent (Bottom Navigation):** The unified 3-tab bottom bar features a signature soft glowing hairline along its top perimeter:
  `box-shadow: 0 -1px 0 0 rgba(43, 38, 34, 0.04), 0 -4px 16px rgba(224, 122, 95, 0.08);`

## Shapes

The design system embraces deep, organic curvature that creates friendly, smooth physical metaphors.

- **Cards & Sheets:** Fixed at `24px` (`border-radius: 1.5rem` / `rounded-3xl`) across primary modules, widgets, and charts.
- **Buttons & Interactive Indicators:** Full pill geometry (`border-radius: 9999px`) for action buttons, chips, and segment toggles.
- **Inputs & Inset Wells:** `16px` (`rounded-2xl`) for input fields, text areas, and progress tracks.

## Components

### Buttons
- **Primary Action:** Pill-shaped, background `#E07A5F`, text `#FFFFFF`, font `label-md`. Subtle hover/press: scales to `0.98` with slightly deeper terracotta `#D06A4F`.
- **Secondary Action:** Pill-shaped, background `#F3ECE2`, text `#2B2622`.
- **Ghost/Tertiary:** No background, warm charcoal text `#2B2622`, active terracotta hover.

### Unified 3-Tab Bottom Bar
- **Tabs:** Strictly `Today`, `Insights`, and `Goals`.
- **Structure:** Floating or dock-anchored bar on pure white (`#FFFFFF`) or frosted glass (`rgba(255, 255, 255, 0.92)` with `backdrop-filter: blur(12px)`).
- **Detailing:** Features the top glowing line (`box-shadow: 0 -4px 16px rgba(224, 122, 95, 0.08)`).
- **Active State:** Icon and label illuminate in Terracotta (`#E07A5F`) paired with a 4px terracotta pip indicator; inactive items remain Warm Charcoal at 40% opacity (`#766E65`).

### Cards & Metrics
- Pure white background `#FFFFFF`, rounded to `24px`, ambient shadow applied.
- Includes large-scale bold numerics (`display-hero` or `headline-metric`) alongside subtle descriptive category pills.

### Scores & Chart Accents
- Strict color limits: Charts only use band colors for meaning:
  - Green (`#6EA874`) for completed targets or optimal zones.
  - Amber (`#F2C14E`) for medium zones or recovery windows.
  - Coral/Red (`#E07A5F` / `#E85D4A`) for high exertion or missed milestones.
- Chart lines feature smooth curves with muted fills (`rgba(110, 168, 116, 0.1)`).

### Ember Companion Mascot
- Clean, flat vector geometric style with no heavy gradients or skeuomorphic rendering.
- Expresses quiet presence in the Today header or milestone badges using warm organic tones (`#E07A5F`, `#F2C14E`, and `#2B2622`).

### Chips & Insets
- Small pill containers (`rounded-full`), padded `space-xs` vertically and `space-sm` horizontally, set against `#F3ECE2` background for contextual tagging.

### Inputs, Checkboxes & Radios
- **Inputs:** `16px` rounded corners, `#FFFFFF` background, hairline border `rgba(43, 38, 34, 0.1)`. Focus state rings gently in `#E07A5F` with `0 0 0 3px rgba(224, 122, 95, 0.15)`.
- **Checkboxes & Radios:** Rounded circular indicators (`rounded-full`), filling with `#E07A5F` and white check icon upon selection.