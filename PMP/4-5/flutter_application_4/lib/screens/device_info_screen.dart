import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  static const MethodChannel _channel =
      MethodChannel('com.example.flutter_application_4/device');

  String _network = 'Не определено';
  String _battery = 'Не определено';
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
  try {
    final network = await _channel.invokeMethod<String>('getNetworkType');
    final battery = await _channel.invokeMethod<int>('getBatteryLevel');

    if (!mounted) return;

    setState(() {
      _network = network ?? 'Неизвестно';
      _battery = battery == null
          ? 'Неизвестно'
          : battery == -1
              ? 'Недоступно'
              : '$battery%';
      _error = '';
    });
  } on PlatformException catch (e) {
    if (!mounted) return;

    setState(() {
      _error = '${e.code}: ${e.message ?? "Ошибка Android"}';
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _error = e.toString();
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Информация об устройстве'),
        backgroundColor: const Color(0xFFE8D7FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.wifi, color: Colors.purple),
                title: const Text('Тип сети'),
                subtitle: Text(_network),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.battery_charging_full,
                  color: Colors.purple,
                ),
                title: const Text('Заряд батареи'),
                subtitle: Text(_battery),
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _error,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadInfo,
                child: const Text('Обновить данные'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}