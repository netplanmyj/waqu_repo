package jp.netplan.android.waqu_repo

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Flutterのコンテンツがシステムバーの後ろまで描画されるように設定
        // WindowCompat.setDecorFitsSystemWindows(window, false) は
        // super.onCreate() の前に呼び出すことで、Flutterの初期化よりも
        // 優先してウィンドウレイアウトを設定できます。
        WindowCompat.setDecorFitsSystemWindows(window, false)

        // FlutterActivity の onCreate を呼び出し、Flutterエンジンを初期化
        super.onCreate(savedInstanceState)
    }
}