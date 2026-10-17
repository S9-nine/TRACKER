---
name: Warm Mindful Tracker
colors:
  surface: '#f9f9f9'
  surface-dim: '#dadada'
  surface-bright: '#f9f9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f3'
  surface-container: '#eeeeee'
  surface-container-high: '#e8e8e8'
  surface-container-highest: '#e2e2e2'
  on-surface: '#1a1c1c'
  on-surface-variant: '#55423e'
  inverse-surface: '#2f3131'
  inverse-on-surface: '#f0f1f1'
  outline: '#88726d'
  outline-variant: '#dbc1ba'
  surface-tint: '#9a442d'
  primary: '#9a442d'
  on-primary: '#ffffff'
  primary-container: '#e07a5f'
  on-primary-container: '#5b1604'
  inverse-primary: '#ffb4a1'
  secondary: '#406840'
  on-secondary: '#ffffff'
  secondary-container: '#beecb9'
  on-secondary-container: '#446c44'
  tertiary: '#645d58'
  on-tertiary: '#ffffff'
  tertiary-container: '#9d958f'
  on-tertiary-container: '#332e2a'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdbd2'
  primary-fixed-dim: '#ffb4a1'
  on-primary-fixed: '#3c0800'
  on-primary-fixed-variant: '#7c2e19'
  secondary-fixed: '#c1eebc'
  secondary-fixed-dim: '#a5d2a2'
  on-secondary-fixed: '#002106'
  on-secondary-fixed-variant: '#284f2a'
  tertiary-fixed: '#ebe1da'
  tertiary-fixed-dim: '#cec5bf'
  on-tertiary-fixed: '#1f1b17'
  on-tertiary-fixed-variant: '#4c4641'
  background: '#f9f9f9'
  on-background: '#1a1c1c'
  surface-variant: '#e2e2e2'
  surface-base: '#FAFAFA'
  surface-card: '#FFFFFF'
  surface-subtle: '#F7F7F6'
  surface-border: '#EAEAE8'
  text-primary: '#2B2622'
  text-muted: '#756F68'
  accent-terracotta: '#E07A5F'
  accent-sage: '#588157'
typography:
  display-hero:
    fontFamily: Inter
    fontSize: 56px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.03em
  display-hero-mobile:
    fontFamily: Inter
    fontSize: 44px
    fontWeight: '700'
    lineHeight: 52px
    letterSpacing: -0.03em
  headline-lg:
    fontFamily: Inter
    fontSize: 34px
    fontWeight: '700'
    lineHeight: 42px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 30px
    letterSpacing: -0.015em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 17px
    fontWeight: '400'
    lineHeight: 26px
    letterSpacing: -0.005em
  body-md:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1.5rem
  margin-mobile: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.25rem
---

## Brand & Style

This design system is tailored for mindful goal tracking and daily rituals, balancing metric precision with welcoming, non-judgmental warmth. It discards sensory-overloading gamification in favor of calm clarity and purposeful focus.

The aesthetic philosophy centers on **Warm Minimalist Tactility**:
- Crisp, modern warm whites replace former peach or tinted cream washes, delivering an airy canvas with pristine contrast.
- Deep warm charcoal grounds the visual hierarchy with authoritative typographic clarity without the cold harshness of pure black.
- Tactile, pill-shaped interactions provide friendly touch anchors.
- Restrained, intentional terracotta accents command attention strictly at key primary actions and state transitions, supported by serene sage green progress tones.

## Colors

The color palette is built on high-legibility neutrals with deliberate, restrained chromatic accents:

- **Canvas & Surfaces**: The base canvas is `#FAFAFA`, with `#FFFFFF` reserved for elevated modular cards and active input fields. Tiered secondary containers and inset elements utilize neutral warm white tones (`#F7F7F6`). All previous peach and orange-tinted surface washes are eliminated.
- **Borders & Dividers**: Structural boundaries utilize `#EAEAE8`, providing subtle separation without chromatic interference.
- **Typography & Text Contrast**: Primary headings and values are anchored in `#2B2622` (warm charcoal) for deep, glare-free readability. Secondary text, captions, and muted labels use `#756F68`.
- **Accents**:
  - **Primary Action (`#E07A5F`)**: Terracotta is applied strictly to primary interactive buttons, critical active indicators, and focus states.
  - **Health & Completion (`#588157`)**: Natural sage green designates completed streaks, filled rings, and affirmative status indicators.

