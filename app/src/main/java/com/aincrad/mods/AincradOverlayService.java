package com.aincrad.mods;

import android.app.Service;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.IBinder;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.Toast;

public class AincradOverlayService extends Service {
    private WindowManager windowManager;
    private View floatingIconView;

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
        
        LayoutInflater inflater = LayoutInflater.from(this);
        floatingIconView = inflater.inflate(R.layout.floating_widget, null);

        WindowManager.LayoutParams params = new WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                PixelFormat.TRANSLUCENT);

        params.gravity = Gravity.TOP | Gravity.START;
        params.x = 100;
        params.y = 150;

        windowManager.addView(floatingIconView, params);

        // Floating icon click handler to trigger menu
        floatingIconView.setOnClickListener(v -> {
            Toast.makeText(this, "Aincrad Mods Menu Expanded [OB55 Active]", Toast.LENGTH_SHORT).show();
        });
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (floatingIconView != null) {
            windowManager.removeView(floatingIconView);
        }
    }
}

