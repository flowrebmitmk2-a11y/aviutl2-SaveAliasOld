# SaveAliasOld

`SaveAliasOld` は AviUtl2 用のプラグインです。選択中オブジェクトの alias を `.object` ファイルとして保存します。

## 導入方法

1. `SaveAliasOld.aux2` を AviUtl2 のプラグイン配置先へ置きます。
2. 必要に応じて AviUtl2 を再起動します。

## AviUtl2 上での簡単な使い方

1. 保存したいオブジェクトを選択します。
2. オブジェクトメニューから `エイリアスを保存旧` を実行します。
3. 保存先を選ぶと `.object` ファイルとして書き出されます。

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
