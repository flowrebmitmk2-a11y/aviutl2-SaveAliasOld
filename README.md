# SaveAliasOld

`SaveAliasOld` は AviUtl2 用の `.aux2` プラグインです。選択中オブジェクトの alias をファイル保存する用途を想定し、GitHub 公開と自動ビルドに対応しやすい形へ整理しています。

## 主な内容

- AviUtl2 向けのプラグイン本体
- CMake ベースのビルド構成
- GitHub Actions による自動ビルド
- SDK サブモジュール前提の構成

## ディレクトリ構成

- `src/`: プラグイン本体
- `external/aviutl2-plugin-sdk/`: AviUtl2 SDK の git submodule
- `scripts/build.ps1`: ローカルビルド用スクリプト
- `.github/workflows/build.yml`: CI ビルド

## SDK の入れ方

この repo は `aviutl2/aviutl2_sdk_mirror` を submodule として入れる前提です。

```powershell
git submodule add https://github.com/aviutl2/aviutl2_sdk_mirror.git external/aviutl2-plugin-sdk
git submodule update --init --recursive
```

## ビルド

```powershell
pwsh ./scripts/build.ps1
```

CMake を直接使う場合:

```powershell
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release
```

生成物は `build/Release/SaveAliasOld.aux2` です。

## GitHub Actions

次のタイミングでビルドが走ります。

- push
- pull request
- 手動実行
- `repository_dispatch` の `sdk-updated`



