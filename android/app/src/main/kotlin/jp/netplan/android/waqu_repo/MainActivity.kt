package jp.netplan.android.waqu_repo

import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // エッジツーエッジ表示を有効化（Android 5.0以降）
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        // Android 15以降で非推奨APIの使用を回避
        // システムバーを透明にする（Flutterが設定した色を使用）
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
        }
    }
}