#include <windows.h>
#include <commdlg.h> // For GetSaveFileNameW
#include <shlwapi.h> // For PathRemoveFileSpecW
#pragma comment(lib, "shlwapi.lib")

#include "plugin2.h"
#include "logger2.h"
#include "config2.h"

// --- グローバル/静的変数 ---
// 最後に保存したファイルのディレクトリパスを保持し、次回のダイアログの初期ディレクトリとして使用します。
static WCHAR g_last_save_dir[MAX_PATH] = L"";


// --- プロトタイプ宣言 ---
void on_save_alias_old(EDIT_SECTION* edit);


// --- 必須のエントリーポイント ---

// ロガー初期化 (AviUtl2から呼び出される)
EXTERN_C __declspec(dllexport) void InitializeLogger(LOG_HANDLE* handle) {
    // このプラグインではロガーは使用しない
}

// 設定ハンドル初期化 (AviUtl2から呼び出される)
EXTERN_C __declspec(dllexport) void InitializeConfig(CONFIG_HANDLE* handle) {
    // このプラグインでは設定は使用しない
}

// プラグイン初期化 (AviUtl2から呼び出される)
EXTERN_C __declspec(dllexport) bool InitializePlugin(DWORD version) {
    return true;
}

// プラグイン終了 (AviUtl2から呼び出される)
EXTERN_C __declspec(dllexport) void UninitializePlugin() {
    // クリーンアップは不要
}

// プラグイン登録 (メインのエントリーポイント)
// この関数はAviUtl2によってプラグインを登録するために呼び出されます。
EXTERN_C __declspec(dllexport) void RegisterPlugin(HOST_APP_TABLE* host) {
    if (!host) return;

    // オブジェクトの右クリックコンテキストメニューに新しい項目を登録します。
    // L"エイリアスを保存旧" がメニューに表示されるテキストです。
    // on_save_alias_old は項目がクリックされたときに実行されるコールバック関数です。
    host->register_object_menu(L"エイリアスを保存旧", on_save_alias_old);
}

// --- メニューコールバック実装 ---
// 「エイリアスを保存旧」メニュー項目がクリックされたときに実行される関数です。
void on_save_alias_old(EDIT_SECTION* edit) {
    if (!edit) return;

    // 1. タイムライン上で現在フォーカスされているオブジェクトを取得します。
    OBJECT_HANDLE object = edit->get_focus_object();
    if (!object) {
        // オブジェクトが選択されていない場合は何もしません。
        // より良いユーザー体験のためにはメッセージを表示することも可能ですが、今回は単に処理を終了します。
        return;
    }

    // 2. オブジェクトのエイリアスデータを取得します。
    // SDKの仕様によると、このデータはUTF-8エンコードされた文字列であり、
    // そのフォーマットは .object ファイルの内容と同一です。
    LPCSTR alias_data = edit->get_object_alias(object);
    if (!alias_data || strlen(alias_data) == 0) {
        MessageBoxW(NULL, L"エイリアスデータの取得に失敗しました。", L"エイリアス保存エラー", MB_OK | MB_ICONERROR);
        return;
    }

    // 3. 標準のWindows「ファイル名を付けて保存」ダイアログを設定して表示します。
    WCHAR file_path[MAX_PATH] = {0};
    OPENFILENAMEW ofn = {0};
    ofn.lStructSize = sizeof(OPENFILENAMEW);
    ofn.hwndOwner = NULL; // AviUtlのメインウィンドウハンドルを渡すのが理想的です。
    ofn.lpstrFilter = L"エイリアスファイル (*.object)\0*.object\0すべてのファイル (*.*)\0*.*\0";
    ofn.lpstrFile = file_path;
    ofn.nMaxFile = MAX_PATH;
    ofn.lpstrTitle = L"エイリアスを名前を付けて保存";
    ofn.lpstrDefExt = L"object";
    ofn.Flags = OFN_OVERWRITEPROMPT | OFN_PATHMUSTEXIST;

    // ダイアログの初期ディレクトリを前回使用したディレクトリに設定します。
    if (wcslen(g_last_save_dir) > 0) {
        ofn.lpstrInitialDir = g_last_save_dir;
    }

    // ダイアログを表示します。ユーザーがキャンセルした場合、GetSaveFileNameWはFALSEを返します。
    if (GetSaveFileNameW(&ofn)) {
        // ユーザーが「保存」をクリックしました。

        // 4. エイリアスデータ（UTF-8文字列）を選択されたファイルに書き込みます。
        HANDLE hFile = CreateFileW(file_path, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);

        if (hFile == INVALID_HANDLE_VALUE) {
            MessageBoxW(NULL, L"ファイルの作成に失敗しました。", L"エイリアス保存エラー", MB_OK | MB_ICONERROR);
            return;
        }

        DWORD bytes_written;
        BOOL result = WriteFile(hFile, alias_data, (DWORD)strlen(alias_data), &bytes_written, NULL);

        CloseHandle(hFile);

        if (!result) {
            MessageBoxW(NULL, L"ファイルへの書き込みに失敗しました。", L"エイリアス保存エラー", MB_OK | MB_ICONERROR);
            return;
        }

        // 5. 保存が成功した場合、次回の為に保存先のディレクトリパスを更新します。
        wcscpy_s(g_last_save_dir, MAX_PATH, file_path);
        PathRemoveFileSpecW(g_last_save_dir); // ファイル名部分を削除し、ディレクトリパスのみを残します。
    }
}
