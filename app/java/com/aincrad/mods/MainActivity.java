package com.aincrad.mods;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    private EditText keyInputField;
    private Button loginSubmitButton;
    private Button overlayPermissionButton;
    private final String VALID_KEY = "RITIK-OB55-DEMO-2026";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Load XML Layout
        setContentView(R.layout.activity_main);

        keyInputField = findViewById(R.id.keyInputField);
        loginSubmitButton = findViewById(R.id.loginSubmitButton);
        overlayPermissionButton = findViewById(R.id.overlayPermissionButton);

        overlayPermissionButton.setOnClickListener(v -> openOverlaySettings());

        loginSubmitButton.setOnClickListener(v -> {
            String enteredKey = keyInputField.getText().toString().trim();
            if (enteredKey.equals(VALID_KEY)) {
                if (!hasOverlayPermission()) {
                    openOverlaySettings();
                    return;
                }
                Toast.makeText(this, "Key Accepted! Launching Aincrad Overlay...", Toast.LENGTH_SHORT).show();

                // Launch Floating Window Service
                Intent overlayIntent = new Intent(this, AincradOverlayService.class);
                startService(overlayIntent);
                finish();
            } else {
                Toast.makeText(this, "Access Denied! Invalid Key.", Toast.LENGTH_LONG).show();
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        // Permission mil gayi to button hat jayega
        overlayPermissionButton.setVisibility(hasOverlayPermission() ? View.GONE : View.VISIBLE);
    }

    private boolean hasOverlayPermission() {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this);
    }

    private void openOverlaySettings() {
        Toast.makeText(this, "Floating permission allow karo, phir wapas aao", Toast.LENGTH_LONG).show();
        Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:" + getPackageName()));
        startActivity(intent);
    }
}
