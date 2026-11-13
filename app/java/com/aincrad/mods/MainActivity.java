package com.aincrad.mods;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

public class MainActivity extends AppCompatActivity {
    private EditText keyInputField;
    private Button loginSubmitButton;
    private static final int PERMISSION_REQ_ID = 101;
    private final String VALID_KEY = "RITIK-OB55-DEMO-2026";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Load XML Layout
        setContentView(R.layout.activity_main);

        keyInputField = findViewById(R.id.keyInputField);
        loginSubmitButton = findViewById(R.id.loginSubmitButton);

        requestAppPermissions();

        loginSubmitButton.setOnClickListener(v -> {
            String enteredKey = keyInputField.getText().toString().trim();
            if (enteredKey.equals(VALID_KEY)) {
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

    private void requestAppPermissions() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.SYSTEM_ALERT_WINDOW) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{
                Manifest.permission.READ_EXTERNAL_STORAGE, 
                Manifest.permission.WRITE_EXTERNAL_STORAGE
            }, PERMISSION_REQ_ID);
        }
    }
}

