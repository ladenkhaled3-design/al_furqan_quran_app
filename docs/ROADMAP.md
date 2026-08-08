# Roadmap — Quran App

## Guiding Principles

- Offline-first, Arabic-first, RTL throughout.
- No feature starts until its prerequisite infrastructure is stable.
- No fake Quran data — real `quran.json` must be present before any reader work.
- Each phase ends with a working, shippable build.

---

## Phase 1 — Foundation (Pre-MVP) `[IN PROGRESS]`

Fix critical infrastructure gaps before feature work begins.

### Tasks

| # | Task | File(s) |
|---|---|---|
| 1.1 | Add real `quran.json` to `assets/data/` | `assets/data/quran.json` |
| 1.2 | Register asset in `pubspec.yaml` | `pubspec.yaml` |
| 1.3 | Fix `main()`: add `WidgetsFlutterBinding.ensureInitialized()` + `await` DI | `lib/main.dart` |
| 1.4 | Set `locale: Locale('ar')` in `MaterialApp.router` for RTL | `lib/app/app.dart` |
| 1.5 | Wire `quranDataProvider` (FutureProvider) | `lib/features/quran/presentation/providers/quran_provider.dart` |
| 1.6 | Wire `lastReadProvider` + `settingsProvider` stubs | same providers file |
| 1.7 | Remove `isar_community_generator` from dev_deps (Isar not yet used) | `pubspec.yaml` |

### Acceptance Criteria
- App starts without crash on cold launch.
- Surah list loads from JSON asset.
- RTL layout applied globally.

---

## Phase 2 — MVP Core `[NEXT]`

Build all MVP screens end-to-end, wired to real data.

### Tasks

| # | Task | Notes |
|---|---|---|
| 2.1 | **HomeScreen** — bind `LastReadCard` + `FeatureCard` to providers | replace static placeholders |
| 2.2 | **SurahListScreen** — lazy `ListView.builder`, 114 tiles | `/surahs` route |
| 2.3 | **QuranReaderScreen** — Amiri font, RTL, verse-by-verse layout | `/surah/:id` route |
| 2.4 | **AyahTile** — number badge, text, action bar (bookmark / copy) | in reader widgets |
| 2.5 | **Last-read tracking** — save on ayah scroll, restore on home | `QuranRepository.saveLastReadSurah` fix |
| 2.6 | Add `QuranRouter` routes for all MVP screens | `lib/app/router/app_router.dart` |
| 2.7 | Add `AppLoadingWidget`, `AppErrorWidget`, `EmptyStateWidget` | `lib/common/widgets/` |

### Acceptance Criteria
- User can open app → tap surah → read all ayahs.
- Last-read position is restored on next launch.
- All screens show loading / error / empty states.

---

## Phase 3 — MVP Completion `[NEXT]`

Complete remaining MVP features.

### Tasks

| # | Task | Notes |
|---|---|---|
| 3.1 | **SearchScreen** — full-text search over ayah text + surah names | derived Riverpod provider |
| 3.2 | **BookmarksScreen** + `bookmarksProvider` | CRUD via SharedPrefs |
| 3.3 | **SettingsScreen** — font size slider, theme toggle | `settingsProvider` + `AppTheme.darkTheme` |
| 3.4 | **Dark theme** — `AppTheme.darkTheme` | `lib/app/theme/app_theme.dart` |
| 3.5 | **Font size** — reader respects `settingsProvider.fontSize` | `AyahText` widget |
| 3.6 | Juz / Hizb navigation labels in reader | use `Ayah.juz` + `Ayah.hizbQuarter` |
| 3.7 | Performance audit — profile JSON parse, optimize if >300 ms | use `compute()` isolate if needed |

### Acceptance Criteria
- Search returns results within 200 ms on mid-range device.
- Bookmarks persist across restarts.
- Dark mode toggled from settings and applied instantly.

---

## Phase 4 — Post-MVP (Audio + Tafsir) `[PLANNED]`

| # | Feature | Package | Notes |
|---|---|---|---|
| 4.1 | **Audio recitation** — per-ayah playback | `just_audio`, `audio_service` | qari selector, play/pause/seek |
| 4.2 | **Translation** — English + selectable languages | embedded JSON or Isar | shown below Arabic text |
| 4.3 | **Tafsir** — simplified Arabic tafsir per ayah | embedded JSON | expandable in reader |
| 4.4 | **Upgrade bookmarks to Isar** — structured queries | `isar_community` | activate commented deps |

---

## Phase 5 — Advanced Features `[FUTURE]`

| # | Feature | Notes |
|---|---|---|
| 5.1 | **Azkar** — morning / evening adhkar screen | static JSON data |
| 5.2 | **Prayer Times** — location-based, offline calc | `adhan` package |
| 5.3 | **Qibla** — compass to Mecca | `flutter_qiblah` or custom |
| 5.4 | **Hijri Calendar widget** | `hijri` package |
| 5.5 | **Offline update** — download updated Quran data without app update | versioned remote JSON + local cache |

---

## Phase Completion Criteria (overall)

| Phase | Done when… |
|---|---|
| 1 | App launches, JSON loads, RTL active |
| 2 | User can read any surah; last-read restored |
| 3 | Search + bookmarks + settings all working in dark/light |
| 4 | Audio plays per ayah; translation shown; Isar active |
| 5 | Prayer times, qibla, azkar all functional |

---

## Current Status

- **Phase 1:** In progress — infrastructure gaps identified (see ARCHITECTURE.md §10).
- **Phases 2–5:** Not started.
