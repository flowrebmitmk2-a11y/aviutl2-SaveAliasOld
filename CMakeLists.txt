# CMakeの最小バージョンを指定
cmake_minimum_required(VERSION 3.10)

# プロジェクト名と使用言語(C++)を定義
project(SaveAliasOld CXX)

# C++の標準をC++17に設定
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# MSVCコンパイラにソース文字セットがUTF-8であることを伝える
if(MSVC)
    add_compile_options(/source-charset:utf-8)
endif()

# DLL (共有ライブラリ) をソースファイルから作成
# 第1引数: ライブラリのターゲット名
# 第2引数: SHAREDはDLLを作成することを示す
# 第3引数以降: ソースファイル
add_library(SaveAliasOld SHARED SaveAliasOld.cpp)

# WindowsのAPIに必要なライブラリをリンク
target_link_libraries(SaveAliasOld PRIVATE shlwapi user32 comdlg32)

# 出力されるプラグインの拡張子を .aul に変更
# AviUtlの慣例に従い、.dllの代わりに.aux2を使用します
set_target_properties(SaveAliasOld PROPERTIES SUFFIX ".aux2")

# Visual Studio用の設定: Unicode文字セットを使用する
set_target_properties(SaveAliasOld PROPERTIES VS_CHARACTER_SET "Unicode")

# ビルド後、.aulファイルがbuildディレクトリ直下に出力されるように設定
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

