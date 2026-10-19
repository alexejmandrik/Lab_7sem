import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const MethodChannel _channel =
      MethodChannel('com.example.flutter_application_4/device');

  Future<void> _openMap(BuildContext context) async {
    try {
      await _channel.invokeMethod('openMap', {
        'latitude': 53.9006,
        'longitude': 27.5590,
      });
    } on PlatformException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось открыть карту: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта'),
        backgroundColor: const Color(0xFFE8D7FF),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                size: 90,
                color: Colors.purple,
              ),
              const SizedBox(height: 20),
              const Text(
                'Минск',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('53.9006, 27.5590'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openMap(context),
                  icon: const Icon(Icons.map),
                  label: const Text('Открыть в приложении карт'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}