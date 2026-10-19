import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _photo;

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
    );

    if (!mounted || photo == null) return;

    setState(() {
      _photo = photo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Камера'),
        backgroundColor: const Color(0xFFE8D7FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _photo == null
                    ? const Icon(
                        Icons.camera_alt_outlined,
                        size: 100,
                        color: Colors.purple,
                      )
                    : Image.file(
                        File(_photo!.path),
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Сделать фото'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}