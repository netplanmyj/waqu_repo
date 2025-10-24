package jp.netplan.android.waqu_repo

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // エッジツーエッジ表示を有効化（Android推奨の方法）
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}