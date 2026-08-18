# プロジェクト固有ルール

## GitHub Actionsによるビルド

- `.github/workflows/build.yml`にビルドワークフローがある。
- `main`または`develop`へのpush、および`main`または`develop`を対象とするPull Requestで自動実行される。
- 実行環境は`macos-15`、Xcodeは`/Applications/Xcode_26.0.app`を使用する。
- `ProgressDiary`スキームを`generic/platform=iOS Simulator`向けにビルドする。
- シミュレータ向けビルドのため、`CODE_SIGNING_ALLOWED=NO`を指定する。
- ローカル環境に`xcodebuild`がない場合、GitHub Actionsの実行結果をビルド結果として確認する。
