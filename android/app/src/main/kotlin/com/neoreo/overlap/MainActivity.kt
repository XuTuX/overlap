package com.neoreo.overlap

import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Android 10(Q) 이상일 때 edge-to-edge 지원
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // 시스템 창에 여유 공간 주지 않고 전체 화면 사용
            WindowCompat.setDecorFitsSystemWindows(window, false)
        }
    }
}
