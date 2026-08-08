# Architecture — Quran App

## 1. Current Project Structure

```
lib/
├── main.dart                          # Entry point; initialises DI, runs app
├── app/
│   ├── app.dart                       # MaterialApp.router wrapper
│   ├── router/app_router.dart         # go_router config (only / → HomeScreen)
│   ├── theme/app_theme.dart           # Light theme (Amiri + Cairo fonts, green palette)
│   └── localization/                  # (empty)
├── config/
│   └── dependency_injection/
│       └── dependency_injection.dart  # Riverpod provider graph (no GetIt)
├── core/
│   ├── constants/app_constants.dart   # App name, asset paths, pref keys
│   ├── errors/failures.dart           # Failure hierarchy (Server/Cache/Network)
│   ├── logger/                        # AppLogger wrapper
│   ├── network/                       # (empty – no HTTP client wired yet)
│   └── utils/                        # (empty)
├── common/
│   └── widgets/                       # (empty – shared widgets intended here)
└── features/
    └── quran/
        ├── data/
        │   ├── datasources/quran_local_data_source.dart   # rootBundle JSON loader
        │   ├── models/surah_model.dart                    # SurahModel + AyahModel (JSON)
        │   └── repositories/quran_repository_impl.dart   # SharedPrefs last-read
        ├── domain/
        │   ├── entities/surah.dart                        # Surah + Ayah (Equatable)
        │   ├── repositories/quran_repository.dart         # Abstract repo interface
        │   └── usecases/
        │       ├── get_surahs_usecase.dart
        │       └── get_last_read_usecase.dart
        └── presentation/
            ├── screens/home_screen.dart                   # Static menu (no providers yet)
            ├── providers/quran_provider.dart              # (empty)
            ├── controllers/                               # (empty)
            └── widgets/
                ├── feature_card.dart
                ├── home_section_title.dart
                ├── last_read_card.dart
                └── quran_header.dart

assets/
└── data/quran.json   # Bundled Quran JSON (path declared in constants; NOT yet added to pubspec)

docs/
├── AI_RULES.md
├── ARCHITECTURE.md   ← this file
├── ROADMAP.md
└── REVIEW_CHECKLIST.md
```

**Key observations:**
- `quran.json` asset is referenced in constants but `assets:` section in `pubspec.yaml` is commented out.
- `quran_provider.dart` is empty; no Riverpod providers wired yet.
- `HomeScreen` is static (no data binding).
- No dark theme, no localization, no RTL directive set at app level.
- ~~GetIt removed~~ — DI is now pure Riverpod (`ProviderScope` wraps app; `FutureProvider` handles async init).
- ~~DI race condition fixed~~ — `WidgetsFlutterBinding.ensureInitialized()` added; `main()` no longer calls async setup before `runApp`.

---

## 2. Target Architecture

**Pattern:** Clean Architecture + Feature-Sliced layout.

```
Presentation  ──►  Domain  ◄──  Data
(Riverpod)         (pure)       (JSON asset + SharedPrefs)
```

Each feature is self-contained under `lib/features/<feature>/`.
Shared infrastructure lives in `lib/core/` and `lib/common/`.
App-level wiring (router, theme, DI) lives in `lib/app/` and `lib/config/`.

**State management:** Riverpod (`flutter_riverpod ^3.x`)
**Navigation:** go_router (`^17.x`)
**DI:** Riverpod providers (`dependency_injection.dart`) — no GetIt
**Error handling:** `Either<Failure, T>` via dartz

---

## 3. Page Hierarchy

```
/ (HomeScreen)
├── /surahs              SurahListScreen
│   └── /surah/:id       QuranReaderScreen
│       └── (sheet)      AyahDetailSheet (modal)
├── /search              SearchScreen
├── /bookmarks           BookmarksScreen
└── /settings            SettingsScreen
```

MVP only. Later: audio player, tafsir, azkar, prayer times, qibla — each gets its own top-level route.

---

