package com.example.heatmap

import android.content.Context
import android.net.wifi.WifiManager
import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity() : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        MethodChannel(flutterView, "com.example.heatmap/wifi").setMethodCallHandler { call, result ->
            if("getCurWifiLevel".equals(call.method)){
                try{
                    result.success(getWifiLevel())
                }catch (e: Exception){
                    result.error("FAILED", "Failed to get CurWifiLevel", e.toString())
                }
            }else{
                result.notImplemented()
            }
        }
    }

    fun getWifiLevel(): Int {
        val wifiManager = baseContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        return wifiManager.connectionInfo.rssi;
    }
}
