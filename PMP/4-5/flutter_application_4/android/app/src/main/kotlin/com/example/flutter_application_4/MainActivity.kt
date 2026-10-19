package com.example.flutter_application_4

import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.BatteryManager
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.example.flutter_application_4/device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "getNetworkType" -> {
                    try {
                        result.success(getNetworkType())
                    } catch (e: Exception) {
                        result.error("NETWORK_ERROR", e.message, null)
                    }
                }

                "getBatteryLevel" -> {
                    try {
                        result.success(getBatteryLevel())
                    } catch (e: Exception) {
                        result.error("BATTERY_ERROR", e.message, null)
                    }
                }

                "openMap" -> {
                    val latitude = call.argument<Double>("latitude")
                    val longitude = call.argument<Double>("longitude")

                    if (latitude == null || longitude == null) {
                        result.error("INVALID_COORDINATES", "Координаты не указаны", null)
                    } else {
                        try {
                            val uri = Uri.parse("geo:$latitude,$longitude")
                            val intent = Intent(Intent.ACTION_VIEW, uri)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("MAP_ERROR", e.message, null)
                        }
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun getNetworkType(): String {
        val manager = getSystemService(
            Context.CONNECTIVITY_SERVICE
        ) as ConnectivityManager

        val network = manager.activeNetwork
            ?: return "Нет подключения"

        val capabilities = manager.getNetworkCapabilities(network)
            ?: return "Нет подключения"

        return when {
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ->
                "Wi-Fi"

            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) ->
                "Мобильная сеть"

            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) ->
                "Ethernet"

            else -> "Другая сеть"
        }
    }

    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(
            Context.BATTERY_SERVICE
        ) as BatteryManager

        val level = batteryManager.getIntProperty(
            BatteryManager.BATTERY_PROPERTY_CAPACITY
        )

        return if (level in 0..100) level else -1
    }
}