package jp.netplan.android.waqu_repo

import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // エッジツーエッジ表示を有効化
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        // システムバーの外観を設定（非推奨APIを使わない方法）
        val windowInsetsController = WindowCompat.getInsetsController(window, window.decorView)
        windowInsetsController?.apply {
            // ライトテーマのアイコンを使用（背景が明るい場合）
            isAppearanceLightStatusBars = true
            isAppearanceLightNavigationBars = true
        }
        
        // Android 10以降: ナビゲーションバーのコントラスト強制を無効化
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
        }
    }
}