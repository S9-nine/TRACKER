---
name: Warm Mindful Tracker
colors:
  surface: '#fff8f5'
  surface-dim: '#e2d8d2'
  surface-bright: '#fff8f5'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fcf2eb'
  surface-container: '#f6ece5'
  surface-container-high: '#f1e6e0'
  surface-container-highest: '#ebe1da'
  on-surface: '#1f1b17'
  on-surface-variant: '#55423e'
  inverse-surface: '#352f2b'
  inverse-on-surface: '#f9efe8'
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
  tertiary: '#326a38'
  on-tertiary: '#ffffff'
  tertiary-container: '#6aa46c'
  on-tertiary-container: '#003810'
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
  tertiary-fixed: '#b4f2b3'
  tertiary-fixed-dim: '#98d599'
  on-tertiary-fixed: '#002107'
  on-tertiary-fixed-variant: '#185123'
  background: '#fff8f5'
  on-background: '#1f1b17'
  surface-variant: '#ebe1da'
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

This design system is crafted for mindful goal and habit tracking on Android, merging the tactile clarity of Apple Health with organic warmth. The personality is quiet, grounded, and non-judgmental—an antidote to anxiety-inducing streak trackers with flashing indicators and high-friction clutter. 

Visually, the system adopts **Warm Minimalist Tactility**:
- Uncluttered cream canvases replace sterile cool grays or clinical white.
- Large, grounded display metrics bring focus to personal progress without gamification gimmicks.
- Subtle, warm-tinted ambient shadows elevate surfaces with the physical presence of premium linen paper.
- Calming natural hues—earthy terracotta and sage greens—provide affirmative visual reinforcement.

## Colors

The palette establishes an emotional climate of calm focus through organic, earthy pigment choices:

- **Canvas & Surfaces**: The base canvas is `#FAF6F1` (cream), delivering a soft, glare-free background. Elevated cards and modular surfaces sit on `#FFFFFF`.
- **Text & Hierarchy**: Primary typography is set in `#2B2622` (warm charcoal) for soft, high-contrast legibility. Muted body and secondary metadata use `#7C746D` (warm slate brown), keeping visual hierarchy clean and gentle.
- **Accents**:
  - Primary CTA / Milestone Action: `#E07A5F` (terracotta) delivers an energetic yet grounded invitation to engage.
  - Completion & Health State: `#588157` and `#4E8752` (sage and moss greens) indicate completed rituals and streaks.
  - Active Glows: `rgba(88, 129, 87, 0.35)` provides an ethereal back-glow on successfully checked habits and completed progress rings.

## Typography

The type scale relies on Inter’s neo-grotesque neutrality, tuned for Apple Health-style metric dominance:
- **Massive Metrics (`display-hero`)**: Reserved for numerical progress (e.g., "14", "85%"), allowing values to anchor the view while secondary labels remain understated.
- **Editorial Sectioning**: Large bold titles (`headline-lg` and `headline-md`) introduce views without heavy divider lines, relying on generous margins.
- **Micro Labels**: Tracking is slightly relaxed in `label-sm` to ensure status indicators and calendar week headers remain crisp at tiny scales on compact Android displays.

## Layout & Spacing

The layout is built on a responsive fluid model designed around generous whitespace, avoiding edge-to-edge claustrophobia:

- **Mobile Rhythm**: A single-column flow with `1.25rem` screen margins and `1rem` vertical stacking between card groupings.
- **Tablet / Large Form Factors**: Stacks transition into a 2-column or 3-column asymmetric layout using `1.5rem` margins and `1rem` gutters.
- **Internal Component Spacing**: Cards utilize `1.5rem` (`space-lg`) of internal padding to let habits breathe. Vertical spacing between consecutive metric blocks and labels uses compact values (`0.25rem` to `0.5rem`) to bind data pairs tightly.

## Elevation & Depth

Visual hierarchy is constructed through soft, light-diffusing elevations rather than hard borders:

- **Canvas (Level 0)**: `#FAF6F1`.
- **Card Tier (Level 1)**: Solid pure `#FFFFFF` resting on the cream surface with an ultra-diffused, warm-tinted shadow: `box-shadow: 0 4px 24px -2px rgba(43, 38, 34, 0.05)`.
- **Floating Controls (Level 2)**: Quick-entry habit triggers and floating bottom bars use an expanded ambient elevation: `box-shadow: 0 12px 32px -4px rgba(43, 38, 34, 0.08)`.
- **Active State Glow**: Progress rings and completed habit triggers cast a soft chromatic aura: `box-shadow: 0 0 16px 2px rgba(88, 129, 87, 0.35)`.

## Shapes

The design system uses soft, pill-adjacent corners to create an approachable, organic interface:
- **Cards & Sheets**: Set consistently to an explicit `24px` radius (`1.5rem` / `rounded-xl`), producing a smooth, pebble-like quality on device screens.
- **Buttons, Badges, & Streak Pills**: Full capsule or pill styling (`rounded-full` / `9999px`) for touch targets and tags.
- **Input Fields & Micro Elements**: `12px` to `16px` radius (`rounded-lg`), blending structural stability with soft tactile corners.

## Components

### Buttons & Interactive CTAs
- **Primary CTA**: `#E07A5F` fill, pure white text, pill-shaped (`border-radius: 9999px`), minimum touch height of `52px`. Soft drop shadow matching terracotta: `0 4px 16px -2px rgba(224, 122, 95, 0.25)`.
- **Secondary / Ghost CTA**: Tinted cream background (`#F2EBE1`), `#2B2622` text, no border. Pressed state subtly darkens to `#EAE0D3`.

### Habit Cards
- Surface: `#FFFFFF` with `24px` corner radii and warm ambient shadow (`0 4px 24px -2px rgba(43, 38, 34, 0.05)`).
- Padding: `1.5rem` (`24px`).
- Layout: Asymmetric layout with large numeric indicators (`display-hero-mobile`), habit title (`headline-sm`), and an embedded soft-green radial progress tracker or circular toggle.

### Completion Rings & Checkers
- **Target Size**: Minimum `44px` circular hit area.
- **Unchecked State**: Subtle 2px stroke using `#E8E0D7`, hollow center.
- **Completed State**: Background fills with `#588157`, presenting a crisp white checkmark accompanied by an ambient halo (`0 0 16px 2px rgba(88, 129, 87, 0.35)`).

### Metric Chips & Frequency Filters
- Pill-shaped (`rounded-full`), `36px` height.
- Inactive: `#FFFFFF` background with faint `#EAE3DB` hairline outline and `#7C746D` text.
- Active: `#2B2622` background with `#FAF6F1` text.

### Input Fields
- Background: `#FFFFFF`.
- Border: `1.5px` solid `#EAE3DB`, radius of `16px`.
- Focus State: Border transitions to `#E07A5F` with an outer glow of `0 0 0 3px rgba(224, 122, 95, 0.15)`.
- Text: `#2B2622`, placeholder set in `#7C746D` with 60% opacity.

### Streak & Calendar Strip
- Horizontal day selector anchored inside cards: days are arranged in a 7-column grid with weekday micro-labels (`label-sm`).
- Completed days feature a solid `#588157` circle; today's incomplete slot highlights with a terracotta dot badge.