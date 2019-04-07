package zlp.heatmap1;

import android.content.Context;
import android.net.wifi.WifiManager;
import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), "zlp.heatmap1/wifi").setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                        if (methodCall.equals("getCurWifiLevel")) {
                            try {
                                result.success(getCurWifiLevel());
                            } catch (Exception e) {
                                result.error("FAILED", "Failed to get current WiFi level", e.toString());
                            }
                        } else {
                            result.notImplemented();
                        }
                    }
                }
        );
    }

    int getCurWifiLevel() {
        WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(WIFI_SERVICE);
        return wifiManager.getConnectionInfo().getRssi();
    }
}