## 4. Component Hierarchy

### Home
```
HomeScreen
├── QuranHeader          greeting + hijri date
├── LastReadCard         last surah/ayah, resume CTA
├── HomeSectionTitle     section labels
└── FeatureCard (×n)     tappable cards
```

### Surah List
```
SurahListScreen
├── SearchBar            inline filter
└── SurahListView
    └── SurahListTile (×114)
```

### Quran Reader
```
QuranReaderScreen
├── ReaderAppBar         surah name, juz, settings icon
├── AyahListView
│   └── AyahTile (×n)
│       ├── AyahNumberBadge
│       ├── AyahText        Arabic, RTL, Amiri font
│       └── AyahActionBar   bookmark / copy / share
└── ReaderBottomBar      prev/next page, go-to-ayah
```

### Search
```
SearchScreen
├── SearchTextField
└── SearchResultList
    └── SearchResultTile  highlighted match + surah name
```

### Bookmarks
```
BookmarksScreen
└── BookmarkList
    └── BookmarkTile      surah + ayah, remove action
```

### Settings
```
SettingsScreen
├── FontSizeSlider
├── ThemeToggle          light / dark
└── LanguageSelector     AR / EN (phase 2)
```

### Shared
```
common/widgets/
├── AppErrorWidget
├── AppLoadingWidget
└── EmptyStateWidget
```

---

## 5. Data Models

### Domain Entities

```dart
Surah
  id             int
  name           String      // transliterated
  nameArabic     String      // "الفاتحة"
  nameEnglish    String
  totalVerses    int
  revelationType String      // "Meccan" | "Medinan"
  ayahs          List<Ayah>?

Ayah
  number         int         // within surah (1-based)
  text           String      // Full Arabic text WITH tashkeel — display only, never modified
  textPlain      String      // Arabic text stripped of diacritics — search/filter use only
  juz            int?
  page           int?
  hizbQuarter    int?
```

**Planned additions (Phase 2+):**
```dart
Bookmark  { surahId, ayahNumber, createdAt }
LastRead  { surahId, ayahNumber, savedAt }
```

### Data Models
- `SurahModel extends Surah` — `fromJson` / `toJson`
- `AyahModel extends Ayah` — `fromJson` / `toJson`; `textPlain` is read from the JSON `textPlain` field if present, otherwise derived by stripping diacritics from `text` at parse time (inside the background isolate)

---

## 6. Local Quran Data Strategy

**Source:** Single bundled `assets/data/quran.json` (114 surahs + 6236 ayahs).

**Sample structure:**
```json
[
  {
    "id": 1, "name": "Al-Fatiha", "nameArabic": "الفاتحة",
    "nameEnglish": "The Opening", "totalVerses": 7, "revelationType": "Meccan",
    "ayahs": [
      { "number": 1, "text": "بِسْمِ ٱللَّهِ ...", "juz": 1, "page": 1, "hizbQuarter": 1 }
    ]
  }
]
```

**Loading approach:**
1. `QuranLocalDataSourceImpl.getSurahs()` calls `rootBundle.loadString` — bytes only, UI thread (required by platform channel).
2. JSON decoding + `SurahModel.fromJson` (including `textPlain` diacritic stripping) runs inside `Isolate.run(_parseQuranJson)` — off the UI thread.
3. Full parse done once; result cached in Riverpod `FutureProvider` (`keepAlive: true`).
4. Surah list (without ayahs) kept in a lighter in-memory structure for the list screen.
5. Individual surah ayahs loaded lazily per reader session.

**Persistence (SharedPreferences):**
| Key | Type | Purpose |
|---|---|---|
| `last_read_surah` | `int` | last opened surah id |
| `last_read_ayah` | `int` | last read ayah within surah |
| `bookmarks` | `List<String>` | encoded `"surahId:ayahNumber"` |
| `theme_mode` | `String` | `"light"` / `"dark"` |
| `font_size` | `double` | reader font size |

