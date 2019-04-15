package zlp.heatmap1;

import android.annotation.TargetApi;
import android.content.Context;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        String msg = "zalupa";
        Log.d(null, msg+'1');
        super.onCreate(savedInstanceState);
        Log.d(null, msg+'2');
        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), "zlp.heatmap1/wifi").setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                        Log.d(null, msg+'3');
                        if ("getCurWifiLevel".equals(methodCall.method)) {
                            try {
                                result.success(getCurWifiLevel());
                                Log.d(null, msg+" success");
                            } catch (Exception e) {
                                result.error("FAILED", "Failed to get current WiFi level", e.toString());
                            }
                        } else {
                            Log.d(null, msg+'4');
                            result.notImplemented();
                        }
                    }
                }
        );
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    int getCurWifiLevel() {
        Log.d(null, "zalupa 5");
        WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(WIFI_SERVICE);
        Log.d(null, new Integer(wifiManager.getConnectionInfo().getFrequency()).toString());
        return wifiManager.getConnectionInfo().getRssi();
    }
}
