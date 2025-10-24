package jp.netplan.android.waqu_repo

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.enableEdgeToEdge
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Google推奨: enableEdgeToEdge()をComponentActivityとして呼び出す
        (this as ComponentActivity).enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        
        // 追加のエッジツーエッジ設定（Flutterとの互換性のため）
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}