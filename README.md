# Progress Diary

Progress Diary is an iOS app for recording daily progress in lightweight, text-based lists.
Each entry keeps its creation date, while a GitHub-style heatmap makes activity visible across the year.

## Features

- Create multiple independent progress lists.
- Swipe horizontally between lists with paging.
- Add short text entries to the currently selected list.
- View entries with their creation date in `M.d` format.
- See a separate yearly heatmap for each list.
- Choose a heatmap color for each list from eight presets.
- Create, select, and delete lists.
- Protect list deletion with a nested menu and confirmation alert.
- Use the bottom-right floating add button with Liquid Glass on iOS 26 and a material fallback on earlier supported iOS versions.
- Preserve existing entries by migrating them to the default `Progress` list.

## How to Use

1. Open the list menu in the navigation bar to select an existing list or create a new one.
2. Swipe left or right across the entry area to change lists.
3. Tap the floating `+` button to add an entry to the current list.
4. Open a list's settings to change its heatmap color.
5. Use `Delete` → `Delete Current List` to begin deletion, then confirm in the alert.

The heatmap at the top always represents the currently selected list. A day is marked when that list has at least one entry on that date.

## Project Structure

- `iOS-Template/ProgressDiary/`: the main iOS app, domain state, persistence, and app-layer view stores.
- `iOS-Template/Packages/DiaryFeature/`: the package-owned SwiftUI screen and display models.
- `iOS-Template/ProgressDiary.xcodeproj/`: the Xcode project.
- `.github/workflows/build.yml`: the GitHub Actions build workflow.

## Requirements

- Xcode 26.0 or later.
- iOS 17 or later.
- Swift Package Manager support, included with Xcode.

## Build

The project can be built locally with:

```sh
xcodebuild build \
  -project iOS-Template/ProgressDiary.xcodeproj \
  -scheme ProgressDiary \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO
```

GitHub Actions runs the same simulator build automatically for pushes to `main` or `develop`, and for pull requests targeting either branch. The workflow uses `macos-15` and Xcode 26.0.

## Data Storage

The app uses SwiftData for local persistence. Lists and entries are stored on the device; no server or account is required.