**Phase 2+ upgrade:** Replace SharedPreferences bookmarks with Isar (`isar_community`) when complex queries or large volumes are needed.

---

## 7. State Management

| Provider | Type | Purpose |
|---|---|---|
| `quranDataProvider` | `FutureProvider<List<Surah>>` | loads & caches surah list |
| `surahDetailProvider(id)` | `FutureProvider.family<Surah>` | single surah + ayahs |
| `lastReadProvider` | `FutureProvider<LastRead?>` | SharedPrefs last-read |
| `bookmarksProvider` | `NotifierProvider<BookmarksNotifier, List<Bookmark>>` | CRUD bookmarks |
| `searchQueryProvider` | `StateProvider<String>` | live search input |
| `searchResultsProvider` | `Provider<List<Surah>>` | derived filtered list |
| `settingsProvider` | `NotifierProvider<SettingsNotifier, AppSettings>` | font, theme, language |
| `themeProvider` | `Provider<ThemeMode>` | derived from settingsProvider |

---

## 8. Navigation

```dart
GoRouter(
  routes: [
    GoRoute(path: '/',           name: 'home',      → HomeScreen),
    GoRoute(path: '/surahs',     name: 'surahs',    → SurahListScreen),
    GoRoute(path: '/surah/:id',  name: 'reader',    → QuranReaderScreen),
    GoRoute(path: '/search',     name: 'search',    → SearchScreen),
    GoRoute(path: '/bookmarks',  name: 'bookmarks', → BookmarksScreen),
    GoRoute(path: '/settings',   name: 'settings',  → SettingsScreen),
  ],
  errorBuilder: → NotFoundScreen,
)
```

RTL: set `locale: Locale('ar')` in `MaterialApp.router` to activate system-level RTL layout.

---

## 9. Package Map

| Package | Role |
|---|---|
| `flutter_riverpod ^3.3.2` | State management + DI (no GetIt) |
| `go_router ^17.3.0` | Navigation |
| `google_fonts ^8.2.0` | Amiri (Arabic) + Cairo (UI) |
| `equatable ^2.0.7` | Value equality on entities |
| `dartz ^0.10.1` | Functional error handling (Either) |
| `shared_preferences ^2.5.3` | Last-read + settings persistence |
| `logger ^2.7.0` | Structured logging |
| `isar_community ^3.3.2` *(commented)* | Future: local DB for bookmarks |
| `isar_community_generator ^3.3.2` *(commented out in dev_deps)* | Activate together with isar_community |
| `just_audio ^0.10.6` *(commented)* | Future: audio recitation |

---

## 10. Technical Risks

| # | Risk | Severity | Status |
|---|---|---|---|
| 1 | `quran.json` not declared in `pubspec.yaml` assets — app crashes at runtime | **High** | ⚠️ Open — add file + register asset before first run |
| 2 | ~~DI race condition~~ — `main()` didn’t `await` async DI setup | ~~High~~ | ✅ Fixed — `WidgetsFlutterBinding.ensureInitialized()` added; Riverpod resolves async deps lazily |
| 3 | No Riverpod providers wired — HomeScreen has no data | High | ⚠️ Open — wire `quranDataProvider` before HomeScreen feature work |
| 4 | ~~Full JSON parse on main thread~~ | ~~Medium~~ | ✅ Fixed — parsing runs inside `Isolate.run` |
| 5 | No RTL directive at app level — layout may be LTR on first run | Medium | ⚠️ Open — set `locale: Locale('ar')` in `MaterialApp.router` |
| 6 | Only `surahId` persisted — `ayahNumber` ignored in `saveLastReadSurah` | Low | ⚠️ Open — fix in repository when last-read feature is implemented |
| 7 | No dark theme — ThemeToggle will break | Low | ⚠️ Open — add `AppTheme.darkTheme` before settings screen |
| 8 | ~~`isar_community_generator` mismatch in dev_deps~~ | ~~Low~~ | ✅ Fixed — generator commented out until Isar is activated |
