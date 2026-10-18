# Tally — product brief

Tally turns goals into small daily tasks, and each task rings like a real alarm
until you answer it. Every **Done** adds a mark to the tally.

## Who it's for

People who already know what they want to do (run, study, read) but keep
letting the moment pass. They don't need more information. They need a nudge
at the right minute and a reason to keep going the day after a bad day.

## Principles (and the evidence behind them)

1. **Never miss twice.** In Lally et al. (2010), one missed day barely affected
   habit formation, but people who were inconsistent never formed the habit.
   → A single skip is fine. Two bad days in a row are the real danger, and the
   app's tone and colours respond to that pattern, not to a single slip.
   ([BPS summary](https://bps.org.uk/research-digest/how-form-habit))

2. **Build in slack.** Duolingo's own experiments found that flexibility
   (Streak Freezes) kept more people active without making them lazier.
   → One **rest day** per week doesn't break your streak.
   ([Duolingo blog](https://blog.duolingo.com/how-duolingo-streak-builds-habit))

3. **Be kind after a slip.** Leiden research on the "what-the-hell effect":
   self-criticism after a slip makes people quit, and forgiving self-talk keeps
   them going. → "Slipping" is a warm tangerine nudge with forgiving copy,
   never red and never guilt.
   ([David Robson](https://davidarobson.substack.com/p/how-to-overcome-the-what-the-hell))

4. **Celebrate right away.** BJ Fogg (Tiny Habits): a positive feeling right
   after the behaviour is what wires the habit in.
   → Each Done draws a tally stroke with a haptic tick. Finishing the day gets
   its own moment.
   ([TED Ideas](https://ideas.ted.com/how-you-can-use-the-power-of-celebration-to-make-new-habits-stick/))

5. **Plan when and where.** If-then plans ("After coffee, I run") have a
   medium-to-large effect on follow-through (Gollwitzer & Sheeran, d ≈ 0.65).
   → Tasks get an optional **cue** ("After my morning coffee"), shown on the
   ring screen. ([summary](https://goalsandprogress.com/implementation-intentions-research/))

6. **Only the notifications you asked for.** Users turn off apps that notify
   too often (Localytics survey). → Tally never sends marketing, guilt or
   "we miss you" pushes. It only fires what you scheduled.
   ([appbot](https://appbot.co/blog/app-push-notifications-2026-best-practices/))

7. **Wake gently, without nagging.** Gradually rising alarms improve morning
   mood, and repeated snoozing worsens grogginess.
   → The alarm fades in over 10 s, and the ring screen shows how many times
   you've snoozed. ([PMC study](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9804954/))

## Visual identity

- **Name:** Tally. **Mark:** four strokes crossed by a fifth.
- **Themes:** Ink (dark, #0B0B0F) and Mono (light, white). Font: Plus Jakarta Sans.
- **Mood accents.** The mood is computed once a day so it never flickers:

| Mood | Accent (dark / light) | Rule (last 7 days, not counting today) |
|---|---|---|
| Thriving | aqua #4FE3C1 / #0FA888 | ≥ 85 % done **and** streak ≥ 3 |
| Steady | violet #9D8CFF / #6A4CFF | everything else; also the starting mood (< 3 days of history) |
| Slipping | tangerine #FF8A4C / #E8540F | < 50 % done, **or** 20+ points below the previous week |

- When you're Thriving, faint aqua embers rise on the Today card. They fade
  in, stay on that card only, and switch off with Android's "Remove animations".
  Becoming Thriving gets a one-time bigger moment.
- The app icon stays violet.

## Streak rules

- **Kept day:** every scheduled task was done.
- **Rest day:** every task was answered, at least one with Skip. You get one
  per Mon–Sun week. It doesn't break the streak and doesn't add to it.
- **Broken day:** anything left unanswered, or a second rest day that week.
- Days with nothing scheduled are ignored.

## Tally rules (when you can answer)

A tally should mean you actually did the thing at roughly the right time. So:

- **Opens an hour early.** A task can be tallied from 60 minutes before its
  time until midnight. Before that, its circle is dimmed and tapping it says
  when it opens.
- **Rest any time today.** You can plan a skip ahead ("Rest today"), because
  deciding not to do something is honest.
- **One grace day.** Yesterday's unanswered tasks stay in the check-in card
  until midnight, and then the day is final.
- **No tap-to-toggle.** Tapping a tallied task doesn't undo it. Undo is in the
  3-second snackbar and the long-press menu, and works only while the day is
  still open.
- The ring screen's slide-to-tally always counts, since it's the moment itself.

## Roadmap

- **Step 4a — look and feel:** rename to Tally, Ink/Mono themes, mood engine
  and embers, redesigned ring screen (pulses, big clock, slide to tally,
  fade-in sound), tally-stroke Done with haptics, swipe Done/Skip, undo,
  day-complete moment, task cues, new streak rules.
- **Step 4b — trust:** backup/restore (Android auto-backup and file export),
  edit/complete goals, pause tasks, release build and signing key, final
  package id (`com.anchor.anchor` stays until then so data on the phone
  survives).
- **Later:** Play Store listing, home-screen widget, weekly review.
