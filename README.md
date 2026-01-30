# SaveAliasOld for AviUtl2

オブジェクトのエイリアスを「名前を付けて保存」で保存するための AviUtl2 用プラグインです。

## 導入方法

1.  **プラグインのダウンロード**
    [リリースページ](https://github.com/flowrebmitmk2-a11y/aviutl2-SaveAliasOld/releases)から、最新の `SaveAliasOld-Release.zip` をダウンロードしてください。

2.  **ファイルの配置**
    ダウンロードしたZIPファイルを解凍し、中に入っている `SaveAliasOld.aux2` をAviUtl2の `plugins` フォルダ内に配置してください。
    （例: `C:\AviUtl2\plugins\SaveAliasOld.aux2`）

3.  **確認**
    AviUtl2を起動すれば導入は完了です。

## 使い方

1. 拡張編集タイムライン上で、エイリアスとして保存したいオブジェクトを右クリックします。
2. 表示されたコンテキストメニューから「エイリアスを保存旧」を選択します。
3. ファイル保存ダイアログが表示されるので、任意の名前を付けて `.object` ファイルとして保存します。

## 開発者向けビルド方法

このプラグインを自身でビルドするには、以下の環境が必要です。

*   CMake
*   Visual Studio (2019以降)

以下のコマンドを実行することでビルドできます。

```bash
# 1. リポジトリをクローン
git clone https://github.com/flowrebmitmk2-a11y/aviutl2-SaveAliasOld.git
cd aviutl2-SaveAliasOld

# 2. ビルド用ディレクトリを作成して移動
mkdir build
cd build

# 3. CMakeでプロジェクトを構成
cmake .. -A Win32

# 4. ビルドを実行
cmake --build . --config Release
```

ビルドが成功すると、`build\Release` フォルダ内に `SaveAliasOld.aux2` が生成されます。

## ライセンス

このプロジェクトのライセンスについては、[license.txt](license.txt) を参照してください。