## Typography

The typographic hierarchy prioritizes rapid scannability and quantitative focus using Inter:

- **Numerical Dominance**: Hero numeric data points (daily totals, streak counts) utilize `display-hero` (desktop) and `display-hero-mobile` (handhelds) to establish immediate focal points.
- **Section Headers**: `headline-lg` and `headline-md` define layout divisions with bold visual cadence, eliminating the need for heavy separating horizontal rules.
- **Labels & Microcopy**: Compact labels (`label-sm` and `label-md`) employ slightly widened letter tracking to retain crisp definition inside badges, progress pills, and week grids.

## Layout & Spacing

The layout follows a fluid-responsive system built on an 8pt structural rhythm:

- **Canvas Boundaries**: Mobile views maintain a consistent `1.25rem` outer canvas margin (`margin-mobile`). Tablet and desktop breakpoints expand outer margins to `1.5rem` (`margin`).
- **Flow & Stacking**: Vertical spacing between primary dashboard sections uses `space-lg` (`1.5rem`) to ensure cards breathe without visual congestion.
- **Internal Spacing**: Component cards use `space-lg` (`1.5rem`) padding. Closely associated labels and metrics link tightly using `space-xs` (`0.25rem`) and `space-sm` (`0.5rem`).

## Elevation & Depth

Visual depth is achieved through delicate surface transitions and diffused ambient shadows:

- **Canvas (Level 0)**: `#FAFAFA` base layer.
- **Base Cards (Level 1)**: Crisp `#FFFFFF` elevated above the warm white canvas with a diffused shadow: `box-shadow: 0 4px 20px -2px rgba(43, 38, 34, 0.04)`.
- **Floating Nav & Modals (Level 2)**: Persistent floating bottom bars and action sheets use `box-shadow: 0 12px 32px -4px rgba(43, 38, 34, 0.08)`.
- **Active State Highlights**: Completed ritual indicators cast a localized chromatic glow: `box-shadow: 0 0 16px 2px rgba(88, 129, 87, 0.25)`.

## Shapes

The interface balances soft geometry with structured clarity:

- **Cards & Surfaces**: Configured with a `24px` radius (`1.5rem` / `rounded-xl`) for a smooth, tactile appearance.
- **Interactive Buttons & Badges**: Fully pill-shaped (`9999px`) to create natural, ergonomic touch targets.
- **Form Controls & Inputs**: Form inputs and internal selectors use a `12px` to `16px` radius (`rounded-lg`).

## Components

### Buttons & Interactive CTAs
- **Primary CTA**: `#E07A5F` fill, pure white text, pill-shaped (`border-radius: 9999px`), minimum height `52px`. Ambient terracotta shadow: `0 4px 16px -2px rgba(224, 122, 95, 0.25)`.
- **Secondary CTA**: Neutral `#F7F7F6` container, `#2B2622` text, with a subtle border in `#EAEAE8`. Pressed state shifts to `#ECECE9`.

### Habit & Metric Cards
- Background: Pure `#FFFFFF`.
- Radius: `24px`.
- Border: Optional hair-width boundary in `#EAEAE8` for low-contrast displays.
- Shadow: `0 4px 20px -2px rgba(43, 38, 34, 0.04)`.

### Completion Rings & Checkboxes
- **Touch Target**: Minimum `44px` circular hit area.
- **Unchecked / Idle**: `2px` stroke in `#EAEAE8` against `#FFFFFF`.
- **Checked / Completed**: Solid `#588157` fill, white checkmark glyph, supported by a subtle `rgba(88, 129, 87, 0.25)` halo.

### Input Fields
- Background: `#FFFFFF`.
- Border: `1.5px` solid `#EAEAE8`, corner radius `16px`.
- Text: `#2B2622`, with placeholder text in `#756F68`.
- Focus State: Border transitions to `#E07A5F` with an outer ring of `0 0 0 3px rgba(224, 122, 95, 0.15)`.

### Filter Chips & Segments
- Height: `36px`, pill-shaped (`border-radius: 9999px`).
- Inactive: `#F7F7F6` background, `#756F68` text, `#EAEAE8` border.
- Active: `#2B2622` background, `#FAFAFA` text.